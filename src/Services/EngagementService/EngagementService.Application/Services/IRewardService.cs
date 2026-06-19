using Contracts;
using EngagementService.Application.DTOs.Reward;

namespace EngagementService.Application.Services;

public interface IRewardService
{
    Task<int> GetUserTotalPointsAsync(int userId);
    Task<IEnumerable<RewardVoucherDto>> GetAvailableRewardsAsync();
    Task<IEnumerable<EngagementService.Application.DTOs.Reward.RewardTransactionDto>> GetUserTransactionHistoryAsync(int userId);
    Task<RedeemRewardResponseDto> RedeemRewardAsync(int userId, RedeemRewardRequestDto request);
    Task<Contracts.RewardTransactionDto> CreateTransactionAsync(CreateRewardTransactionRequest request);
}
