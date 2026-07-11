using Contracts;
using EngagementService.Application.Clients;
using EngagementService.Application.DTOs.Reward;
using EngagementService.Application.Repositories;
using EngagementService.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace EngagementService.Application.Services;

public sealed class RewardService : IRewardService
{
    private readonly IEngagementUnitOfWork _uow;
    private readonly IIdentityClient _identityClient;
    private readonly INotificationService _notificationService;
    private readonly ILogger<RewardService> _logger;

    public RewardService(
        IEngagementUnitOfWork uow,
        IIdentityClient identityClient,
        INotificationService notificationService,
        ILogger<RewardService> logger)
    {
        _uow = uow;
        _identityClient = identityClient;
        _notificationService = notificationService;
        _logger = logger;
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
            .Select(MapReward);
        return Task.FromResult(rewards);
    }

    public Task<IEnumerable<RewardVoucherDto>> GetAllRewardsAsync()
    {
        var rewards = _uow.Rewards
            .OrderBy(r => r.Points)
            .AsEnumerable()
            .Select(MapReward);
        return Task.FromResult(rewards);
    }

    public async Task<RewardVoucherDto> CreateRewardAsync(CreateRewardDto request)
    {
        ValidateReward(request.Name, request.Points);
        if (_uow.Rewards.Any(r => r.Name.ToLower() == request.Name.Trim().ToLower()))
            throw new InvalidOperationException("Reward name already exists");

        var reward = new Reward
        {
            Name = request.Name.Trim(),
            Description = request.Description?.Trim(),
            Points = request.Points,
            Status = request.Status
        };

        await _uow.AddRewardAsync(reward);
        await _uow.SaveChangesAsync();
        return MapReward(reward);
    }

    public async Task<RewardVoucherDto> UpdateRewardAsync(int rewardId, UpdateRewardDto request)
    {
        ValidateReward(request.Name, request.Points);
        var reward = _uow.Rewards.FirstOrDefault(r => r.RewardId == rewardId)
            ?? throw new InvalidOperationException("Reward not found");

        if (_uow.Rewards.Any(r => r.RewardId != rewardId && r.Name.ToLower() == request.Name.Trim().ToLower()))
            throw new InvalidOperationException("Reward name already exists");

        reward.Name = request.Name.Trim();
        reward.Description = request.Description?.Trim();
        reward.Points = request.Points;
        reward.Status = request.Status;

        _uow.UpdateReward(reward);
        await _uow.SaveChangesAsync();
        return MapReward(reward);
    }

    public async Task DeleteRewardAsync(int rewardId)
    {
        var reward = _uow.Rewards.FirstOrDefault(r => r.RewardId == rewardId)
            ?? throw new InvalidOperationException("Reward not found");

        reward.Status = false;
        _uow.UpdateReward(reward);
        await _uow.SaveChangesAsync();
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
                CreatedAt = t.CreatedAt,
                Status = t.Status,
                SourceType = t.SourceType,
                ReferenceId = t.ReferenceId,
                FailureReason = t.FailureReason,
                CompletedAt = t.CompletedAt
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

        var redeemedAt = DateTime.UtcNow;
        var sourceType = "RewardRedeem";
        // A public redeem call is a distinct business operation. Grouping by minute
        // incorrectly treated two legitimate redemptions as the same request.
        var referenceId = $"{userId}:{reward.RewardId}:{Guid.NewGuid():N}";
        var existing = FindBySource(sourceType, referenceId, "Redeemed");
        if (existing != null)
        {
            if (string.Equals(existing.Status, "Completed", StringComparison.OrdinalIgnoreCase))
            {
                return new RedeemRewardResponseDto
                {
                    TransactionId = existing.TransactionId,
                    RewardId = reward.RewardId,
                    RewardName = reward.Name,
                    RedeemedPoints = reward.Points,
                    RemainingPoints = user.TotalPoints,
                    RedeemedAt = existing.CompletedAt ?? existing.CreatedAt ?? redeemedAt
                };
            }

            throw new InvalidOperationException("A matching redeem transaction is already pending or failed. Please retry later.");
        }

        var transaction = new RewardTransaction
        {
            UserId = userId,
            RewardId = reward.RewardId,
            Type = "Redeemed",
            Points = -reward.Points,
            Description = $"Đã đổi voucher: {reward.Name}",
            CreatedAt = redeemedAt,
            Status = "Pending",
            SourceType = sourceType,
            ReferenceId = referenceId
        };

        await _uow.AddRewardTransactionAsync(transaction);
        await _uow.SaveChangesAsync();

        int remaining;
        try
        {
            remaining = await _identityClient.DeductPointsAsync(userId, reward.Points, $"Đã đổi voucher: {reward.Name}");
        }
        catch (Exception ex)
        {
            await MarkTransactionFailedAsync(transaction, ex);
            throw;
        }

        transaction.Status = "Completed";
        transaction.CompletedAt = DateTime.UtcNow;
        _uow.UpdateRewardTransaction(transaction);
        await _uow.SaveChangesAsync();

        try
        {
            await _notificationService.CreateAsync(new CreateNotificationRequest
            {
                UserId = userId,
                Content = $"Bạn đã đổi thành công voucher '{reward.Name}' lấy {reward.Points} điểm."
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create redeem notification for transaction {TransactionId}", transaction.TransactionId);
        }

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
        var existing = FindBySource(request.SourceType, request.ReferenceId, request.Type);
        if (existing != null)
        {
            if (string.Equals(existing.Status, "Completed", StringComparison.OrdinalIgnoreCase))
                return MapToContract(existing);

            if (string.Equals(existing.Status, "Pending", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("A matching reward transaction is already pending.");

            existing.Status = "Pending";
            existing.FailureReason = null;
            existing.CompletedAt = null;
            _uow.UpdateRewardTransaction(existing);
            await _uow.SaveChangesAsync();
            return await CompleteTransactionAsync(existing, request);
        }

        var transaction = new RewardTransaction
        {
            UserId = request.UserId,
            RewardId = request.RewardId,
            ReportId = request.ReportId,
            Points = request.Points,
            Type = request.Type,
            Description = request.Description,
            CreatedAt = createdAt,
            Status = "Pending",
            SourceType = request.SourceType,
            ReferenceId = request.ReferenceId
        };
        await _uow.AddRewardTransactionAsync(transaction);
        await _uow.SaveChangesAsync();

        return await CompleteTransactionAsync(transaction, request);
    }

    private async Task<Contracts.RewardTransactionDto> CompleteTransactionAsync(RewardTransaction transaction, CreateRewardTransactionRequest request)
    {
        try
        {
            if (request.AdjustUserPoints && request.Points != 0)
            {
                if (request.Points > 0)
                    await _identityClient.AddPointsAsync(request.UserId, request.Points, request.Description ?? request.Type);
                else
                    await _identityClient.DeductPointsAsync(request.UserId, Math.Abs(request.Points), request.Description ?? request.Type);
            }
        }
        catch (Exception ex)
        {
            await MarkTransactionFailedAsync(transaction, ex);
            throw;
        }

        transaction.Status = "Completed";
        transaction.CompletedAt = DateTime.UtcNow;
        transaction.FailureReason = null;
        _uow.UpdateRewardTransaction(transaction);
        await _uow.SaveChangesAsync();

        if (request.CreateNotification && !string.IsNullOrWhiteSpace(request.NotificationContent))
        {
            try
            {
                await _notificationService.CreateAsync(new CreateNotificationRequest { UserId = request.UserId, Content = request.NotificationContent });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create reward notification for transaction {TransactionId}", transaction.TransactionId);
            }
        }

        return MapToContract(transaction);
    }

    private RewardTransaction? FindBySource(string? sourceType, string? referenceId, string type)
    {
        if (string.IsNullOrWhiteSpace(sourceType) || string.IsNullOrWhiteSpace(referenceId))
            return null;

        return _uow.RewardTransactions.FirstOrDefault(t =>
            t.SourceType == sourceType &&
            t.ReferenceId == referenceId &&
            t.Type == type);
    }

    private async Task MarkTransactionFailedAsync(RewardTransaction transaction, Exception ex)
    {
        transaction.Status = "Failed";
        transaction.FailureReason = ex.Message;
        _uow.UpdateRewardTransaction(transaction);
        await _uow.SaveChangesAsync();
        _logger.LogError(ex, "Reward transaction {TransactionId} failed", transaction.TransactionId);
    }

    private static Contracts.RewardTransactionDto MapToContract(RewardTransaction transaction) => new()
    {
        TransactionId = transaction.TransactionId,
        UserId = transaction.UserId,
        RewardId = transaction.RewardId,
        ReportId = transaction.ReportId,
        Points = transaction.Points,
        Type = transaction.Type,
        Description = transaction.Description,
        CreatedAt = transaction.CreatedAt,
        Status = transaction.Status,
        SourceType = transaction.SourceType,
        ReferenceId = transaction.ReferenceId,
        FailureReason = transaction.FailureReason,
        CompletedAt = transaction.CompletedAt
    };

    private static RewardVoucherDto MapReward(Reward reward) => new()
    {
        RewardId = reward.RewardId,
        Name = reward.Name,
        Description = reward.Description,
        Points = reward.Points,
        Status = reward.Status
    };

    private static void ValidateReward(string name, int points)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name is required");
        if (points <= 0)
            throw new ArgumentException("Points must be greater than zero");
    }
}
