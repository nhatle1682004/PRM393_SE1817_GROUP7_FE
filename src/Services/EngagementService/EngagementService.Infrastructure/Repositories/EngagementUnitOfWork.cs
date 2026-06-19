using EngagementService.Application.Repositories;
using EngagementService.Domain.Entities;
using EngagementService.Infrastructure.Persistence;

namespace EngagementService.Infrastructure.Repositories;

public sealed class EngagementUnitOfWork : IEngagementUnitOfWork
{
    private readonly EngagementDbContext _context;

    public EngagementUnitOfWork(EngagementDbContext context)
    {
        _context = context;
    }

    public IQueryable<Notification> Notifications => _context.Notifications;
    public IQueryable<Reward> Rewards => _context.Rewards;
    public IQueryable<RewardTransaction> RewardTransactions => _context.RewardTransactions;
    public IQueryable<Feedback> Feedbacks => _context.Feedbacks;
    public Task AddNotificationAsync(Notification notification) => _context.Notifications.AddAsync(notification).AsTask();
    public Task AddRewardTransactionAsync(RewardTransaction transaction) => _context.RewardTransactions.AddAsync(transaction).AsTask();
    public Task AddFeedbackAsync(Feedback feedback) => _context.Feedbacks.AddAsync(feedback).AsTask();
    public void UpdateNotification(Notification notification) => _context.Notifications.Update(notification);
    public void UpdateReward(Reward reward) => _context.Rewards.Update(reward);
    public void UpdateFeedback(Feedback feedback) => _context.Feedbacks.Update(feedback);
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) => _context.SaveChangesAsync(cancellationToken);
}
