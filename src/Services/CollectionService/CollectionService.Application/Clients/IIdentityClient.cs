using Contracts;

namespace CollectionService.Application.Clients;

public interface IIdentityClient
{
    Task<UserDto?> GetUserAsync(int userId);
    Task<CollectorProfileDto?> GetCollectorAsync(int collectorId);
    Task<IEnumerable<CollectorProfileDto>> GetCollectorsByEnterpriseAsync(int enterpriseId);
    Task UpdateCollectorAvailabilityAsync(int collectorId, bool isAvailable);
    Task SoftDeleteUserAsync(int userId);
    Task ReactivateUserAsync(int userId);
}
