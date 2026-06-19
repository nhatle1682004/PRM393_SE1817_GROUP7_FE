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
        var allUsers = await _userService.GetAllAsync();
        return Ok(allUsers.Where(u => string.Equals(u.RoleName, "Collector", StringComparison.OrdinalIgnoreCase)));
    }

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAllUsers() => Ok(await _userService.GetAllAsync());

    [HttpGet("{id:int}")]
    [Authorize]
    public async Task<IActionResult> GetUserById(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        return user == null ? NotFound(new { message = "User not found" }) : Ok(user);
    }

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequestDto request)
    {
        try
        {
            var result = await _userService.CreateUserAsync(request);
            return CreatedAtAction(nameof(CreateUser), new { id = result.UserId }, result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("exists"))
        {
            return Conflict(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create user: {Email}", request.Email);
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserRequestDto request)
    {
        try
        {
            return Ok(await _userService.UpdateUserAsync(id, request));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
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

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        try
        {
            await _userService.DeleteUserAsync(id);
            return NoContent();
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
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

    [HttpPut("{id:int}/deactivate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeactivateUser(int id)
    {
        try
        {
            return Ok(await _userService.SoftDeleteUserAsync(id));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/activate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> ActivateUser(int id)
    {
        try
        {
            return Ok(await _userService.ReactivateUserAsync(id));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
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
