namespace CollectionService.Domain.Entities;

public sealed class CollectionConfirmation
{
    public int ConfirmationId { get; set; }
    public int AssignmentId { get; set; }
    public string? Note { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public string BeforeImageUrl { get; set; } = null!;
    public string AfterImageUrl { get; set; } = null!;
    public CollectorAssignment Assignment { get; set; } = null!;
    public ICollection<CollectionDetail> CollectionDetails { get; set; } = new List<CollectionDetail>();
}
