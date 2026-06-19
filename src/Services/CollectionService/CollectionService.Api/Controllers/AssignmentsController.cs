using CollectionService.Application.DTOs.Assignment;
using CollectionService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CollectionService.Api.Controllers;

[ApiController]
[Route("api/assignments")]
public sealed class AssignmentsController : ControllerBase
{
    private readonly IAssignmentService _service;

    public AssignmentsController(IAssignmentService service)
    {
        _service = service;
    }

    [HttpPost]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> AssignCollector([FromBody] AssignCollectorDto dto)
    {
        if (!TryGetUserId(out var enterpriseId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            return Ok(await _service.AssignCollectorAsync(dto.RequestId, enterpriseId, dto));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{assignmentId:int}")]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> ReassignCollector(int assignmentId, [FromBody] ReassignCollectorDto dto)
    {
        if (!TryGetUserId(out var enterpriseId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            return Ok(await _service.ReassignCollectorAsync(assignmentId, enterpriseId, dto));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{assignmentId:int}/cancel")]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> CancelAssignment(int assignmentId)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
        if (string.IsNullOrWhiteSpace(userRole))
            return Unauthorized(new { message = "Invalid or missing Role claim" });
        try
        {
            return Ok(await _service.CancelAssignmentAsync(assignmentId, userId, userRole));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("my-assignments")]
    [Authorize(Roles = "Collector")]
    public async Task<IActionResult> GetMyAssignments()
    {
        if (!TryGetUserId(out var collectorId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        return Ok(await _service.GetMyAssignmentsAsync(collectorId));
    }

    [HttpGet("{assignmentId:int}")]
    [Authorize(Roles = "Collector")]
    public async Task<IActionResult> GetAssignmentDetail(int assignmentId)
    {
        if (!TryGetUserId(out var collectorId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            var assignment = await _service.GetAssignmentDetailAsync(assignmentId, collectorId);
            return assignment == null ? NotFound(new { message = "Assignment not found" }) : Ok(assignment);
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
