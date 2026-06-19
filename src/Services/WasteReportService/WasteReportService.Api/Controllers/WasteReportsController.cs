using Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WasteReportService.Application.DTOs.WasteReport;
using WasteReportService.Application.Services;

namespace WasteReportService.Api.Controllers;

[ApiController]
[Route("api/waste-reports")]
public sealed class WasteReportsController : ControllerBase
{
    private readonly IWasteReportService _service;

    public WasteReportsController(IWasteReportService service)
    {
        _service = service;
    }

    public class CreateWasteReportForm
    {
        public IFormFile? Image { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string? Description { get; set; }
        public List<int> WasteTypeIds { get; set; } = new();
    }

    public sealed class UpdateWasteReportForm : CreateWasteReportForm
    {
    }

    [HttpGet]
    [Authorize(Roles = "Admin,Citizen,Enterprise")]
    public async Task<IActionResult> GetAll()
    {
        var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
        var isAdmin = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
        var isEnterprise = string.Equals(role, "Enterprise", StringComparison.OrdinalIgnoreCase);
        int? userId = null;
        if (!isAdmin && !isEnterprise)
        {
            if (!TryGetUserId(out var parsedUserId))
                return Unauthorized(new { message = "Invalid or missing UserId claim" });
            userId = parsedUserId;
        }

        return Ok(await _service.GetAllAsync(userId));
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin,Citizen,Enterprise")]
    public async Task<IActionResult> GetById(int id)
    {
        var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
        var isAdmin = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
        var isEnterprise = string.Equals(role, "Enterprise", StringComparison.OrdinalIgnoreCase);
        int? userId = null;
        if (!isAdmin && !isEnterprise)
        {
            if (!TryGetUserId(out var parsedUserId))
                return Unauthorized(new { message = "Invalid or missing UserId claim" });
            userId = parsedUserId;
        }

        var report = await _service.GetByIdAsync(id, userId);
        return report == null ? NotFound(new { message = "Waste report not found" }) : Ok(report);
    }

    [HttpPost]
    [Authorize(Roles = "Citizen")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Create([FromForm] CreateWasteReportForm form)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });

        try
        {
            var created = await _service.CreateAsync(userId, new CreateWasteReportDto
            {
                Image = await SaveImageAsync(form.Image),
                Latitude = form.Latitude,
                Longitude = form.Longitude,
                Description = form.Description,
                WasteTypeIds = form.WasteTypeIds
            });
            return CreatedAtAction(nameof(Create), new { id = created.Id }, created);
        }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Citizen")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Update(int id, [FromForm] UpdateWasteReportForm form)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });

        try
        {
            var updated = await _service.UpdateAsync(id, userId, new UpdateWasteReportDto
            {
                Image = await SaveImageAsync(form.Image),
                Latitude = form.Latitude,
                Longitude = form.Longitude,
                Description = form.Description,
                WasteTypeIds = form.WasteTypeIds
            });
            return Ok(updated);
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/cancel")]
    [Authorize(Roles = "Citizen")]
    public async Task<IActionResult> Cancel(int id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            return Ok(await _service.CancelAsync(id, userId));
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/accept")]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> Accept(int id)
    {
        if (!TryGetUserId(out var enterpriseId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            return Ok(await _service.AcceptAsync(id, enterpriseId));
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/reject")]
    [Authorize(Roles = "Enterprise")]
    public async Task<IActionResult> Reject(int id)
    {
        try
        {
            return Ok(await _service.RejectAsync(id));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }

    private static async Task<string> SaveImageAsync(IFormFile? image)
    {
        if (image == null || image.Length <= 0)
            return string.Empty;

        var ext = Path.GetExtension(image.FileName);
        var fileName = $"{Guid.NewGuid():N}{ext}";
        var root = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "waste-reports");
        Directory.CreateDirectory(root);
        var fullPath = Path.Combine(root, fileName);
        await using var stream = new FileStream(fullPath, FileMode.Create);
        await image.CopyToAsync(stream);
        return $"/uploads/waste-reports/{fileName}";
    }
}
