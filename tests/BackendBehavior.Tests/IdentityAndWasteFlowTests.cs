using Contracts;
using IdentityService.Application.CacheModels;
using IdentityService.Application.DTOs.Auth;
using IdentityService.Application.Repositories;
using IdentityService.Application.Services;
using IdentityService.Domain.Entities;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using NSubstitute;
using WasteReportService.Application.Clients;
using WasteReportService.Application.Repositories;
using WasteReportService.Domain.Entities;
using Xunit;
using WasteApplicationService = WasteReportService.Application.Services.WasteReportService;

namespace BackendBehavior.Tests;

public sealed class IdentityAndWasteFlowTests
{
    [Fact]
    public async Task RegisterAndVerifyOtp_CreatesAnActiveCitizenWithHashedPassword()
    {
        var uow = Substitute.For<IIdentityUnitOfWork>();
        var users = Substitute.For<IUserRepository>();
        uow.Users.Returns(users);
        users.EmailExistsAsync("citizen@example.com").Returns(false);
        uow.SaveChangesAsync(Arg.Any<CancellationToken>()).Returns(1);
        User? createdUser = null;
        users.AddAsync(Arg.Do<User>(user => createdUser = user)).Returns(Task.CompletedTask);

        using var cache = new MemoryCache(new MemoryCacheOptions());
        var configuration = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Jwt:Key"] = "a-development-key-that-is-longer-than-thirty-two-characters",
            ["Jwt:Issuer"] = "issuer",
            ["Jwt:Audience"] = "audience"
        }).Build();

        var email = Substitute.For<IEmailService>();
        string? emailBody = null;
        email.SendEmailAsync(
                "citizen@example.com",
                Arg.Any<string>(),
                Arg.Do<string>(body => emailBody = body),
                true)
            .Returns(Task.CompletedTask);
        var service = new AuthService(uow, configuration, cache, email);

        await service.RegisterCitizenAsync(new RegisterRequestDto
        {
            Email = "citizen@example.com",
            FullName = "Citizen",
            Password = "StrongPassword123!",
            ConfirmPassword = "StrongPassword123!"
        });

        Assert.NotNull(emailBody);
        var otp = System.Text.RegularExpressions.Regex.Match(emailBody!, @"\b\d{6}\b").Value;
        Assert.NotEmpty(otp);
        var result = await service.VerifyOtpAndCreateUserAsync("citizen@example.com", otp);

        Assert.Same(createdUser, result);
        Assert.Equal(1, result.RoleId);
        Assert.Equal("Active", result.Status);
        Assert.True(BCrypt.Net.BCrypt.Verify("StrongPassword123!", result.Password));
        Assert.False(cache.TryGetValue("OTP_citizen@example.com", out _));
        await email.Received(1).SendEmailAsync("citizen@example.com", Arg.Any<string>(), Arg.Any<string>(), true);
    }

    [Fact]
    public async Task AcceptReport_ValidatesDistrictAndCreatesRequestAndNotification()
    {
        var report = new WasteReport { ReportId = 7, SubmittedBy = 11, DistrictId = 4, Status = "Pending" };
        var uow = CreateWasteUnitOfWork(report);
        var identity = Substitute.For<IIdentityClient>();
        identity.GetEnterpriseAsync(22).Returns(new EnterpriseProfileDto { EnterpriseId = 22, ManagedDistrictId = 4 });
        var collection = Substitute.For<ICollectionClient>();
        collection.CreateFromReportAsync(Arg.Any<CreateCollectionRequestFromReportRequest>())
            .Returns(new CollectionRequestDto { RequestId = 9, ReportId = report.ReportId, EnterpriseId = 22 });
        var engagement = Substitute.For<IEngagementClient>();
        engagement.CreateNotificationAsync(Arg.Any<CreateNotificationRequest>()).Returns(Task.CompletedTask);
        var service = new WasteApplicationService(uow, identity, collection, engagement, NullLogger<WasteApplicationService>.Instance);

        var result = await service.AcceptAsync(report.ReportId, 22);

        Assert.Equal("Accepted", report.Status);
        Assert.Equal("Accepted", result.Status);
        await collection.Received(1).CreateFromReportAsync(Arg.Is<CreateCollectionRequestFromReportRequest>(request =>
            request.ReportId == report.ReportId && request.EnterpriseId == 22 && request.Status == "Pending"));
        await engagement.Received(1)
            .CreateNotificationAsync(
                Arg.Is<CreateNotificationRequest>(request =>
                    request.UserId == report.SubmittedBy &&
                    request.Content.Contains(
                        "chấp nhận",
                        StringComparison.OrdinalIgnoreCase)));
    }

    [Fact]
    public async Task Dashboard_ResolvesRecentReportSubmitterThroughIdentityService()
    {
        var report = new WasteReport
        {
            ReportId = 7,
            SubmittedBy = 11,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow,
            WasteTypes = new List<WasteType> { new() { WasteTypeId = 2, Name = "Plastic", IsActive = true } }
        };
        var uow = CreateWasteUnitOfWork(report);
        uow.WasteReports.GetAllAsync().Returns(new[] { report });
        var identity = Substitute.For<IIdentityClient>();
        identity.GetUserAsync(report.SubmittedBy).Returns(new UserDto { UserId = report.SubmittedBy, FullName = "Citizen Name" });
        var service = new WasteApplicationService(
            uow,
            identity,
            Substitute.For<ICollectionClient>(),
            Substitute.For<IEngagementClient>(),
            NullLogger<WasteApplicationService>.Instance);

        var result = await service.GetDashboardStatsAsync(DateTime.UtcNow.Year);

        Assert.Single(result.RecentReports);
        Assert.Equal("Citizen Name", result.RecentReports[0].SubmittedByName);
    }

    private static IWasteUnitOfWork CreateWasteUnitOfWork(WasteReport report)
    {
        var uow = Substitute.For<IWasteUnitOfWork>();

        uow.WasteReports.Returns(Substitute.For<IWasteReportRepository>());
        uow.WasteTypes.Returns(Substitute.For<IWasteTypeRepository>());
        uow.Districts.Returns(Array.Empty<District>().AsQueryable());

        uow.WasteReports
            .GetByIdAsync(report.ReportId)
            .Returns(report);

        uow.WasteReports
            .TrySetStatusToAcceptedAsync(report.ReportId)
            .Returns(_ =>
            {
                if (!string.Equals(
                        report.Status,
                        "Pending",
                        StringComparison.OrdinalIgnoreCase))
                {
                    return false;
                }

                report.Status = "Accepted";
                return true;
            });

        uow.SaveChangesAsync(Arg.Any<CancellationToken>())
            .Returns(1);

        return uow;
    }
}
