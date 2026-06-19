using CollectionService.Domain.Entities;

namespace CollectionService.Application.Repositories;

public interface ICollectionRequestRepository
{
    Task AddAsync(CollectionRequest entity);
    Task<CollectionRequest?> GetByIdAsync(int requestId);
    Task<CollectionRequest?> GetByReportIdAsync(int reportId);
    Task<IEnumerable<CollectionRequest>> GetByEnterpriseIdAsync(int enterpriseId);
    Task<IEnumerable<CollectionRequest>> GetAllAsync();
    void Update(CollectionRequest entity);
}
