using Contracts;

namespace EngagementService.Application.Clients;

public interface ICollectionClient
{
    Task<CollectionFeedbackContextDto?> GetFeedbackContextByReportAsync(int reportId);
    Task CancelAssignmentForComplaintAsync(CancelAssignmentForComplaintRequest request);
    Task<CollectionDashboardStatsDto?> GetDashboardStatsAsync();
}
