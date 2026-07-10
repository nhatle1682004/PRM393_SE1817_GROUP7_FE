using EngagementService.Application.DTOs.Reward;
using EngagementService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EngagementService.Api.Controllers;

[ApiController]
[Route("api/rewards")]
[Authorize]
public sealed class RewardsController : ControllerBase
{
    private readonly IRewardService _rewardService;

    public RewardsController(IRewardService rewardService)
    {
        _rewardService = rewardService;
    }

    [HttpGet("catalog")]
    [Authorize(Roles = "Citizen,Admin")]
    public async Task<IActionResult> GetRewardCatalog() => Ok(await _rewardService.GetAvailableRewardsAsync());

    [HttpGet("balance")]
    public async Task<IActionResult> GetMyBalance()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();
        return Ok(new { TotalPoints = await _rewardService.GetUserTotalPointsAsync(userId) });
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetMyTransactionHistory()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();
        return Ok(await _rewardService.GetUserTransactionHistoryAsync(userId));
    }

    [HttpPost("redeem")]
    [Authorize(Roles = "Citizen")]
    public async Task<IActionResult> RedeemReward([FromBody] RedeemRewardRequestDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();
        try
        {
            return Ok(await _rewardService.RedeemRewardAsync(userId, request));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }
}
