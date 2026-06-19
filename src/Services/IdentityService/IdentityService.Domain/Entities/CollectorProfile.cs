namespace IdentityService.Domain.Entities;

public sealed class CollectorProfile
{
    public int CollectorId { get; set; }
    public int EnterpriseId { get; set; }
    public bool IsAvailable { get; set; }
    public DateTime? AvailabilityUpdatedAt { get; set; }
    public int WarningCount { get; set; }
    public DateTime? CreatedAt { get; set; }
    public User Collector { get; set; } = null!;
    public EnterpriseProfile? EnterpriseProfile { get; set; }
}
