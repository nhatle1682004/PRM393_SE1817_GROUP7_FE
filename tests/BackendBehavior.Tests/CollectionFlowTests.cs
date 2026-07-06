using CollectionService.Application.Clients;
using CollectionService.Application.DTOs.Collection;
using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using Contracts;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Abstractions;
using NSubstitute;
using Xunit;
using CollectionApplicationService = CollectionService.Application.Services.CollectionService;

namespace BackendBehavior.Tests;

public sealed class CollectionFlowTests
{
    [Fact]
    public async Task CompleteCollection_PersistsDetailsAndRunsEveryCrossServiceEffect()
    {
        var request = new CollectionRequest
        {
            RequestId = 20,
            ReportId = 100,
            EnterpriseId = 30,
            Status = "Arrived"
        };
        var assignment = new CollectorAssignment
        {
            AssignmentId = 10,
            RequestId = request.RequestId,
            AssignedCollector = 40,
            Status = "Arrived",
            BeforeImageUrl = "/uploads/collection-proofs/before.jpg",
            Request = request
        };
        request.CollectorAssignments.Add(assignment);

        var uow = Substitute.For<ICollectionUnitOfWork>();
        uow.CollectionRequests.Returns(Substitute.For<ICollectionRequestRepository>());
        uow.CollectorAssignments.Returns(Substitute.For<ICollectorAssignmentRepository>());
        uow.CollectionConfirmations.Returns(Array.Empty<CollectionConfirmation>().AsQueryable());
        uow.CollectionDetails.Returns(Array.Empty<CollectionDetail>().AsQueryable());
        uow.CollectorAssignments.GetByIdWithDetailsAsync(assignment.AssignmentId).Returns(assignment);
        uow.SaveChangesAsync(Arg.Any<CancellationToken>()).Returns(1);
        uow.ExecuteInTransactionAsync(Arg.Any<Func<Task>>(), Arg.Any<CancellationToken>())
            .Returns(call => call.Arg<Func<Task>>()());

        CollectionConfirmation? savedConfirmation = null;
        var savedDetails = new List<CollectionDetail>();
        uow.AddConfirmationAsync(Arg.Do<CollectionConfirmation>(confirmation =>
        {
            confirmation.ConfirmationId = 77;
            savedConfirmation = confirmation;
        })).Returns(Task.CompletedTask);
        uow.AddDetailAsync(Arg.Do<CollectionDetail>(detail => savedDetails.Add(detail))).Returns(Task.CompletedTask);

        var waste = Substitute.For<IWasteReportClient>();
        waste.GetWasteTypeAsync(3).Returns(new WasteTypeDto
        {
            WasteTypeId = 3,
            Name = "Plastic",
            RewardPoints = 4,
            IsActive = true
        });
        waste.GetReportAsync(request.ReportId).Returns(new WasteReportDto
        {
            ReportId = request.ReportId,
            SubmittedBy = 50,
            Status = "Accepted"
        });
        waste.UpdateReportStatusAsync(request.ReportId, "Collected").Returns(Task.CompletedTask);

        var engagement = Substitute.For<IEngagementClient>();
        CreateRewardTransactionRequest? rewardRequest = null;
        engagement.CreateRewardTransactionAsync(Arg.Do<CreateRewardTransactionRequest>(value => rewardRequest = value))
            .Returns(Task.CompletedTask);

        var service = new CollectionApplicationService(uow, waste, engagement, NullLogger<CollectionApplicationService>.Instance);
        var formFile = CreateFile("after.jpg");

        var result = await service.CompleteCollectionAsync(assignment.AssignmentId, assignment.AssignedCollector, new CompleteCollectionDto
        {
            AfterImage = formFile,
            Note = "Collected",
            ActualWeights = new List<CompleteCollectionDto.WasteWeightItemDto>
            {
                new() { WasteTypeId = 3, Weight = 2.5 }
            }
        });

        Assert.Equal("Completed", assignment.Status);
        Assert.Equal("Completed", request.Status);
        Assert.NotNull(savedConfirmation);
        Assert.Single(savedDetails);
        Assert.Equal(3, savedDetails[0].WasteTypeId);
        Assert.Equal(2.5, savedDetails[0].ActualWeight);
        Assert.Equal(10, result.EarnedPoints);
        Assert.NotNull(rewardRequest);
        Assert.Equal(50, rewardRequest!.UserId);
        Assert.Equal(10, rewardRequest.Points);
        Assert.True(rewardRequest.AdjustUserPoints);
        Assert.True(rewardRequest.CreateNotification);
        Assert.Equal("Collection", rewardRequest.SourceType);
        Assert.Equal(request.RequestId.ToString(), rewardRequest.ReferenceId);
        await waste.Received(1).UpdateReportStatusAsync(request.ReportId, "Collected");

        DeleteGeneratedFile(result.AfterImageUrl);
    }

    [Theory]
    [InlineData(CollectionIssueTypes.WasteNotFound)]
    [InlineData(CollectionIssueTypes.WrongAddress)]
    [InlineData(CollectionIssueTypes.WasteTypeMismatch)]
    [InlineData(CollectionIssueTypes.CitizenUnavailable)]
    [InlineData(CollectionIssueTypes.Other)]
    public async Task ReportIssue_PreservesEveryLegacyIssueType(string issueType)
    {
        var request = new CollectionRequest { RequestId = 2, ReportId = 3, Status = "OnTheWay" };
        var assignment = new CollectorAssignment
        {
            AssignmentId = 1,
            AssignedCollector = 9,
            RequestId = request.RequestId,
            Request = request,
            Status = "OnTheWay"
        };
        var uow = CreateUnitOfWork(assignment);
        var service = new CollectionApplicationService(
            uow,
            Substitute.For<IWasteReportClient>(),
            Substitute.For<IEngagementClient>(),
            NullLogger<CollectionApplicationService>.Instance);

        await service.ReportIssueAsync(assignment.AssignmentId, assignment.AssignedCollector, new ReportIssueDto
        {
            IssueType = issueType,
            Description = "proof"
        });

        Assert.Equal("ReportedIssue", assignment.Status);
        Assert.Equal("Issue", request.Status);
        Assert.Equal(issueType, request.IssueReport);
        Assert.Equal("proof", request.IssueReason);
    }

    [Fact]
    public async Task StartCollection_BlocksASecondActiveTrip()
    {
        var request = new CollectionRequest { RequestId = 2, ReportId = 3, Status = "Assigned" };
        var assignment = new CollectorAssignment
        {
            AssignmentId = 1,
            AssignedCollector = 9,
            RequestId = request.RequestId,
            Request = request,
            Status = "Assigned"
        };
        var uow = CreateUnitOfWork(assignment);
        uow.CollectorAssignments.HasActiveTripByCollectorAsync(assignment.AssignedCollector).Returns(true);
        var service = new CollectionApplicationService(
            uow,
            Substitute.For<IWasteReportClient>(),
            Substitute.For<IEngagementClient>(),
            NullLogger<CollectionApplicationService>.Instance);

        var error = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            service.StartCollectionAsync(assignment.AssignmentId, assignment.AssignedCollector));

        Assert.Contains("another active collection trip", error.Message);
        Assert.Equal("Assigned", assignment.Status);
    }

    private static ICollectionUnitOfWork CreateUnitOfWork(CollectorAssignment assignment)
    {
        var uow = Substitute.For<ICollectionUnitOfWork>();
        uow.CollectionRequests.Returns(Substitute.For<ICollectionRequestRepository>());
        uow.CollectorAssignments.Returns(Substitute.For<ICollectorAssignmentRepository>());
        uow.CollectionConfirmations.Returns(Array.Empty<CollectionConfirmation>().AsQueryable());
        uow.CollectionDetails.Returns(Array.Empty<CollectionDetail>().AsQueryable());
        uow.CollectorAssignments.GetByIdWithDetailsAsync(assignment.AssignmentId).Returns(assignment);
        uow.SaveChangesAsync(Arg.Any<CancellationToken>()).Returns(1);
        return uow;
    }

    private static IFormFile CreateFile(string fileName)
    {
        var stream = new MemoryStream(new byte[] { 1, 2, 3 });
        return new FormFile(stream, 0, stream.Length, "file", fileName);
    }

    private static void DeleteGeneratedFile(string? relativeUrl)
    {
        if (string.IsNullOrWhiteSpace(relativeUrl))
            return;

        var relativePath = relativeUrl.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
        var path = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", relativePath["uploads".Length..].TrimStart(Path.DirectorySeparatorChar));
        if (File.Exists(path))
            File.Delete(path);
    }
}
