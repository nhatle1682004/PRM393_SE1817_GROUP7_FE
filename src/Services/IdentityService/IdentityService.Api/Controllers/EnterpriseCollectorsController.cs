using IdentityService.Application.DTOs.User;
using IdentityService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.Api.Controllers;

[ApiController]
[Route("api/enterprise/collectors")]
[Authorize(Roles = "Enterprise")]
[Produces("application/json")]
public sealed class EnterpriseCollectorsController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ILogger<EnterpriseCollectorsController> _logger;

    public EnterpriseCollectorsController(IUserService userService, ILogger<EnterpriseCollectorsController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    private int GetEnterpriseId() => int.TryParse(User.FindFirst("UserId")?.Value, out var id) ? id : 0;

    [HttpGet]
    public async Task<IActionResult> GetMyCollectors()
    {
        var enterpriseId = GetEnterpriseId();
        return Ok(await _userService.GetCollectorsByEnterpriseAsUserDtoAsync(enterpriseId));
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetCollectorById(int id)
    {
        var enterpriseId = GetEnterpriseId();
        var collector = await _userService.GetByIdAsync(id);

        if (collector == null || collector.EnterpriseId != enterpriseId || !string.Equals(collector.RoleName, "Collector", StringComparison.OrdinalIgnoreCase))
            return NotFound(new { message = "Collector not found or does not belong to your enterprise" });

        return Ok(collector);
    }

    [HttpPost]
    public async Task<IActionResult> CreateCollector([FromBody] CreateUserRequestDto request)
    {
        var enterpriseId = GetEnterpriseId();
        var collectorRoleId = await _userService.GetCollectorRoleIdAsync();

        // Enforce role and enterprise
        request.RoleId = collectorRoleId;
        request.EnterpriseId = enterpriseId;

        try
        {
            var result = await _userService.CreateUserAsync(request);
            return CreatedAtAction(nameof(GetCollectorById), new { id = result.UserId }, result);
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
            _logger.LogError(ex, "Failed to create collector for enterprise {EnterpriseId}", enterpriseId);
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateCollector(int id, [FromBody] UpdateUserRequestDto request)
    {
        var enterpriseId = GetEnterpriseId();
        var collector = await _userService.GetByIdAsync(id);

        if (collector == null || collector.EnterpriseId != enterpriseId || !string.Equals(collector.RoleName, "Collector", StringComparison.OrdinalIgnoreCase))
            return NotFound(new { message = "Collector not found or does not belong to your enterprise" });

        // Enforce enterprise consistency and role (cannot change role or enterprise)
        request.EnterpriseId = enterpriseId;
        request.RoleId = collector.RoleId;

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
    public async Task<IActionResult> DeleteCollector(int id)
    {
        var enterpriseId = GetEnterpriseId();
        var collector = await _userService.GetByIdAsync(id);

        if (collector == null || collector.EnterpriseId != enterpriseId || !string.Equals(collector.RoleName, "Collector", StringComparison.OrdinalIgnoreCase))
            return NotFound(new { message = "Collector not found or does not belong to your enterprise" });

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
}
