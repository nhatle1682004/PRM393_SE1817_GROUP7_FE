using CollectionService.Application.DTOs.Assignment;
using CollectionService.Application.DTOs.CollectionRequest;
using Contracts;

namespace CollectionService.Application.Services;

public interface ICollectionRequestService
{
    Task<IEnumerable<global::CollectionService.Application.DTOs.CollectionRequest.CollectionRequestDto>> GetCollectionRequestsByEnterpriseAsync(int enterpriseId);
    Task<CollectionRequestDetailDto?> GetCollectionRequestDetailAsync(int requestId, int enterpriseId);
    Task<IEnumerable<global::CollectionService.Application.DTOs.CollectionRequest.CollectionRequestDto>> GetAllCollectionRequestsAsync();
    Task<IEnumerable<AssignmentHistoryDto>> GetAssignmentHistoryByRequestAsync(int requestId, int enterpriseId);
    Task<Contracts.CollectionRequestDto> CreateFromReportAsync(CreateCollectionRequestFromReportRequest request);
    Task DeleteByReportIdAsync(int reportId);
    Task<CollectionFeedbackContextDto?> GetFeedbackContextByReportAsync(int reportId);
    Task CancelAssignmentForComplaintAsync(CancelAssignmentForComplaintRequest request);
    Task<CollectionDashboardStatsDto> GetDashboardStatsAsync();
    Task<IEnumerable<global::CollectionService.Application.DTOs.CollectionRequest.CollectionRequestDto>> GetUnassignedRequestsAsync(int enterpriseId);
    Task<IEnumerable<global::CollectionService.Application.DTOs.Assignment.CollectorDto>> GetCollectorsByEnterpriseAsync(int enterpriseId);
    Task<global::CollectionService.Application.DTOs.Assignment.CollectorDto?> GetCollectorDetailAsync(int collectorId, int enterpriseId);
    Task<bool> UpdateCollectorAvailabilityAsync(int collectorId, int enterpriseId, bool isAvailable);
    Task SoftDeleteCollectorAsync(int collectorId, int enterpriseId);
    Task ReactivateCollectorAsync(int collectorId, int enterpriseId);
}
