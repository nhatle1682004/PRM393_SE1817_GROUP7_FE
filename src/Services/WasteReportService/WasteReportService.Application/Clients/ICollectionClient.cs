using Contracts;

namespace WasteReportService.Application.Clients;

public interface ICollectionClient
{
    Task<CollectionRequestDto?> CreateFromReportAsync(CreateCollectionRequestFromReportRequest request);
}
