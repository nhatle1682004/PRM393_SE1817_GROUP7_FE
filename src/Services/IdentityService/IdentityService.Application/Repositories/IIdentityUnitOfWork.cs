using IdentityService.Domain.Entities;

namespace IdentityService.Application.Repositories;

public interface IIdentityUnitOfWork
{
    IUserRepository Users { get; }
    IQueryable<Role> Roles { get; }
    IQueryable<EnterpriseProfile> EnterpriseProfiles { get; }
    Task<EnterpriseProfile?> GetEnterpriseProfileByUserIdAsync(int userId);
    IQueryable<CollectorProfile> CollectorProfiles { get; }
    void AddEnterpriseProfile(EnterpriseProfile profile);
    void AddCollectorProfile(CollectorProfile profile);
    void RemoveEnterpriseProfile(EnterpriseProfile profile);
    void RemoveCollectorProfile(CollectorProfile profile);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
