using Contracts;
using IdentityService.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.Api.Controllers;

[ApiController]
[Route("internal/identity")]
public sealed class InternalIdentityController : ControllerBase
{
    private readonly IUserService _userService;

    public InternalIdentityController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("users/{id:int}")]
    public async Task<IActionResult> GetUser(int id)
    {
        var user = await _userService.GetInternalUserAsync(id);
        return user == null ? NotFound(new { message = "User not found" }) : Ok(user);
    }

    [HttpGet("enterprises/{id:int}")]
    public async Task<IActionResult> GetEnterprise(int id)
    {
        var profile = await _userService.GetEnterpriseProfileAsync(id);
        return profile == null ? NotFound(new { message = "Enterprise profile not found" }) : Ok(profile);
    }

    [HttpGet("enterprises/by-district/{districtId:int}")]
    public async Task<IActionResult> GetEnterpriseByDistrict(int districtId)
    {
        var profile = await _userService.GetEnterpriseByDistrictAsync(districtId);
        return profile == null ? NotFound(new { message = "Enterprise profile not found" }) : Ok(profile);
    }

    [HttpGet("collectors/{id:int}")]
    public async Task<IActionResult> GetCollector(int id)
    {
        var profile = await _userService.GetCollectorProfileAsync(id);
        return profile == null ? NotFound(new { message = "Collector profile not found" }) : Ok(profile);
    }

    [HttpGet("collectors/by-enterprise/{enterpriseId:int}")]
    public async Task<IActionResult> GetCollectorsByEnterprise(int enterpriseId)
    {
        return Ok(await _userService.GetCollectorsByEnterpriseAsync(enterpriseId));
    }

    [HttpPut("users/{id:int}/points/add")]
    public async Task<IActionResult> AddPoints(int id, [FromBody] PointAdjustmentRequest request)
    {
        return Ok(new { TotalPoints = await _userService.AddPointsAsync(id, request.Points) });
    }

    [HttpPut("users/{id:int}/points/deduct")]
    public async Task<IActionResult> DeductPoints(int id, [FromBody] PointAdjustmentRequest request)
    {
        return Ok(new { TotalPoints = await _userService.DeductPointsAsync(id, request.Points) });
    }

    [HttpPut("collectors/{id:int}/warnings")]
    public async Task<IActionResult> AddWarning(int id, [FromBody] WarningAdjustmentRequest request)
    {
        return Ok(await _userService.AddCollectorWarningAsync(id, request.Warnings));
    }

    [HttpPut("collectors/{id:int}/availability")]
    public async Task<IActionResult> UpdateAvailability(int id, [FromBody] bool isAvailable)
    {
        return Ok(await _userService.UpdateCollectorAvailabilityAsync(id, isAvailable));
    }

    [HttpGet("dashboard/{year:int}")]
    public async Task<IActionResult> GetDashboardStats(int year)
    {
        return Ok(await _userService.GetDashboardStatsAsync(year));
    }
}
