namespace CollectionService.Domain.Entities;

public sealed class CollectorAssignment
{
    public int AssignmentId { get; set; }
    public int RequestId { get; set; }
    public int AssignedCollector { get; set; }
    public int AssignedBy { get; set; }
    public string? Status { get; set; }
    public DateTime? AssignedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? ArrivedAt { get; set; }
    public string? BeforeImageUrl { get; set; }
    public CollectionRequest Request { get; set; } = null!;
    public CollectionConfirmation? CollectionConfirmation { get; set; }
}
