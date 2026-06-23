using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using CollectionService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CollectionService.Infrastructure.Repositories;

public sealed class CollectionUnitOfWork : ICollectionUnitOfWork
{
    private readonly CollectionDbContext _context;

    public CollectionUnitOfWork(CollectionDbContext context, ICollectionRequestRepository requests, ICollectorAssignmentRepository assignments)
    {
        _context = context;
        CollectionRequests = requests;
        CollectorAssignments = assignments;
    }

    public ICollectionRequestRepository CollectionRequests { get; }
    public ICollectorAssignmentRepository CollectorAssignments { get; }
    public IQueryable<CollectionConfirmation> CollectionConfirmations => _context.CollectionConfirmations;
    public IQueryable<CollectionDetail> CollectionDetails => _context.CollectionDetails;
    public Task AddConfirmationAsync(CollectionConfirmation confirmation) => _context.CollectionConfirmations.AddAsync(confirmation).AsTask();
    public Task AddDetailAsync(CollectionDetail detail) => _context.CollectionDetails.AddAsync(detail).AsTask();
    public async Task ExecuteInTransactionAsync(Func<Task> action, CancellationToken cancellationToken = default)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
        await action();
        await transaction.CommitAsync(cancellationToken);
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) => _context.SaveChangesAsync(cancellationToken);
}
