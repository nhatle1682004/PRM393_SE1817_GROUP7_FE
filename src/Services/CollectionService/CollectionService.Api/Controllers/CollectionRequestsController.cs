using CollectionService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CollectionService.Api.Controllers;

[ApiController]
[Route("api/collection-requests")]
public sealed class CollectionRequestsController : ControllerBase
{
    private readonly ICollectionRequestService _service;

    public CollectionRequestsController(ICollectionRequestService service)
    {
        _service = service;
    }

    [HttpGet]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> GetMyCollectionRequests()
    {
        if (!TryGetUserId(out var enterpriseId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        return Ok(await _service.GetCollectionRequestsByEnterpriseAsync(enterpriseId));
    }

    [HttpGet("{requestId:int}")]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> GetCollectionRequestDetail(int requestId)
    {
        if (!TryGetUserId(out var enterpriseId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            var request = await _service.GetCollectionRequestDetailAsync(requestId, enterpriseId);
            return request == null ? NotFound(new { message = "Collection request not found" }) : Ok(request);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpGet("all")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAllCollectionRequests() => Ok(await _service.GetAllCollectionRequestsAsync());

    [HttpGet("{requestId:int}/assignments")]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> GetAssignmentHistory(int requestId)
    {
        if (!TryGetUserId(out var enterpriseId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            return Ok(await _service.GetAssignmentHistoryByRequestAsync(requestId, enterpriseId));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }
}
