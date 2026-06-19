namespace CollectionService.Domain.Entities;

public sealed class CollectionDetail
{
    public int DetailId { get; set; }
    public int ConfirmationId { get; set; }
    public int WasteTypeId { get; set; }
    public double ActualWeight { get; set; }
    public CollectionConfirmation Confirmation { get; set; } = null!;
}
