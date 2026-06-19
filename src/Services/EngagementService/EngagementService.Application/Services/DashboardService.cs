using EngagementService.Application.Clients;
using EngagementService.Application.DTOs.Dashboard;
using Microsoft.Extensions.Caching.Memory;

namespace EngagementService.Application.Services;

public sealed class DashboardService : IDashboardService
{
    private readonly IIdentityClient _identityClient;
    private readonly IWasteReportClient _wasteClient;
    private readonly ICollectionClient _collectionClient;
    private readonly IMemoryCache _cache;

    public DashboardService(
        IIdentityClient identityClient,
        IWasteReportClient wasteClient,
        ICollectionClient collectionClient,
        IMemoryCache cache)
    {
        _identityClient = identityClient;
        _wasteClient = wasteClient;
        _collectionClient = collectionClient;
        _cache = cache;
    }

    public async Task<AdminDashboardDto> GetAdminDashboardAsync(int year)
    {
        var cacheKey = $"admin_dashboard_{year}";
        if (_cache.TryGetValue(cacheKey, out AdminDashboardDto? cached) && cached != null)
            return cached;

        var identity = await _identityClient.GetDashboardStatsAsync(year);
        var waste = await _wasteClient.GetDashboardStatsAsync(year);
        var collection = await _collectionClient.GetDashboardStatsAsync();

        var dto = new AdminDashboardDto
        {
            TotalUsers = identity?.TotalUsers ?? 0,
            TotalCitizens = identity?.TotalCitizens ?? 0,
            TotalEnterprises = identity?.TotalEnterprises ?? 0,
            TotalCollectors = identity?.TotalCollectors ?? 0,
            TotalReports = waste?.TotalReports ?? 0,
            PendingReports = waste?.PendingReports ?? 0,
            AcceptedReports = waste?.AcceptedReports ?? 0,
            CollectedReports = waste?.CollectedReports ?? 0,
            CancelledReports = waste?.CancelledReports ?? 0,
            RejectedReports = waste?.RejectedReports ?? 0,
            TotalAssignments = collection?.TotalAssignments ?? 0,
            CompletedAssignments = collection?.CompletedAssignments ?? 0,
            UserRegistrationsByMonth = identity?.UserRegistrationsByMonth.Select(x => new MonthlyCountDto { Month = x.Month, MonthName = x.MonthName, Count = x.Count }).ToList() ?? new(),
            ReportsByMonth = waste?.ReportsByMonth.Select(x => new MonthlyReportDto { Month = x.Month, MonthName = x.MonthName, Count = x.Count }).ToList() ?? new(),
            WasteTypeDistribution = waste?.WasteTypeDistribution.Select(x => new WasteTypeDistributionDto { Name = x.Name, Count = x.Count }).ToList() ?? new(),
            ReportStatusDistribution = waste?.ReportStatusDistribution.Select(x => new StatusCountDto { Status = x.Status, Count = x.Count }).ToList() ?? new(),
            TopCollectors = collection?.TopCollectors.Select(x => new TopCollectorDto { UserId = x.UserId, FullName = x.FullName, CompletedCount = x.CompletedCount }).ToList() ?? new(),
            RecentReports = waste?.RecentReports.Select(x => new RecentReportDto { ReportId = x.ReportId, SubmittedByName = x.SubmittedByName, Description = x.Description, Status = x.Status, WasteTypeNames = x.WasteTypeNames, CreatedAt = x.CreatedAt }).ToList() ?? new()
        };

        _cache.Set(cacheKey, dto, TimeSpan.FromSeconds(30));
        return dto;
    }
}
