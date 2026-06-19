using Contracts;

namespace CollectionService.Application.Clients;

public interface IWasteReportClient
{
    Task<WasteReportDto?> GetReportAsync(int reportId);
    Task<WasteTypeDto?> GetWasteTypeAsync(int wasteTypeId);
    Task UpdateReportStatusAsync(int reportId, string status);
}
