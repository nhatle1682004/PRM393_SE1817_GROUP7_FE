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
    public Reward? Reward { get; set; }
}
