using EngagementService.Domain.Entities;

namespace EngagementService.Application.Repositories;

public interface IEngagementUnitOfWork
{
    IQueryable<Notification> Notifications { get; }
    IQueryable<Reward> Rewards { get; }
    IQueryable<RewardTransaction> RewardTransactions { get; }
    IQueryable<Feedback> Feedbacks { get; }
    Task AddNotificationAsync(Notification notification);
    Task AddRewardAsync(Reward reward);
    Task AddRewardTransactionAsync(RewardTransaction transaction);
    Task AddFeedbackAsync(Feedback feedback);
    void UpdateNotification(Notification notification);
    void UpdateReward(Reward reward);
    void UpdateRewardTransaction(RewardTransaction transaction);
    void UpdateFeedback(Feedback feedback);
    Task ExecuteInTransactionAsync(Func<Task> action, CancellationToken cancellationToken = default);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
