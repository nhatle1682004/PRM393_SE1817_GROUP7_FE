namespace Contracts;

public sealed class IdentityDashboardStatsDto
{
    public int TotalUsers { get; set; }
    public int TotalCitizens { get; set; }
    public int TotalEnterprises { get; set; }
    public int TotalCollectors { get; set; }
    public List<MonthlyCountDto> UserRegistrationsByMonth { get; set; } = new();
}

public sealed class MonthlyCountDto
{
    public int Month { get; set; }
    public string MonthName { get; set; } = string.Empty;
    public int Count { get; set; }
}

public sealed class StatusCountDto
{
    public string Status { get; set; } = string.Empty;
    public int Count { get; set; }
}

public sealed class TopCollectorDto
{
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public int CompletedCount { get; set; }
}
