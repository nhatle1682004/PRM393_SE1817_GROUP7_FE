using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using CollectionService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CollectionService.Infrastructure.Repositories;

public sealed class CollectionRequestRepository : ICollectionRequestRepository
{
    private readonly CollectionDbContext _context;

    public CollectionRequestRepository(CollectionDbContext context)
    {
        _context = context;
    }

    public Task AddAsync(CollectionRequest entity) => _context.CollectionRequests.AddAsync(entity).AsTask();

    public Task<CollectionRequest?> GetByIdAsync(int requestId) => _context.CollectionRequests
        .Include(x => x.CollectorAssignments)
        .FirstOrDefaultAsync(x => x.RequestId == requestId);

    public Task<CollectionRequest?> GetByReportIdAsync(int reportId) => _context.CollectionRequests
        .Include(x => x.CollectorAssignments)
        .ThenInclude(a => a.CollectionConfirmation)
        .ThenInclude(c => c!.CollectionDetails)
        .FirstOrDefaultAsync(x => x.ReportId == reportId);

    public async Task<IEnumerable<CollectionRequest>> GetByEnterpriseIdAsync(int enterpriseId) => await _context.CollectionRequests
        .Include(x => x.CollectorAssignments)
        .Where(x => x.EnterpriseId == enterpriseId)
        .OrderByDescending(x => x.CreatedAt)
        .ToListAsync();

    public async Task<IEnumerable<CollectionRequest>> GetAllAsync() => await _context.CollectionRequests
        .Include(x => x.CollectorAssignments)
        .OrderByDescending(x => x.CreatedAt)
        .ToListAsync();

    public void Update(CollectionRequest entity) => _context.CollectionRequests.Update(entity);
    public void Delete(CollectionRequest entity) => _context.CollectionRequests.Remove(entity);
}
