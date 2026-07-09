using Contracts;
using EngagementService.Application.Clients;
using EngagementService.Application.DTOs.Feedback;
using EngagementService.Application.Repositories;
using EngagementService.Domain.Entities;
using Microsoft.Extensions.Logging;

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
    private readonly ILogger<FeedbackService> _logger;

    public FeedbackService(
        IEngagementUnitOfWork uow,
        IIdentityClient identityClient,
        IWasteReportClient wasteClient,
        ICollectionClient collectionClient,
        INotificationService notificationService,
        IRewardService rewardService,
        ILogger<FeedbackService> logger)
    {
        _uow = uow;
        _identityClient = identityClient;
        _wasteClient = wasteClient;
        _collectionClient = collectionClient;
        _notificationService = notificationService;
        _rewardService = rewardService;
        _logger = logger;
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

    public async Task<IEnumerable<FeedbackResponseDto>> GetAllFeedbacksAsync(int? districtId = null, int? requesterId = null)
    {
        IEnumerable<Feedback> feedbacks;

        if (districtId.HasValue)
        {
            // For Enterprise: Get reports from their district, then filter feedbacks
            var reportsInDistrict = await _wasteClient.GetReportsByDistrictAsync(districtId.Value);
            var reportIds = reportsInDistrict.Select(r => r.ReportId).ToHashSet();

            feedbacks = _uow.Feedbacks
                .Where(f => f.ReportId.HasValue && reportIds.Contains(f.ReportId.Value))
                .OrderByDescending(f => f.CreatedAt)
                .ToList();
        }
        else
        {
            feedbacks = _uow.Feedbacks.OrderByDescending(f => f.CreatedAt).ToList();
        }

        var result = new List<FeedbackResponseDto>();
        foreach (var f in feedbacks)
        {
            var user = await _identityClient.GetUserAsync(f.UserId);
            result.Add(MapToResponse(f, user?.FullName ?? "Unknown"));
        }
        return result;
    }

    public async Task<FeedbackDetailDto> GetFeedbackDetailAsync(int feedbackId, int? requesterId = null)
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
            ResolutionNote = feedback.ResolutionNote,
            ResolveFailureReason = feedback.ResolveFailureReason,
            CreatedAt = feedback.CreatedAt,
            ResolvedAt = feedback.ResolvedAt
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

    public async Task<FeedbackResponseDto> ResolveFeedbackAsync(int feedbackId, ResolveFeedbackDto dto, int? requesterId = null)
    {
        var feedback = _uow.Feedbacks.FirstOrDefault(f => f.FeedbackId == feedbackId) ?? throw new InvalidOperationException("Feedback not found");
        if (!string.Equals(feedback.Status, "Pending", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(feedback.Status, "ResolveFailed", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Only Pending or ResolveFailed feedback can be resolved");

        var citizenId = feedback.UserId;
        var reportId = feedback.ReportId ?? 0;
        var action = dto.Action?.ToLowerInvariant() ?? "warn";
        if (action != "warn" && action != "reassign")
            throw new ArgumentException("Action must be 'warn' or 'reassign'");

        var report = reportId > 0 ? await _wasteClient.GetReportAsync(reportId) : null;
        var context = reportId > 0 ? await _collectionClient.GetFeedbackContextByReportAsync(reportId) : null;

        await _uow.ExecuteInTransactionAsync(async () =>
        {
            feedback.Status = "Resolving";
            feedback.ResolveFailureReason = null;
            feedback.ResolutionNote = dto.AdminNote;
            _uow.UpdateFeedback(feedback);
            await _uow.SaveChangesAsync();
        });

        try
        {
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

                await ReverseEarnedPointsAsync(report.ReportId, report.SubmittedBy);
            }

            if (context?.CollectorId.HasValue == true)
            {
                var points = action == "reassign" ? ReassignPoints : WarnPoints;
                var collector = await _identityClient.AddCollectorWarningAsync(context.CollectorId.Value, points, dto.AdminNote);
                var autoDeactivated = (collector?.WarningCount ?? 0) >= WarningThreshold;
                var collectorMsg = action == "reassign"
                    ? $"Bạn nhận được một cảnh báo (+{points} điểm, tổng: {collector?.WarningCount}/{WarningThreshold}) cho báo cáo #{reportId}. Phân công của bạn đã bị hủy do phản hồi hợp lệ từ người dân."
                    : $"Bạn nhận được một cảnh báo (+{points} điểm, tổng: {collector?.WarningCount}/{WarningThreshold}) cho báo cáo #{reportId}. Lý do: {dto.AdminNote}";
                if (autoDeactivated)
                    collectorMsg += " Tài khoản của bạn đã bị VÔ HIỆU HÓA do đạt ngưỡng cảnh báo.";
                await CreateNotificationBestEffortAsync(context.CollectorId.Value, collectorMsg);
            }

            if (action == "reassign" && context?.EnterpriseId.HasValue == true)
            {
                await CreateNotificationBestEffortAsync(
                    context.EnterpriseId.Value,
                    $"Báo cáo #{reportId} cần được phân công lại cho nhân viên mới. Phân công trước đó đã bị hủy do phản hồi hợp lệ từ người dân.");
            }

            await CreateNotificationBestEffortAsync(
                citizenId,
                action == "reassign"
                    ? $"Phản hồi của bạn về báo cáo #{reportId} đã được giải quyết. Báo cáo sẽ được phân công lại cho nhân viên khác. Bạn nhận được +10 điểm thưởng!"
                    : $"Phản hồi của bạn về báo cáo #{reportId} đã được giải quyết. Nhân viên đã bị cảnh cáo. Bạn nhận được +10 điểm thưởng!");

            await _rewardService.CreateTransactionAsync(new CreateRewardTransactionRequest
            {
                UserId = citizenId,
                ReportId = reportId > 0 ? reportId : null,
                Points = ComplaintRewardPoints,
                Type = "Earned",
                Description = $"Thưởng cho phản hồi hợp lệ về báo cáo #{reportId}",
                AdjustUserPoints = true,
                CreateNotification = false,
                SourceType = "ComplaintReward",
                ReferenceId = feedbackId.ToString()
            });

            await _uow.ExecuteInTransactionAsync(async () =>
            {
                feedback.Status = "Resolved";
                feedback.ResolutionNote = dto.AdminNote;
                feedback.ResolveFailureReason = null;
                feedback.ResolvedAt = DateTime.UtcNow;
                _uow.UpdateFeedback(feedback);
                await _uow.SaveChangesAsync();
            });
        }
        catch (Exception ex)
        {
            await _uow.ExecuteInTransactionAsync(async () =>
            {
                feedback.Status = "ResolveFailed";
                feedback.ResolveFailureReason = ex.Message;
                feedback.ResolutionNote = dto.AdminNote;
                _uow.UpdateFeedback(feedback);
                await _uow.SaveChangesAsync();
            });
            _logger.LogError(ex, "Failed to resolve feedback {FeedbackId}", feedbackId);
            throw;
        }

        var resolvedUser = await _identityClient.GetUserAsync(feedback.UserId);
        return MapToResponse(feedback, resolvedUser?.FullName ?? "Unknown");
    }

    public async Task<FeedbackResponseDto> RejectFeedbackAsync(int feedbackId, int? requesterId = null)
    {
        var feedback = _uow.Feedbacks.FirstOrDefault(f => f.FeedbackId == feedbackId) ?? throw new InvalidOperationException("Feedback not found");

        await _notificationService.CreateAsync(new CreateNotificationRequest
        {
            UserId = feedback.UserId,
            Content = $"Phản hồi của bạn về báo cáo #{feedback.ReportId} đã được xem xét và không được chấp nhận."
        });
        feedback.Status = "Rejected";
        _uow.UpdateFeedback(feedback);
        await _uow.SaveChangesAsync();

        var user = await _identityClient.GetUserAsync(feedback.UserId);
        return MapToResponse(feedback, user?.FullName ?? "Unknown");
    }

    private async Task ReverseEarnedPointsAsync(int reportId, int citizenId)
    {
        var earnedTx = _uow.RewardTransactions
            .Where(t => t.ReportId == reportId
                && t.Type == "Earned"
                && (t.SourceType == "Collection" || t.SourceType == null))
            .ToList();
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
            Description = $"Hoàn tác điểm do có phản hồi về báo cáo #{reportId}",
            AdjustUserPoints = true,
            CreateNotification = true,
            NotificationContent = $"Số điểm thưởng {totalEarned} của báo cáo #{reportId} đã bị thu hồi do có phản hồi hợp lệ. Báo cáo sẽ được phân công lại.",
            SourceType = "ComplaintReversal",
            ReferenceId = reportId.ToString()
        });
    }

    private async Task CreateNotificationBestEffortAsync(int userId, string content)
    {
        try
        {
            await _notificationService.CreateAsync(new CreateNotificationRequest { UserId = userId, Content = content });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create feedback notification for user {UserId}", userId);
        }
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
        ResolveFailureReason = f.ResolveFailureReason,
        CreatedAt = f.CreatedAt,
        ResolvedAt = f.ResolvedAt
    };
}
