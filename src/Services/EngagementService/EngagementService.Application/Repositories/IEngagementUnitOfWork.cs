using EngagementService.Domain.Entities;

namespace EngagementService.Application.Repositories;

public interface IEngagementUnitOfWork
{
    IQueryable<Notification> Notifications { get; }
    IQueryable<Reward> Rewards { get; }
    IQueryable<RewardTransaction> RewardTransactions { get; }
    IQueryable<Feedback> Feedbacks { get; }
    Task AddNotificationAsync(Notification notification);
    Task AddRewardTransactionAsync(RewardTransaction transaction);
    Task AddFeedbackAsync(Feedback feedback);
    void UpdateNotification(Notification notification);
    void UpdateReward(Reward reward);
    void UpdateFeedback(Feedback feedback);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
