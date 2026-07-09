using Contracts;

namespace EngagementService.Application.Clients;

public interface IIdentityClient
{
    Task<UserDto?> GetUserAsync(int userId);
    Task<EnterpriseProfileDto?> GetEnterpriseAsync(int enterpriseId);
    Task<int> AddPointsAsync(int userId, int points, string reason);
    Task<int> DeductPointsAsync(int userId, int points, string reason);
    Task<CollectorProfileDto?> AddCollectorWarningAsync(int collectorId, int points, string reason);
    Task<IdentityDashboardStatsDto?> GetDashboardStatsAsync(int year);
}
