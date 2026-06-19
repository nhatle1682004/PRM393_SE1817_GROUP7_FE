namespace Contracts;

public sealed class NotificationDto
{
    public int NotificationId { get; set; }
    public int UserId { get; set; }
    public string? Content { get; set; }
    public bool IsRead { get; set; }
    public DateTime? CreatedAt { get; set; }
}

public sealed class CreateNotificationRequest
{
    public int UserId { get; set; }
    public string Content { get; set; } = string.Empty;
}

public sealed class CreateRewardTransactionRequest
{
    public int UserId { get; set; }
    public int? RewardId { get; set; }
    public int? ReportId { get; set; }
    public int Points { get; set; }
    public string Type { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool AdjustUserPoints { get; set; } = true;
    public bool CreateNotification { get; set; } = true;
    public string? NotificationContent { get; set; }
}

public sealed class RewardTransactionDto
{
    public int TransactionId { get; set; }
    public int UserId { get; set; }
    public int? RewardId { get; set; }
    public int? ReportId { get; set; }
    public int Points { get; set; }
    public string Type { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? CreatedAt { get; set; }
}
