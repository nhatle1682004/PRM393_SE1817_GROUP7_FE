using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WasteReportService.Application.DTOs.WasteType;
using WasteReportService.Application.Services;

namespace WasteReportService.Api.Controllers;

[ApiController]
[Route("api/waste-types")]
public sealed class WasteTypesController : ControllerBase
{
    private readonly IWasteTypeService _service;

    public WasteTypesController(IWasteTypeService service)
    {
        _service = service;
    }

    [HttpGet]
    [Authorize]
    public async Task<IActionResult> GetAll()
    {
        return Ok(await _service.GetAllAsync(!User.IsInRole("Admin")));
    }

    [HttpGet("{id:int}")]
    [Authorize]
    public async Task<IActionResult> GetById(int id)
    {
        var item = await _service.GetByIdAsync(id);
        return item == null ? NotFound() : Ok(item);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateWasteTypeDto dto)
    {
        try
        {
            var created = await _service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.WasteTypeId }, created);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("exists"))
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateWasteTypeDto dto)
    {
        try
        {
            return Ok(await _service.UpdateAsync(id, dto));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("exists"))
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
    }
}
