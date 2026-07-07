namespace CollectionService.Application.DTOs.Assignment;

public sealed class CollectorDto
{
    public int CollectorId { get; set; }
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public bool IsAvailable { get; set; }
    public int WarningCount { get; set; }
    public DateTime? AvailabilityUpdatedAt { get; set; }
    public DateTime? CreatedAt { get; set; }
    public int CompletedCount { get; set; }
    public int TotalAssignments { get; set; }
}
