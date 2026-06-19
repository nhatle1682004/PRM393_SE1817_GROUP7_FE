using EngagementService.Application.DTOs.Feedback;
using EngagementService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EngagementService.Api.Controllers;

[ApiController]
[Route("api/feedbacks")]
[Produces("application/json")]
public sealed class FeedbacksController : ControllerBase
{
    private readonly IFeedbackService _feedbackService;

    public FeedbacksController(IFeedbackService feedbackService)
    {
        _feedbackService = feedbackService;
    }

    public sealed class CreateFeedbackForm
    {
        public int ReportId { get; set; }
        public string Content { get; set; } = null!;
        public IFormFile? Image { get; set; }
    }

    [HttpPost]
    [Authorize]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> CreateFeedback([FromForm] CreateFeedbackForm form)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });
        try
        {
            var imageUrl = await SaveImageAsync(form.Image);
            var result = await _feedbackService.CreateFeedbackAsync(userId, new CreateFeedbackDto
            {
                ReportId = form.ReportId,
                Content = form.Content,
                ImageUrl = string.IsNullOrEmpty(imageUrl) ? null : imageUrl
            });
            return CreatedAtAction(nameof(CreateFeedback), new { id = result.FeedbackId }, result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("report/{reportId:int}")]
    [Authorize]
    public async Task<IActionResult> GetFeedbacksByReport(int reportId) => Ok(await _feedbackService.GetFeedbacksByReportIdAsync(reportId));

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAllFeedbacks() => Ok(await _feedbackService.GetAllFeedbacksAsync());

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetFeedbackDetail(int id)
    {
        try
        {
            return Ok(await _feedbackService.GetFeedbackDetailAsync(id));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/resolve")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> ResolveFeedback(int id, [FromBody] ResolveFeedbackDto dto)
    {
        try
        {
            return Ok(await _feedbackService.ResolveFeedbackAsync(id, dto));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/reject")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> RejectFeedback(int id)
    {
        try
        {
            return Ok(await _feedbackService.RejectFeedbackAsync(id));
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("not found"))
        {
            return NotFound(new { message = ex.Message });
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
        var root = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "feedbacks");
        Directory.CreateDirectory(root);
        var fullPath = Path.Combine(root, fileName);
        await using var stream = new FileStream(fullPath, FileMode.Create);
        await image.CopyToAsync(stream);
        return $"/uploads/feedbacks/{fileName}";
    }
}
