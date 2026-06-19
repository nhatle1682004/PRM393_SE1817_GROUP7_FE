using Contracts;

namespace EngagementService.Application.Clients;

public interface IWasteReportClient
{
    Task<WasteReportDto?> GetReportAsync(int reportId);
    Task UpdateReportStatusAsync(int reportId, string status);
    Task<WasteDashboardStatsDto?> GetDashboardStatsAsync(int year);
}
