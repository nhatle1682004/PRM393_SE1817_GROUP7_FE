using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WasteReportService.Application.Services;

namespace WasteReportService.Api.Controllers;

[ApiController]
[Route("api/districts")]
public sealed class DistrictsController : ControllerBase
{
    private readonly IDistrictService _districtService;

    public DistrictsController(IDistrictService districtService)
    {
        _districtService = districtService;
    }

    [HttpGet]
    [Authorize(Roles = "Admin,Enterprise")]
    public async Task<IActionResult> GetAll() => Ok(await _districtService.GetAllAsync());
}
