namespace Contracts;

public sealed class WasteReportDto
{
    public int ReportId { get; set; }
    public int SubmittedBy { get; set; }
    public string? SubmittedByName { get; set; }
    public List<int> WasteTypeIds { get; set; } = new();
    public List<string> WasteTypeNames { get; set; } = new();
    public string ImageUrl { get; set; } = string.Empty;
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public int? DistrictId { get; set; }
    public string? Description { get; set; }
    public string? Status { get; set; }
    public DateTime? CreatedAt { get; set; }
}

public sealed class WasteTypeDto
{
    public int WasteTypeId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int RewardPoints { get; set; }
    public bool IsActive { get; set; }
}

public sealed class WasteReportStatusUpdateRequest
{
    public string Status { get; set; } = string.Empty;
}

public sealed class WasteDashboardStatsDto
{
    public int TotalReports { get; set; }
    public int PendingReports { get; set; }
    public int AcceptedReports { get; set; }
    public int CollectedReports { get; set; }
    public int CancelledReports { get; set; }
    public int RejectedReports { get; set; }
    public List<StatusCountDto> ReportStatusDistribution { get; set; } = new();
    public List<MonthlyCountDto> ReportsByMonth { get; set; } = new();
    public List<WasteTypeDistributionDto> WasteTypeDistribution { get; set; } = new();
    public List<RecentReportDto> RecentReports { get; set; } = new();
}

public sealed class WasteTypeDistributionDto
{
    public string Name { get; set; } = string.Empty;
    public int Count { get; set; }
}

public sealed class RecentReportDto
{
    public int ReportId { get; set; }
    public string SubmittedByName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Status { get; set; }
    public List<string> WasteTypeNames { get; set; } = new();
    public DateTime? CreatedAt { get; set; }
}
