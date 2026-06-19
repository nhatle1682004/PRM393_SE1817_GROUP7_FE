using Contracts;
using EngagementService.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace EngagementService.Api.Controllers;

[ApiController]
[Route("internal/engagement")]
public sealed class InternalEngagementController : ControllerBase
{
    private readonly INotificationService _notificationService;
    private readonly IRewardService _rewardService;

    public InternalEngagementController(INotificationService notificationService, IRewardService rewardService)
    {
        _notificationService = notificationService;
        _rewardService = rewardService;
    }

    [HttpPost("notifications")]
    public async Task<IActionResult> CreateNotification([FromBody] CreateNotificationRequest request)
    {
        return Ok(await _notificationService.CreateAsync(request));
    }

    [HttpPost("reward-transactions")]
    public async Task<IActionResult> CreateRewardTransaction([FromBody] CreateRewardTransactionRequest request)
    {
        return Ok(await _rewardService.CreateTransactionAsync(request));
    }
}
