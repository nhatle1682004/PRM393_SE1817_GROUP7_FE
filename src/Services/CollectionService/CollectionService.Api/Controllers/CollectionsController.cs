using CollectionService.Application.DTOs.Collection;
using CollectionService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CollectionService.Api.Controllers;

[ApiController]
[Route("api/collections")]
public sealed class CollectionsController : ControllerBase
{
    private readonly ICollectionService _service;

    public CollectionsController(ICollectionService service)
    {
        _service = service;
    }

    [HttpPut("{assignmentId:int}/decline")]
    [Authorize(Roles = "Collector")]
    public async Task<IActionResult> DeclineAssignment(int assignmentId, [FromBody] DeclineAssignmentDto dto)
        => await HandleCollectorAction(assignmentId, collectorId => _service.DeclineAssignmentAsync(assignmentId, collectorId, dto));

    [HttpPut("{assignmentId:int}/start")]
    [Authorize(Roles = "Collector")]
    public async Task<IActionResult> StartCollection(int assignmentId)
        => await HandleCollectorAction(assignmentId, collectorId => _service.StartCollectionAsync(assignmentId, collectorId));

    [HttpPut("{assignmentId:int}/arrived")]
    [Authorize(Roles = "Collector")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> ArrivedAtLocation(int assignmentId, [FromForm] ArrivedAtLocationDto dto)
        => await HandleCollectorAction(assignmentId, collectorId => _service.ArrivedAtLocationAsync(assignmentId, collectorId, dto));

    [HttpPut("{assignmentId:int}/report-issue")]
    [Authorize(Roles = "Collector")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> ReportIssue(int assignmentId, [FromForm] ReportIssueDto dto)
        => await HandleCollectorAction(assignmentId, collectorId => _service.ReportIssueAsync(assignmentId, collectorId, dto));

    [HttpPut("{assignmentId:int}/complete")]
    [Authorize(Roles = "Collector")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> CompleteCollection(int assignmentId, [FromForm] CompleteCollectionDto dto)
        => await HandleCollectorAction(assignmentId, collectorId => _service.CompleteCollectionAsync(assignmentId, collectorId, dto));

    private async Task<IActionResult> HandleCollectorAction<T>(int assignmentId, Func<int, Task<T>> action)
    {
        if (!TryGetUserId(out var collectorId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            return Ok(await action(collectorId));
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

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }
}
