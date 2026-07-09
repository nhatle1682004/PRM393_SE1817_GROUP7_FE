using Contracts;

namespace WasteReportService.Application.Clients;

public interface ICollectionClient
{
    Task<CollectionRequestDto?> CreateFromReportAsync(CreateCollectionRequestFromReportRequest request);
    Task DeleteRequestByReportIdAsync(int reportId);
    Task<CollectionFeedbackContextDto?> GetFeedbackContextAsync(int reportId);
}
