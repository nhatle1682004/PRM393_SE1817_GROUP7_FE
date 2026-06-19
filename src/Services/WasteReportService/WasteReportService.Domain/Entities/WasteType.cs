namespace WasteReportService.Domain.Entities;

public sealed class WasteType
{
    public int WasteTypeId { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int RewardPoints { get; set; }
    public bool IsActive { get; set; }
    public ICollection<WasteReport> Reports { get; set; } = new List<WasteReport>();
}
