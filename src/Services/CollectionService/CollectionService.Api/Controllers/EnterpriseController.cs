using CollectionService.Application.DTOs.Assignment;
using CollectionService.Application.DTOs.CollectionRequest;
using CollectionService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CollectionService.Api.Controllers;

[ApiController]
[Route("api/enterprise")]
[Authorize(Roles = "Enterprise")]
public sealed class EnterpriseController : ControllerBase
{
    private readonly ICollectionRequestService _collectionService;
    private readonly IAssignmentService _assignmentService;

    public EnterpriseController(
        ICollectionRequestService collectionService,
        IAssignmentService assignmentService)
    {
        _collectionService = collectionService;
        _assignmentService = assignmentService;
    }

    private int GetUserId() => int.TryParse(User.FindFirst("UserId")?.Value, out var id) ? id : 0;

    // ============ COLLECTORS ============
    [HttpGet("collectors")]
    public async Task<IActionResult> GetCollectors()
    {
        var enterpriseId = GetUserId();
        return Ok(await _collectionService.GetCollectorsByEnterpriseAsync(enterpriseId));
    }

    [HttpGet("collectors/{collectorId:int}")]
    public async Task<IActionResult> GetCollector(int collectorId)
    {
        var enterpriseId = GetUserId();
        var collector = await _collectionService.GetCollectorDetailAsync(collectorId, enterpriseId);
        return collector == null ? NotFound(new { message = "Collector not found" }) : Ok(collector);
    }

    [HttpPut("collectors/{collectorId:int}/availability")]
    public async Task<IActionResult> UpdateCollectorAvailability(int collectorId, [FromBody] UpdateCollectorAvailabilityDto dto)
    {
        var enterpriseId = GetUserId();
        try
        {
            var result = await _collectionService.UpdateCollectorAvailabilityAsync(collectorId, enterpriseId, dto.IsAvailable);
            return Ok(result);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    // ============ COLLECTION REQUESTS ============
    [HttpGet("collection-requests")]
    public async Task<IActionResult> GetCollectionRequests()
    {
        var enterpriseId = GetUserId();
        return Ok(await _collectionService.GetCollectionRequestsByEnterpriseAsync(enterpriseId));
    }

    [HttpGet("collection-requests/{requestId:int}")]
    public async Task<IActionResult> GetCollectionRequest(int requestId)
    {
        var enterpriseId = GetUserId();
        var request = await _collectionService.GetCollectionRequestDetailAsync(requestId, enterpriseId);
        return request == null ? NotFound(new { message = "Collection request not found" }) : Ok(request);
    }

    // ============ ASSIGNMENTS ============
    [HttpPost("assignments")]
    public async Task<IActionResult> AssignCollector([FromBody] AssignCollectorDto dto)
    {
        var enterpriseId = GetUserId();
        try
        {
            var result = await _assignmentService.AssignCollectorAsync(dto.RequestId, enterpriseId, dto);
            return Ok(result);
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("assignments/{assignmentId:int}/cancel")]
    public async Task<IActionResult> CancelAssignment(int assignmentId)
    {
        var userId = GetUserId();
        var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? "Enterprise";
        try
        {
            var result = await _assignmentService.CancelAssignmentAsync(assignmentId, userId, userRole);
            return Ok(result);
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

    [HttpGet("assignments")]
    public async Task<IActionResult> GetAssignments()
    {
        var enterpriseId = GetUserId();
        return Ok(await _assignmentService.GetAllAssignmentsByEnterpriseAsync(enterpriseId));
    }
}

public sealed class UpdateCollectorAvailabilityDto
{
    public bool IsAvailable { get; set; }
}
