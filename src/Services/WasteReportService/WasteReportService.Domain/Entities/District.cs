namespace WasteReportService.Domain.Entities;

public sealed class District
{
    public int DistrictId { get; set; }
    public string Name { get; set; } = null!;
    public string? Code { get; set; }
    public bool IsActive { get; set; }
    public ICollection<WasteReport> WasteReports { get; set; } = new List<WasteReport>();
}
