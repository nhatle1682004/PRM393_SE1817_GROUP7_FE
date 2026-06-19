namespace EngagementService.Domain.Entities;

public sealed class Reward
{
    public int RewardId { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int Points { get; set; }
    public bool Status { get; set; }
    public ICollection<RewardTransaction> RewardTransactions { get; set; } = new List<RewardTransaction>();
}
