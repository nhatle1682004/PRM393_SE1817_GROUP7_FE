namespace IdentityService.Domain.Entities;

public sealed class EnterpriseProfile
{
    public int EnterpriseId { get; set; }
    public int ManagedDistrictId { get; set; }
    public DateTime? CreatedAt { get; set; }
    public User Enterprise { get; set; } = null!;
    public ICollection<CollectorProfile> CollectorProfiles { get; set; } = new List<CollectorProfile>();
}
