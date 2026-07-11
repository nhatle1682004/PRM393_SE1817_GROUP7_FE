namespace EngagementService.Application.DTOs.Reward;

public sealed class UpdateRewardDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Points { get; set; }
    public bool Status { get; set; } = true;
}
