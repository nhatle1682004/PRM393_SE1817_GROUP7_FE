using IdentityService.Application.Repositories;
using IdentityService.Domain.Entities;
using IdentityService.Infrastructure.Persistence;

namespace IdentityService.Infrastructure.Repositories;

public sealed class IdentityUnitOfWork : IIdentityUnitOfWork
{
    private readonly IdentityDbContext _context;

    public IdentityUnitOfWork(IdentityDbContext context, IUserRepository users)
    {
        _context = context;
        Users = users;
    }

    public IUserRepository Users { get; }
    public IQueryable<Role> Roles => _context.Roles;
    public IQueryable<EnterpriseProfile> EnterpriseProfiles => _context.EnterpriseProfiles;
    public IQueryable<CollectorProfile> CollectorProfiles => _context.CollectorProfiles;
    public void AddEnterpriseProfile(EnterpriseProfile profile) => _context.EnterpriseProfiles.Add(profile);
    public void AddCollectorProfile(CollectorProfile profile) => _context.CollectorProfiles.Add(profile);
    public void RemoveEnterpriseProfile(EnterpriseProfile profile) => _context.EnterpriseProfiles.Remove(profile);
    public void RemoveCollectorProfile(CollectorProfile profile) => _context.CollectorProfiles.Remove(profile);
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) => _context.SaveChangesAsync(cancellationToken);
}
