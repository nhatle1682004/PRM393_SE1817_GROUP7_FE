namespace EngagementService.Application.DTOs.Reward
{
    public class RewardTransactionDto
    {
        public int TransactionId { get; set; }
        public int UserId { get; set; }
        public int? ReportId { get; set; }
        public int Points { get; set; }
        public string Type { get; set; } = null!; // "Earned", "Redeemed"
        public string? Description { get; set; }
        public DateTime? CreatedAt { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? SourceType { get; set; }
        public string? ReferenceId { get; set; }
        public string? FailureReason { get; set; }
        public DateTime? CompletedAt { get; set; }
    }
}
