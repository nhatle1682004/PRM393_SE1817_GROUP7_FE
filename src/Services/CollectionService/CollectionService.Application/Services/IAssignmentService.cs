using CollectionService.Application.DTOs.Assignment;

namespace CollectionService.Application.Services;

public interface IAssignmentService
{
    Task<CollectorAssignmentResponseDto> AssignCollectorAsync(int requestId, int enterpriseId, AssignCollectorDto dto);
    Task<CollectorAssignmentResponseDto> ReassignCollectorAsync(int assignmentId, int enterpriseId, ReassignCollectorDto dto);
    Task<CancelAssignmentResponseDto> CancelAssignmentAsync(int assignmentId, int userId, string userRole);
    Task<IEnumerable<AssignmentDto>> GetAllAssignmentsByEnterpriseAsync(int enterpriseId);
    Task<IEnumerable<AssignmentHistoryDto>> GetAssignmentHistoryByRequestAsync(int requestId, int enterpriseId);
    Task<IEnumerable<MyAssignmentDto>> GetMyAssignmentsAsync(int collectorId);
    Task<MyAssignmentDto?> GetAssignmentDetailAsync(int assignmentId, int collectorId);
}
