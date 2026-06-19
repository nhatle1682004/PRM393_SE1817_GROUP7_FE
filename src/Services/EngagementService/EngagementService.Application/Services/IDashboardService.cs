using EngagementService.Application.DTOs.Dashboard;

namespace EngagementService.Application.Services;

public interface IDashboardService
{
    Task<AdminDashboardDto> GetAdminDashboardAsync(int year);
}
