using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using CollectionService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CollectionService.Infrastructure.Repositories;

public sealed class CollectorAssignmentRepository : ICollectorAssignmentRepository
{
    private readonly CollectionDbContext _context;

    public CollectorAssignmentRepository(CollectionDbContext context)
    {
        _context = context;
    }

    public Task AddAsync(CollectorAssignment entity) => _context.CollectorAssignments.AddAsync(entity).AsTask();

    public Task<CollectorAssignment?> GetByIdAsync(int assignmentId) => _context.CollectorAssignments
        .Include(x => x.Request)
        .Include(x => x.CollectionConfirmation)
        .FirstOrDefaultAsync(x => x.AssignmentId == assignmentId);

    public Task<CollectorAssignment?> GetByIdWithDetailsAsync(int assignmentId) => _context.CollectorAssignments
        .Include(x => x.Request)
        .Include(x => x.CollectionConfirmation)
        .ThenInclude(c => c!.CollectionDetails)
        .FirstOrDefaultAsync(x => x.AssignmentId == assignmentId);

    public async Task<IEnumerable<CollectorAssignment>> GetByRequestIdAsync(int requestId) => await _context.CollectorAssignments
        .Include(x => x.CollectionConfirmation)
        .Where(x => x.RequestId == requestId)
        .OrderByDescending(x => x.AssignedAt)
        .ToListAsync();

    public async Task<IEnumerable<CollectorAssignment>> GetByCollectorIdAsync(int collectorId) => await _context.CollectorAssignments
        .Include(x => x.Request)
        .Include(x => x.CollectionConfirmation)
        .ThenInclude(c => c!.CollectionDetails)
        .Where(x => x.AssignedCollector == collectorId)
        .OrderByDescending(x => x.AssignedAt)
        .ToListAsync();

    public async Task<IEnumerable<CollectorAssignment>> GetByEnterpriseIdAsync(int enterpriseId) => await _context.CollectorAssignments
        .Include(x => x.Request)
        .Include(x => x.CollectionConfirmation)
        .Where(x => x.Request.EnterpriseId == enterpriseId)
        .OrderByDescending(x => x.AssignedAt)
        .ToListAsync();

    public Task<int> CountOpenAssignmentsByCollectorAsync(int collectorId)
    {
        var openStatuses = new[] { "Assigned", "OnTheWay", "Arrived", "ReportedIssue" };
        return _context.CollectorAssignments.CountAsync(x => x.AssignedCollector == collectorId && openStatuses.Contains(x.Status));
    }

    public Task<bool> HasActiveTripByCollectorAsync(int collectorId)
    {
        var activeTripStatuses = new[] { "OnTheWay", "Arrived" };
        return _context.CollectorAssignments.AnyAsync(x => x.AssignedCollector == collectorId && activeTripStatuses.Contains(x.Status));
    }

    public void Update(CollectorAssignment entity) => _context.CollectorAssignments.Update(entity);
}
