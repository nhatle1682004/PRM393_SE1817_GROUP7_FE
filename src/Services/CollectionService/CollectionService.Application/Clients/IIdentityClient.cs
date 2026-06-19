using Contracts;

namespace CollectionService.Application.Clients;

public interface IIdentityClient
{
    Task<UserDto?> GetUserAsync(int userId);
    Task<CollectorProfileDto?> GetCollectorAsync(int collectorId);
    Task<IEnumerable<CollectorProfileDto>> GetCollectorsByEnterpriseAsync(int enterpriseId);
}
