namespace EngagementService.Domain.Entities;

public sealed class RewardTransaction
{
    public int TransactionId { get; set; }
    public int UserId { get; set; }
    public int? RewardId { get; set; }
    public DateTime? CreatedAt { get; set; }
    public string Type { get; set; } = null!;
    public int Points { get; set; }
    public string? Description { get; set; }
    public int? ReportId { get; set; }
    public string Status { get; set; } = "Pending";
    public string? SourceType { get; set; }
    public string? ReferenceId { get; set; }
    public string? FailureReason { get; set; }
    public DateTime? CompletedAt { get; set; }
    public Reward? Reward { get; set; }
}
