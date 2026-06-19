using Contracts;
using EngagementService.Application.Clients;
using EngagementService.Application.DTOs.Reward;
using EngagementService.Application.Repositories;
using EngagementService.Domain.Entities;

namespace EngagementService.Application.Services;

public sealed class RewardService : IRewardService
{
    private readonly IEngagementUnitOfWork _uow;
    private readonly IIdentityClient _identityClient;
    private readonly INotificationService _notificationService;

    public RewardService(IEngagementUnitOfWork uow, IIdentityClient identityClient, INotificationService notificationService)
    {
        _uow = uow;
        _identityClient = identityClient;
        _notificationService = notificationService;
    }

    public async Task<int> GetUserTotalPointsAsync(int userId)
    {
        var user = await _identityClient.GetUserAsync(userId);
        return user?.TotalPoints ?? 0;
    }

    public Task<IEnumerable<RewardVoucherDto>> GetAvailableRewardsAsync()
    {
        var rewards = _uow.Rewards
            .Where(r => r.Status)
            .OrderBy(r => r.Points)
            .AsEnumerable()
            .Select(r => new RewardVoucherDto { RewardId = r.RewardId, Name = r.Name, Description = r.Description, Points = r.Points, Status = r.Status });
        return Task.FromResult(rewards);
    }

    public Task<IEnumerable<EngagementService.Application.DTOs.Reward.RewardTransactionDto>> GetUserTransactionHistoryAsync(int userId)
    {
        var history = _uow.RewardTransactions
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .AsEnumerable()
            .Select(t => new EngagementService.Application.DTOs.Reward.RewardTransactionDto
            {
                TransactionId = t.TransactionId,
                UserId = t.UserId,
                ReportId = t.ReportId,
                Points = t.Points,
                Type = t.Type,
                Description = t.Description,
                CreatedAt = t.CreatedAt
            });
        return Task.FromResult(history);
    }

    public async Task<RedeemRewardResponseDto> RedeemRewardAsync(int userId, RedeemRewardRequestDto request)
    {
        var user = await _identityClient.GetUserAsync(userId) ?? throw new InvalidOperationException("User not found");
        var reward = _uow.Rewards.FirstOrDefault(r => r.RewardId == request.RewardId);
        if (reward == null || !reward.Status)
            throw new InvalidOperationException("Voucher not found or inactive");
        if (reward.Points <= 0)
            throw new InvalidOperationException("Voucher points is invalid");
        if (user.TotalPoints < reward.Points)
            throw new InvalidOperationException("Not enough points to redeem this voucher");

        var remaining = await _identityClient.DeductPointsAsync(userId, reward.Points, $"Redeemed voucher: {reward.Name}");
        var redeemedAt = DateTime.UtcNow;
        var transaction = new RewardTransaction
        {
            UserId = userId,
            RewardId = reward.RewardId,
            Type = "Redeemed",
            Points = -reward.Points,
            Description = $"Redeemed voucher: {reward.Name}",
            CreatedAt = redeemedAt
        };

        await _uow.AddRewardTransactionAsync(transaction);
        await _uow.SaveChangesAsync();
        await _notificationService.CreateAsync(new CreateNotificationRequest
        {
            UserId = userId,
            Content = $"You have successfully redeemed voucher '{reward.Name}' for {reward.Points} points."
        });

        return new RedeemRewardResponseDto
        {
            TransactionId = transaction.TransactionId,
            RewardId = reward.RewardId,
            RewardName = reward.Name,
            RedeemedPoints = reward.Points,
            RemainingPoints = remaining,
            RedeemedAt = redeemedAt
        };
    }

    public async Task<Contracts.RewardTransactionDto> CreateTransactionAsync(CreateRewardTransactionRequest request)
    {
        var createdAt = DateTime.UtcNow;
        if (request.AdjustUserPoints && request.Points != 0)
        {
            if (request.Points > 0)
                await _identityClient.AddPointsAsync(request.UserId, request.Points, request.Description ?? request.Type);
            else
                await _identityClient.DeductPointsAsync(request.UserId, Math.Abs(request.Points), request.Description ?? request.Type);
        }

        var transaction = new RewardTransaction
        {
            UserId = request.UserId,
            RewardId = request.RewardId,
            ReportId = request.ReportId,
            Points = request.Points,
            Type = request.Type,
            Description = request.Description,
            CreatedAt = createdAt
        };
        await _uow.AddRewardTransactionAsync(transaction);
        await _uow.SaveChangesAsync();

        if (request.CreateNotification && !string.IsNullOrWhiteSpace(request.NotificationContent))
            await _notificationService.CreateAsync(new CreateNotificationRequest { UserId = request.UserId, Content = request.NotificationContent });

        return new Contracts.RewardTransactionDto
        {
            TransactionId = transaction.TransactionId,
            UserId = transaction.UserId,
            RewardId = transaction.RewardId,
            ReportId = transaction.ReportId,
            Points = transaction.Points,
            Type = transaction.Type,
            Description = transaction.Description,
            CreatedAt = transaction.CreatedAt
        };
    }
}
