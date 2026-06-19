using CollectionService.Domain.Entities;

namespace CollectionService.Application.Repositories;

public interface ICollectionUnitOfWork
{
    ICollectionRequestRepository CollectionRequests { get; }
    ICollectorAssignmentRepository CollectorAssignments { get; }
    IQueryable<CollectionConfirmation> CollectionConfirmations { get; }
    IQueryable<CollectionDetail> CollectionDetails { get; }
    Task AddConfirmationAsync(CollectionConfirmation confirmation);
    Task AddDetailAsync(CollectionDetail detail);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
