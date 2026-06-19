namespace Contracts;

public sealed class CreateCollectionRequestFromReportRequest
{
    public int ReportId { get; set; }
    public int EnterpriseId { get; set; }
    public string Status { get; set; } = "Pending";
}

public sealed class CollectionRequestDto
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
}

public sealed class CollectionFeedbackContextDto
{
    public int? RequestId { get; set; }
    public int? EnterpriseId { get; set; }
    public int? AssignmentId { get; set; }
    public int? CollectorId { get; set; }
    public string? AssignmentStatus { get; set; }
    public DateTime? AssignedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? ArrivedAt { get; set; }
    public string? BeforeImageUrl { get; set; }
    public int? ConfirmationId { get; set; }
    public string? ConfirmationNote { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public string? ConfirmationBeforeImageUrl { get; set; }
    public string? ConfirmationAfterImageUrl { get; set; }
}

public sealed class CancelAssignmentForComplaintRequest
{
    public int AssignmentId { get; set; }
    public int RequestId { get; set; }
    public string RequestStatus { get; set; } = "Pending";
}

public sealed class CollectionDashboardStatsDto
{
    public int TotalAssignments { get; set; }
    public int CompletedAssignments { get; set; }
    public List<TopCollectorDto> TopCollectors { get; set; } = new();
}
