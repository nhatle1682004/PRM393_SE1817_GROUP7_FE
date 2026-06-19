namespace Contracts;

public sealed class UserDto
{
    public int UserId { get; set; }
    public int RoleId { get; set; }
    public string RoleName { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string Status { get; set; } = string.Empty;
    public int TotalPoints { get; set; }
    public int? ManagedDistrictId { get; set; }
    public int? EnterpriseId { get; set; }
    public bool? IsAvailable { get; set; }
    public int? WarningCount { get; set; }
}

public sealed class EnterpriseProfileDto
{
    public int EnterpriseId { get; set; }
    public int ManagedDistrictId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
}

public sealed class CollectorProfileDto
{
    public int CollectorId { get; set; }
    public int EnterpriseId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public bool IsAvailable { get; set; }
    public int WarningCount { get; set; }
    public string Status { get; set; } = string.Empty;
}

public sealed class PointAdjustmentRequest
{
    public int Points { get; set; }
    public string Reason { get; set; } = string.Empty;
}

public sealed class WarningAdjustmentRequest
{
    public int Warnings { get; set; } = 1;
    public string Reason { get; set; } = string.Empty;
}
