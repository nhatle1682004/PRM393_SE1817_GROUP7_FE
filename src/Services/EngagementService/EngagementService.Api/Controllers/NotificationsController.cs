using EngagementService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EngagementService.Api.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public sealed class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyNotifications()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        return Ok(await _notificationService.GetUserNotificationsAsync(userId));
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();
        await _notificationService.MarkAsReadAsync(id, userId);
        return Ok(new { message = "Notification marked as read" });
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();
        await _notificationService.MarkAllAsReadAsync(userId);
        return Ok(new { message = "All notifications marked as read" });
    }

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }
}
