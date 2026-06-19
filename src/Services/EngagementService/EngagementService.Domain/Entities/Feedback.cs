namespace EngagementService.Domain.Entities;

public sealed class Feedback
{
    public int FeedbackId { get; set; }
    public int UserId { get; set; }
    public int? ReportId { get; set; }
    public string Content { get; set; } = null!;
    public string? Status { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime? CreatedAt { get; set; }
    public string? ResolutionNote { get; set; }
}
