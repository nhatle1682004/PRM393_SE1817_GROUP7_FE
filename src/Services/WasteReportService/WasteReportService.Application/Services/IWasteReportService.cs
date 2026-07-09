using Contracts;
using WasteReportService.Application.DTOs.WasteReport;

namespace WasteReportService.Application.Services;

public interface IWasteReportService
{
    Task<WasteReportCreatedResponseDto> CreateAsync(int userId, CreateWasteReportDto dto);
    Task<WasteReportStatusResponseDto> AcceptAsync(int reportId, int enterpriseId);
    Task<WasteReportStatusResponseDto> RejectAsync(int reportId);
    Task<IEnumerable<DTOs.WasteReport.WasteReportDto>> GetAllAsync(int? userId);
    Task<IEnumerable<DTOs.WasteReport.WasteReportDto>> GetByDistrictAsync(int districtId);
    Task<IEnumerable<Contracts.WasteReportDto>> GetInternalByDistrictAsync(int districtId);
    Task<DTOs.WasteReport.WasteReportDto?> GetByIdAsync(int reportId, int? userId);
    Task<DTOs.WasteReport.WasteReportDto> UpdateAsync(int reportId, int userId, UpdateWasteReportDto dto);
    Task<WasteReportStatusResponseDto> CancelAsync(int reportId, int userId);
    Task<Contracts.WasteReportDto?> GetInternalByIdAsync(int reportId);
    Task UpdateStatusAsync(int reportId, string status);
    Task ResetStatusAsync(int reportId);
    Task<WasteDashboardStatsDto> GetDashboardStatsAsync(int year);
}
