using Contracts;
using EngagementService.Application.DTOs.Reward;

namespace EngagementService.Application.Services;

public interface IRewardService
{
    Task<int> GetUserTotalPointsAsync(int userId);
    Task<IEnumerable<RewardVoucherDto>> GetAvailableRewardsAsync();
    Task<IEnumerable<RewardVoucherDto>> GetAllRewardsAsync();
    Task<RewardVoucherDto> CreateRewardAsync(CreateRewardDto request);
    Task<RewardVoucherDto> UpdateRewardAsync(int rewardId, UpdateRewardDto request);
    Task DeleteRewardAsync(int rewardId);
    Task<IEnumerable<EngagementService.Application.DTOs.Reward.RewardTransactionDto>> GetUserTransactionHistoryAsync(int userId);
    Task<RedeemRewardResponseDto> RedeemRewardAsync(int userId, RedeemRewardRequestDto request);
    Task<Contracts.RewardTransactionDto> CreateTransactionAsync(CreateRewardTransactionRequest request);
}
