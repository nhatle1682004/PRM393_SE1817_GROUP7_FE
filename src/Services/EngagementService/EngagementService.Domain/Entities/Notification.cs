namespace EngagementService.Domain.Entities;

public sealed class Notification
{
    public int NotificationId { get; set; }
    public int UserId { get; set; }
    public string? Content { get; set; }
    public bool? IsRead { get; set; }
    public DateTime? CreatedAt { get; set; }
}
