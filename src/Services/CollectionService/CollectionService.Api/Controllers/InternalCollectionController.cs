using CollectionService.Application.Services;
using Contracts;
using Microsoft.AspNetCore.Mvc;

namespace CollectionService.Api.Controllers;

[ApiController]
[Route("internal/collection")]
public sealed class InternalCollectionController : ControllerBase
{
    private readonly ICollectionRequestService _requestService;

    public InternalCollectionController(ICollectionRequestService requestService)
    {
        _requestService = requestService;
    }

    [HttpPost("requests/from-report")]
    public async Task<IActionResult> CreateFromReport([FromBody] CreateCollectionRequestFromReportRequest request)
    {
        return Ok(await _requestService.CreateFromReportAsync(request));
    }

    [HttpDelete("requests/by-report/{reportId:int}")]
    public async Task<IActionResult> DeleteByReport(int reportId)
    {
        await _requestService.DeleteByReportIdAsync(reportId);
        return NoContent();
    }

    [HttpGet("feedback-context/by-report/{reportId:int}")]
    public async Task<IActionResult> GetFeedbackContext(int reportId)
    {
        var context = await _requestService.GetFeedbackContextByReportAsync(reportId);
        return context == null ? NotFound(new { message = "Collection request not found" }) : Ok(context);
    }

    [HttpPut("assignments/cancel-for-complaint")]
    public async Task<IActionResult> CancelForComplaint([FromBody] CancelAssignmentForComplaintRequest request)
    {
        await _requestService.CancelAssignmentForComplaintAsync(request);
        return Ok(new { message = "Assignment cancelled" });
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboardStats() => Ok(await _requestService.GetDashboardStatsAsync());
}
