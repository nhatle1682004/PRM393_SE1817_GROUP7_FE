using CollectionService.Application.DTOs.Collection;

namespace CollectionService.Application.Services;

public interface ICollectionService
{
    Task<DeclineAssignmentResponseDto> DeclineAssignmentAsync(int assignmentId, int collectorId, DeclineAssignmentDto dto);
    Task<StartCollectionResponseDto> StartCollectionAsync(int assignmentId, int collectorId);
    Task<ArrivedAtLocationResponseDto> ArrivedAtLocationAsync(int assignmentId, int collectorId, ArrivedAtLocationDto dto);
    Task<ReportIssueResponseDto> ReportIssueAsync(int assignmentId, int collectorId, ReportIssueDto dto);
    Task<CompleteCollectionResponseDto> CompleteCollectionAsync(int assignmentId, int collectorId, CompleteCollectionDto dto);
}
