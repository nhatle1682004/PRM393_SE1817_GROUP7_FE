namespace SharedKernel.Constants;

public static class ReportStatuses
{
    public const string Pending = "Pending";
    public const string Accepted = "Accepted";
    public const string Rejected = "Rejected";
    public const string Cancelled = "Cancelled";
    public const string Collected = "Collected";
}

public static class CollectionRequestStatuses
{
    public const string Pending = "Pending";
    public const string Assigned = "Assigned";
    public const string OnTheWay = "OnTheWay";
    public const string Arrived = "Arrived";
    public const string Issue = "Issue";
    public const string Completed = "Completed";
}

public static class AssignmentStatuses
{
    public const string Assigned = "Assigned";
    public const string OnTheWay = "OnTheWay";
    public const string Arrived = "Arrived";
    public const string ReportedIssue = "ReportedIssue";
    public const string Completed = "Completed";
    public const string Declined = "Declined";
    public const string Cancelled = "Cancelled";
}

public static class FeedbackStatuses
{
    public const string Pending = "Pending";
    public const string Resolved = "Resolved";
    public const string Rejected = "Rejected";
}
