using Contracts;
using Microsoft.AspNetCore.Mvc;
using WasteReportService.Application.Services;

namespace WasteReportService.Api.Controllers;

[ApiController]
[Route("internal/waste")]
public sealed class InternalWasteController : ControllerBase
{
    private readonly IWasteReportService _wasteReportService;
    private readonly IWasteTypeService _wasteTypeService;

    public InternalWasteController(IWasteReportService wasteReportService, IWasteTypeService wasteTypeService)
    {
        _wasteReportService = wasteReportService;
        _wasteTypeService = wasteTypeService;
    }

    [HttpGet("reports/{id:int}")]
    public async Task<IActionResult> GetReport(int id)
    {
        var report = await _wasteReportService.GetInternalByIdAsync(id);
        return report == null ? NotFound(new { message = "Waste report not found" }) : Ok(report);
    }

    [HttpGet("reports/by-district/{districtId:int}")]
    public async Task<IActionResult> GetReportsByDistrict(int districtId)
    {
        return Ok(await _wasteReportService.GetInternalByDistrictAsync(districtId));
    }

    [HttpPut("reports/{id:int}/status")]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] WasteReportStatusUpdateRequest request)
    {
        await _wasteReportService.UpdateStatusAsync(id, request.Status);
        return Ok(new { ReportId = id, request.Status });
    }

    [HttpGet("waste-types/{id:int}")]
    public async Task<IActionResult> GetWasteType(int id)
    {
        var wt = await _wasteTypeService.GetByIdAsync(id);
        return wt == null ? NotFound(new { message = "Waste type not found" }) : Ok(new WasteTypeDto
        {
            WasteTypeId = wt.WasteTypeId,
            Name = wt.Name,
            Description = wt.Description,
            RewardPoints = wt.RewardPoints,
            IsActive = wt.IsActive
        });
    }

    [HttpGet("waste-types")]
    public async Task<IActionResult> GetWasteTypes([FromQuery] int[] ids)
    {
        var result = new List<WasteTypeDto>();
        foreach (var id in ids)
        {
            var wt = await _wasteTypeService.GetByIdAsync(id);
            if (wt != null)
                result.Add(new WasteTypeDto { WasteTypeId = wt.WasteTypeId, Name = wt.Name, Description = wt.Description, RewardPoints = wt.RewardPoints, IsActive = wt.IsActive });
        }
        return Ok(result);
    }

    [HttpGet("dashboard/{year:int}")]
    public async Task<IActionResult> GetDashboardStats(int year) => Ok(await _wasteReportService.GetDashboardStatsAsync(year));
}
