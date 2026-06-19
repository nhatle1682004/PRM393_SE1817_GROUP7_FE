namespace CollectionService.Domain.Entities;

public sealed class CollectionRequest
{
    public int RequestId { get; set; }
    public int ReportId { get; set; }
    public int EnterpriseId { get; set; }
    public string? Status { get; set; }
    public DateTime? CreatedAt { get; set; }
    public string? Note { get; set; }
    public string? IssueReport { get; set; }
    public string? IssueReason { get; set; }
    public string? IssueImageUrl { get; set; }
    public ICollection<CollectorAssignment> CollectorAssignments { get; set; } = new List<CollectorAssignment>();
}
