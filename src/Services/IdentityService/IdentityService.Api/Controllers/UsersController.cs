using IdentityService.Application.DTOs.User;
using IdentityService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.Api.Controllers;

[ApiController]
[Route("api/users")]
[Produces("application/json")]
public sealed class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserService userService, ILogger<UsersController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    [HttpGet("collectors")]
    [Authorize(Roles = "Admin,Enterprise")]
    public async Task<IActionResult> GetCollectors()
    {
        if (!TryGetUserId(out var currentUserId))
            return Unauthorized();

        var currentUser = await _userService.GetByIdAsync(currentUserId);
        if (currentUser == null) return NotFound();

        // Admin can see all collectors
        if (string.Equals(currentUser.RoleName, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            var allUsers = await _userService.GetAllAsync();
            return Ok(allUsers.Where(u => string.Equals(u.RoleName, "Collector", StringComparison.OrdinalIgnoreCase)));
        }

        // Enterprise can only see their own collectors
        if (string.Equals(currentUser.RoleName, "Enterprise", StringComparison.OrdinalIgnoreCase))
        {
            return Ok(await _userService.GetCollectorsByEnterpriseAsUserDtoAsync(currentUser.UserId));
        }

        return Forbid();
    }

    [HttpGet("{id:int}")]
    [Authorize]
    public async Task<IActionResult> GetUserById(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        return user == null ? NotFound(new { message = "User not found" }) : Ok(user);
    }

    [HttpPut("me/availability")]
    [Authorize(Roles = "Collector")]
    public async Task<IActionResult> UpdateMyAvailability([FromBody] UpdateCollectorAvailabilityDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });

        try
        {
            return Ok(await _userService.UpdateCollectorAvailabilityAsync(userId, request.IsAvailable));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPut("me/profile")]
    [Authorize]
    public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateProfileRequestDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });

        try
        {
            return Ok(await _userService.UpdateMyProfileAsync(userId, request));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("exists"))
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpGet("me/profile")]
    [Authorize]
    public async Task<IActionResult> GetMyProfile()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });

        var user = await _userService.GetByIdAsync(userId);
        return user == null ? NotFound(new { message = "User not found" }) : Ok(user);
    }

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }
}
