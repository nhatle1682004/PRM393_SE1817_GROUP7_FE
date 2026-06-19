using CollectionService.Domain.Entities;

namespace CollectionService.Application.Repositories;

public interface ICollectorAssignmentRepository
{
    Task AddAsync(CollectorAssignment entity);
    Task<CollectorAssignment?> GetByIdAsync(int assignmentId);
    Task<CollectorAssignment?> GetByIdWithDetailsAsync(int assignmentId);
    Task<IEnumerable<CollectorAssignment>> GetByRequestIdAsync(int requestId);
    Task<IEnumerable<CollectorAssignment>> GetByCollectorIdAsync(int collectorId);
    Task<IEnumerable<CollectorAssignment>> GetByEnterpriseIdAsync(int enterpriseId);
    Task<int> CountOpenAssignmentsByCollectorAsync(int collectorId);
    Task<bool> HasActiveTripByCollectorAsync(int collectorId);
    void Update(CollectorAssignment entity);
}
