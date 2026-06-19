namespace IdentityService.Domain.Entities;

public sealed class User
{
    public int UserId { get; set; }
    public int RoleId { get; set; }
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string? Phone { get; set; }
    public string? Status { get; set; }
    public DateTime? CreatedAt { get; set; }
    public int TotalPoints { get; set; }
    public Role Role { get; set; } = null!;
    public EnterpriseProfile? EnterpriseProfile { get; set; }
    public CollectorProfile? CollectorProfile { get; set; }
}
