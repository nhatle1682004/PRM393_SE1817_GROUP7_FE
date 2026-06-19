using Contracts;
using EngagementService.Application.Clients;
using EngagementService.Application.DTOs.Feedback;
using EngagementService.Application.Repositories;
using EngagementService.Domain.Entities;

namespace EngagementService.Application.Services;

public sealed class FeedbackService : IFeedbackService
{
    private const int WarnPoints = 1;
    private const int ReassignPoints = 2;
    private const int ComplaintRewardPoints = 10;
    private const int WarningThreshold = 4;
    private readonly IEngagementUnitOfWork _uow;
    private readonly IIdentityClient _identityClient;
    private readonly IWasteReportClient _wasteClient;
    private readonly ICollectionClient _collectionClient;
    private readonly INotificationService _notificationService;
    private readonly IRewardService _rewardService;

    public FeedbackService(
        IEngagementUnitOfWork uow,
        IIdentityClient identityClient,
        IWasteReportClient wasteClient,
        ICollectionClient collectionClient,
        INotificationService notificationService,
        IRewardService rewardService)
    {
        _uow = uow;
        _identityClient = identityClient;
        _wasteClient = wasteClient;
        _collectionClient = collectionClient;
        _notificationService = notificationService;
        _rewardService = rewardService;
    }

    public async Task<FeedbackResponseDto> CreateFeedbackAsync(int userId, CreateFeedbackDto dto)
    {
        var user = await _identityClient.GetUserAsync(userId) ?? throw new InvalidOperationException("User not found");
        _ = await _wasteClient.GetReportAsync(dto.ReportId) ?? throw new InvalidOperationException("Report not found");

        var hasPending = _uow.Feedbacks.Any(f => f.ReportId == dto.ReportId && f.Status == "Pending");
        if (hasPending)
            throw new InvalidOperationException("A complaint for this report is already pending review. Please wait for admin resolution before submitting a new one.");

        var feedback = new Feedback
        {
            UserId = userId,
            ReportId = dto.ReportId,
            Content = dto.Content,
            ImageUrl = dto.ImageUrl,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        await _uow.AddFeedbackAsync(feedback);
        await _uow.SaveChangesAsync();
        return MapToResponse(feedback, user.FullName);
    }

    public async Task<IEnumerable<FeedbackResponseDto>> GetFeedbacksByReportIdAsync(int reportId)
    {
        var feedbacks = _uow.Feedbacks.Where(f => f.ReportId == reportId).OrderByDescending(f => f.CreatedAt).ToList();
        var result = new List<FeedbackResponseDto>();
        foreach (var f in feedbacks)
        {
            var user = await _identityClient.GetUserAsync(f.UserId);
            result.Add(MapToResponse(f, user?.FullName ?? "Unknown"));
        }
        return result;
    }

    public async Task<IEnumerable<FeedbackResponseDto>> GetAllFeedbacksAsync()
    {
        var feedbacks = _uow.Feedbacks.OrderByDescending(f => f.CreatedAt).ToList();
        var result = new List<FeedbackResponseDto>();
        foreach (var f in feedbacks)
        {
            var user = await _identityClient.GetUserAsync(f.UserId);
            result.Add(MapToResponse(f, user?.FullName ?? "Unknown"));
        }
        return result;
    }

    public async Task<FeedbackDetailDto> GetFeedbackDetailAsync(int feedbackId)
    {
        var feedback = _uow.Feedbacks.FirstOrDefault(f => f.FeedbackId == feedbackId) ?? throw new InvalidOperationException("Feedback not found");
        var user = await _identityClient.GetUserAsync(feedback.UserId);
        var report = feedback.ReportId.HasValue ? await _wasteClient.GetReportAsync(feedback.ReportId.Value) : null;
        var detail = new FeedbackDetailDto
        {
            FeedbackId = feedback.FeedbackId,
            UserId = feedback.UserId,
            UserName = user?.FullName ?? "Unknown",
            Content = feedback.Content,
            Status = feedback.Status,
            FeedbackImageUrl = feedback.ImageUrl,
            CreatedAt = feedback.CreatedAt
        };

        if (report != null)
        {
            detail.ReportId = report.ReportId;
            detail.ReportDescription = report.Description;
            detail.ReportStatus = report.Status;
            detail.ReportImageUrl = report.ImageUrl;
            detail.Latitude = report.Latitude;
            detail.Longitude = report.Longitude;
            detail.ReportCreatedAt = report.CreatedAt;
            detail.WasteTypeNames = report.WasteTypeNames;

            var context = await _collectionClient.GetFeedbackContextByReportAsync(report.ReportId);
            if (context != null)
            {
                detail.EnterpriseId = context.EnterpriseId;
                detail.AssignmentId = context.AssignmentId;
                detail.AssignmentStatus = context.AssignmentStatus;
                detail.CollectorId = context.CollectorId;
                detail.AssignedAt = context.AssignedAt;
                detail.StartedAt = context.StartedAt;
                detail.ArrivedAt = context.ArrivedAt;
                detail.BeforeImageUrl = context.BeforeImageUrl;
                detail.ConfirmationId = context.ConfirmationId;
                detail.ConfirmationNote = context.ConfirmationNote;
                detail.ConfirmedAt = context.ConfirmedAt;
                detail.ConfirmationBeforeImageUrl = context.ConfirmationBeforeImageUrl;
                detail.ConfirmationAfterImageUrl = context.ConfirmationAfterImageUrl;

                if (context.EnterpriseId.HasValue)
                    detail.EnterpriseName = (await _identityClient.GetUserAsync(context.EnterpriseId.Value))?.FullName;
                if (context.CollectorId.HasValue)
                {
                    var collector = await _identityClient.GetUserAsync(context.CollectorId.Value);
                    detail.CollectorName = collector?.FullName;
                    detail.CollectorWarningCount = collector?.WarningCount ?? 0;
                }
            }
        }

        return detail;
    }

    public async Task<FeedbackResponseDto> ResolveFeedbackAsync(int feedbackId, ResolveFeedbackDto dto)
    {
        var feedback = _uow.Feedbacks.FirstOrDefault(f => f.FeedbackId == feedbackId) ?? throw new InvalidOperationException("Feedback not found");
        var now = DateTime.UtcNow;
        var citizenId = feedback.UserId;
        var reportId = feedback.ReportId ?? 0;
        var action = dto.Action?.ToLowerInvariant() ?? "warn";
        var report = reportId > 0 ? await _wasteClient.GetReportAsync(reportId) : null;
        var context = reportId > 0 ? await _collectionClient.GetFeedbackContextByReportAsync(reportId) : null;

        if (action == "reassign" && report != null && context?.AssignmentId != null && context.RequestId != null)
        {
            if (report.Status == "Collected")
                await _wasteClient.UpdateReportStatusAsync(report.ReportId, "Accepted");

            await _collectionClient.CancelAssignmentForComplaintAsync(new CancelAssignmentForComplaintRequest
            {
                AssignmentId = context.AssignmentId.Value,
                RequestId = context.RequestId.Value,
                RequestStatus = "Pending"
            });

            await ReverseEarnedPointsAsync(report.ReportId, report.SubmittedBy, now);
        }

        if (context?.CollectorId.HasValue == true)
        {
            var points = action == "reassign" ? ReassignPoints : WarnPoints;
            var collector = await _identityClient.AddCollectorWarningAsync(context.CollectorId.Value, points, dto.AdminNote);
            var autoDeactivated = (collector?.WarningCount ?? 0) >= WarningThreshold;
            var collectorMsg = action == "reassign"
                ? $"You received a warning (+{points} pts, total: {collector?.WarningCount}/{WarningThreshold}) for report #{reportId}. Your assignment has been cancelled due to a valid citizen complaint."
                : $"You received a warning (+{points} pt, total: {collector?.WarningCount}/{WarningThreshold}) for report #{reportId}. Reason: {dto.AdminNote}";
            if (autoDeactivated)
                collectorMsg += " Your account has been DEACTIVATED due to reaching the warning threshold.";
            await _notificationService.CreateAsync(new CreateNotificationRequest { UserId = context.CollectorId.Value, Content = collectorMsg });
        }

        if (action == "reassign" && context?.EnterpriseId.HasValue == true)
        {
            await _notificationService.CreateAsync(new CreateNotificationRequest
            {
                UserId = context.EnterpriseId.Value,
                Content = $"Report #{reportId} needs to be reassigned to a new collector. The previous assignment was cancelled due to a valid citizen complaint."
            });
        }

        await _notificationService.CreateAsync(new CreateNotificationRequest
        {
            UserId = citizenId,
            Content = action == "reassign"
                ? $"Your complaint about report #{reportId} has been resolved. The report will be reassigned to a new collector. You earned +10 reward points!"
                : $"Your complaint about report #{reportId} has been resolved. The collector has been warned. You earned +10 reward points!"
        });

        await _rewardService.CreateTransactionAsync(new CreateRewardTransactionRequest
        {
            UserId = citizenId,
            ReportId = reportId > 0 ? reportId : null,
            Points = ComplaintRewardPoints,
            Type = "Earned",
            Description = $"Reward for valid complaint on report #{reportId}",
            AdjustUserPoints = true,
            CreateNotification = false
        });

        feedback.Status = "Resolved";
        feedback.ResolutionNote = dto.AdminNote;
        _uow.UpdateFeedback(feedback);
        await _uow.SaveChangesAsync();

        var user = await _identityClient.GetUserAsync(feedback.UserId);
        return MapToResponse(feedback, user?.FullName ?? "Unknown");
    }

    public async Task<FeedbackResponseDto> RejectFeedbackAsync(int feedbackId)
    {
        var feedback = _uow.Feedbacks.FirstOrDefault(f => f.FeedbackId == feedbackId) ?? throw new InvalidOperationException("Feedback not found");
        await _notificationService.CreateAsync(new CreateNotificationRequest
        {
            UserId = feedback.UserId,
            Content = $"Your complaint about report #{feedback.ReportId} has been reviewed and was found to be invalid."
        });
        feedback.Status = "Rejected";
        _uow.UpdateFeedback(feedback);
        await _uow.SaveChangesAsync();

        var user = await _identityClient.GetUserAsync(feedback.UserId);
        return MapToResponse(feedback, user?.FullName ?? "Unknown");
    }

    private async Task ReverseEarnedPointsAsync(int reportId, int citizenId, DateTime now)
    {
        var earnedTx = _uow.RewardTransactions.Where(t => t.ReportId == reportId && t.Type == "Earned").ToList();
        if (!earnedTx.Any())
            return;

        var totalEarned = earnedTx.Sum(t => t.Points);
        if (totalEarned <= 0)
            return;

        await _rewardService.CreateTransactionAsync(new CreateRewardTransactionRequest
        {
            UserId = citizenId,
            ReportId = reportId,
            Points = -totalEarned,
            Type = "Reversed",
            Description = $"Points reversed due to complaint on report #{reportId}",
            AdjustUserPoints = true,
            CreateNotification = true,
            NotificationContent = $"Your {totalEarned} reward points for report #{reportId} have been reversed due to a valid complaint. The report will be reassigned."
        });
    }

    private static FeedbackResponseDto MapToResponse(Feedback f, string userName) => new()
    {
        FeedbackId = f.FeedbackId,
        UserId = f.UserId,
        UserName = userName,
        ReportId = f.ReportId,
        Content = f.Content,
        Status = f.Status,
        ImageUrl = f.ImageUrl,
        ResolutionNote = f.ResolutionNote,
        CreatedAt = f.CreatedAt
    };
}
