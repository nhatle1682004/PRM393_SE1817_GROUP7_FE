using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WasteReportService.Application.Clients;
using WasteReportService.Application.Services;

namespace WasteReportService.Api.Controllers;

[ApiController]
[Route("api/admin/waste-reports")]
[Authorize(Roles = "Admin")]
[Produces("application/json")]
public sealed class AdminWasteController : ControllerBase
{
    private readonly IWasteReportService _wasteService;
    private readonly ICollectionClient _collectionClient;
    private readonly ILogger<AdminWasteController> _logger;

    public AdminWasteController(
        IWasteReportService wasteService,
        ICollectionClient collectionClient,
        ILogger<AdminWasteController> logger)
    {
        _wasteService = wasteService;
        _collectionClient = collectionClient;
        _logger = logger;
    }

    [HttpPut("{id:int}/reset")]
    public async Task<IActionResult> ResetReport(int id)
    {
        try
        {
            // 1. Reset Waste Report status to Pending
            await _wasteService.ResetStatusAsync(id);

            // 2. Delete associated Collection Request (and its assignments/confirmations)
            await _collectionClient.DeleteRequestByReportIdAsync(id);

            return Ok(new { message = $"Waste report #{id} has been reset to Pending and associated collection requests have been deleted." });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error resetting waste report {ReportId}", id);
            return StatusCode(500, new { message = "An error occurred while resetting the report." });
        }
    }
}
