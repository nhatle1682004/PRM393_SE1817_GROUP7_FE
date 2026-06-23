using CollectionService.Application.Clients;
using CollectionService.Application.DTOs.Collection;
using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using Contracts;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace CollectionService.Application.Services;

public sealed class CollectionService : ICollectionService
{
    private readonly ICollectionUnitOfWork _uow;
    private readonly IWasteReportClient _wasteClient;
    private readonly IEngagementClient _engagementClient;
    private readonly ILogger<CollectionService> _logger;

    public CollectionService(
        ICollectionUnitOfWork uow,
        IWasteReportClient wasteClient,
        IEngagementClient engagementClient,
        ILogger<CollectionService> logger)
    {
        _uow = uow;
        _wasteClient = wasteClient;
        _engagementClient = engagementClient;
        _logger = logger;
    }

    public async Task<DeclineAssignmentResponseDto> DeclineAssignmentAsync(int assignmentId, int collectorId, DeclineAssignmentDto dto)
    {
        var assignment = await GetOwnedAssignmentAsync(assignmentId, collectorId);
        if (!string.Equals(assignment.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only decline assignment when status is 'Assigned'. Cannot decline after starting collection.");
        if (string.IsNullOrWhiteSpace(dto.Reason))
            throw new ArgumentException("Reason is required to decline assignment");

        assignment.Status = "Declined";
        _uow.CollectorAssignments.Update(assignment);
        assignment.Request.Status = "Pending";
        _uow.CollectionRequests.Update(assignment.Request);
        await _uow.SaveChangesAsync();

        return new DeclineAssignmentResponseDto
        {
            AssignmentId = assignment.AssignmentId,
            RequestId = assignment.RequestId,
            Status = assignment.Status,
            Reason = dto.Reason,
            DeclinedAt = DateTime.UtcNow
        };
    }

    public async Task<StartCollectionResponseDto> StartCollectionAsync(int assignmentId, int collectorId)
    {
        var assignment = await GetOwnedAssignmentAsync(assignmentId, collectorId);
        var hasAnotherActiveTrip = await _uow.CollectorAssignments.HasActiveTripByCollectorAsync(collectorId);
        var thisAssignmentAlreadyActive = string.Equals(assignment.Status, "OnTheWay", StringComparison.OrdinalIgnoreCase)
            || string.Equals(assignment.Status, "Arrived", StringComparison.OrdinalIgnoreCase);
        if (hasAnotherActiveTrip && !thisAssignmentAlreadyActive)
            throw new InvalidOperationException("You already have another active collection trip. Complete or resolve it before starting a new one.");

        if (!string.Equals(assignment.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only start collection when status is 'Assigned'");

        var startedAt = DateTime.UtcNow;
        assignment.Status = "OnTheWay";
        assignment.StartedAt = startedAt;
        assignment.Request.Status = "OnTheWay";
        _uow.CollectorAssignments.Update(assignment);
        _uow.CollectionRequests.Update(assignment.Request);
        await _uow.SaveChangesAsync();

        var report = await _wasteClient.GetReportAsync(assignment.Request.ReportId);
        return new StartCollectionResponseDto
        {
            AssignmentId = assignment.AssignmentId,
            RequestId = assignment.RequestId,
            Status = assignment.Status,
            StartedAt = startedAt,
            Latitude = report?.Latitude,
            Longitude = report?.Longitude,
            Address = report?.Description
        };
    }

    public async Task<ArrivedAtLocationResponseDto> ArrivedAtLocationAsync(int assignmentId, int collectorId, ArrivedAtLocationDto dto)
    {
        var assignment = await GetOwnedAssignmentAsync(assignmentId, collectorId);
        if (!string.Equals(assignment.Status, "OnTheWay", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only mark arrival when status is 'OnTheWay'. Please start collection first.");
        if (dto.BeforeImage == null || dto.BeforeImage.Length == 0)
            throw new ArgumentException("Before image is required when marking arrival");

        var beforeImageUrl = await SaveProofImageAsync(dto.BeforeImage, "before");
        var arrivedAt = DateTime.UtcNow;
        assignment.Status = "Arrived";
        assignment.ArrivedAt = arrivedAt;
        assignment.BeforeImageUrl = beforeImageUrl;
        assignment.Request.Status = "Arrived";
        _uow.CollectorAssignments.Update(assignment);
        _uow.CollectionRequests.Update(assignment.Request);
        await _uow.SaveChangesAsync();

        var report = await _wasteClient.GetReportAsync(assignment.Request.ReportId);
        return new ArrivedAtLocationResponseDto
        {
            AssignmentId = assignment.AssignmentId,
            RequestId = assignment.RequestId,
            Status = assignment.Status,
            ArrivedAt = arrivedAt,
            BeforeImageUrl = beforeImageUrl,
            Note = dto.Note,
            Latitude = report?.Latitude,
            Longitude = report?.Longitude
        };
    }

    public async Task<ReportIssueResponseDto> ReportIssueAsync(int assignmentId, int collectorId, ReportIssueDto dto)
    {
        var assignment = await GetOwnedAssignmentAsync(assignmentId, collectorId);
        if (!string.Equals(assignment.Status, "OnTheWay", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(assignment.Status, "Arrived", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only report issue when status is 'OnTheWay' or 'Arrived'.");
        if (string.IsNullOrWhiteSpace(dto.IssueType))
            throw new ArgumentException("Issue type is required");
        if (string.IsNullOrWhiteSpace(dto.Description))
            throw new ArgumentException("Description is required to report issue");

        var validIssueTypes = new[]
        {
            CollectionIssueTypes.WasteNotFound,
            CollectionIssueTypes.WrongAddress,
            CollectionIssueTypes.WasteTypeMismatch,
            CollectionIssueTypes.CitizenUnavailable,
            CollectionIssueTypes.Other
        };
        if (!validIssueTypes.Contains(dto.IssueType, StringComparer.OrdinalIgnoreCase))
            throw new ArgumentException($"Invalid issue type. Valid types: {string.Join(", ", validIssueTypes)}");

        string? proofImageUrl = null;
        if (dto.ProofImage != null && dto.ProofImage.Length > 0)
            proofImageUrl = await SaveIssueProofImageAsync(dto.ProofImage);

        assignment.Status = "ReportedIssue";
        assignment.Request.Status = "Issue";
        assignment.Request.IssueReport = dto.IssueType;
        assignment.Request.IssueReason = dto.Description;
        assignment.Request.IssueImageUrl = proofImageUrl;
        _uow.CollectorAssignments.Update(assignment);
        _uow.CollectionRequests.Update(assignment.Request);
        await _uow.SaveChangesAsync();

        return new ReportIssueResponseDto
        {
            AssignmentId = assignment.AssignmentId,
            RequestId = assignment.RequestId,
            Status = assignment.Status,
            IssueType = dto.IssueType,
            Description = dto.Description,
            ProofImageUrl = proofImageUrl,
            ReportedAt = DateTime.UtcNow
        };
    }

    public async Task<CompleteCollectionResponseDto> CompleteCollectionAsync(int assignmentId, int collectorId, CompleteCollectionDto dto)
    {
        var assignment = await GetOwnedAssignmentAsync(assignmentId, collectorId);
        if (assignment.Request == null)
            throw new InvalidOperationException("Collection request not found");

        if (assignment.CollectionConfirmation != null)
        {
            if (!string.Equals(assignment.Status, "Completed", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Collection confirmation already exists for this assignment");

            var retryableStatuses = new[] { "Completed", "SyncFailed", "RewardFailed" };
            if (!retryableStatuses.Contains(assignment.Request.Status, StringComparer.OrdinalIgnoreCase))
                throw new InvalidOperationException("Collection confirmation already exists for this assignment");

            var retryReport = await _wasteClient.GetReportAsync(assignment.Request.ReportId)
                ?? throw new InvalidOperationException("Waste report not found");
            var retryPointsEarned = await CalculatePointsFromDetailsAsync(assignment.CollectionConfirmation.CollectionDetails);
            await SyncCompletionAsync(assignment, retryReport, retryPointsEarned);
            return BuildCompleteResponse(assignment, assignment.CollectionConfirmation, retryPointsEarned);
        }

        if (!string.Equals(assignment.Status, "Arrived", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only complete collection when status is 'Arrived'. Please mark arrival first.");
        if (string.Equals(assignment.Request.Status, "Completed", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Collection request is already completed");
        if (string.IsNullOrWhiteSpace(assignment.BeforeImageUrl))
            throw new InvalidOperationException("Before image not found. Please mark arrival and upload before photo first.");
        if (dto.AfterImage == null || dto.AfterImage.Length == 0)
            throw new ArgumentException("After image is required to complete collection");
        if (dto.ActualWeights == null || !dto.ActualWeights.Any())
            throw new ArgumentException("ActualWeights is required. Please provide at least one waste type with weight.");

        if (dto.ActualWeights.Any(x => x == null || x.WasteTypeId <= 0 || x.Weight <= 0))
            throw new ArgumentException("All ActualWeights must include WasteTypeId > 0 and Weight > 0.");

        var wasteTypesById = new Dictionary<int, WasteTypeDto>();
        foreach (var wasteTypeId in dto.ActualWeights.Select(x => x.WasteTypeId).Distinct())
        {
            var wasteType = await _wasteClient.GetWasteTypeAsync(wasteTypeId)
                ?? throw new InvalidOperationException($"Waste type not found: {wasteTypeId}");
            if (!wasteType.IsActive)
                throw new InvalidOperationException($"Waste type is inactive: {wasteTypeId}");
            wasteTypesById[wasteTypeId] = wasteType;
        }

        var pointsEarned = dto.ActualWeights.Sum(weightItem =>
            (int)Math.Round(wasteTypesById[weightItem.WasteTypeId].RewardPoints * weightItem.Weight));
        if (pointsEarned <= 0)
            throw new InvalidOperationException("Calculated reward points is 0. Please verify waste type reward points and actual weights.");

        var report = await _wasteClient.GetReportAsync(assignment.Request.ReportId)
            ?? throw new InvalidOperationException("Waste report not found");

        var afterImageUrl = await SaveProofImageAsync(dto.AfterImage, "after");
        var confirmation = new CollectionConfirmation
        {
            AssignmentId = assignmentId,
            BeforeImageUrl = assignment.BeforeImageUrl!,
            AfterImageUrl = afterImageUrl,
            Note = dto.Note,
            ConfirmedAt = DateTime.UtcNow
        };

        await _uow.ExecuteInTransactionAsync(async () =>
        {
            await _uow.AddConfirmationAsync(confirmation);
            foreach (var weightItem in dto.ActualWeights)
            {
                await _uow.AddDetailAsync(new CollectionDetail
                {
                    Confirmation = confirmation,
                    WasteTypeId = weightItem.WasteTypeId,
                    ActualWeight = weightItem.Weight
                });
            }

            assignment.Status = "Completed";
            assignment.Request.Status = "Completed";
            _uow.CollectorAssignments.Update(assignment);
            _uow.CollectionRequests.Update(assignment.Request);
            await _uow.SaveChangesAsync();
        });

        await SyncCompletionAsync(assignment, report, pointsEarned);

        return BuildCompleteResponse(assignment, confirmation, pointsEarned);
    }

    private async Task<int> CalculatePointsFromDetailsAsync(IEnumerable<CollectionDetail> details)
    {
        var pointsEarned = 0;
        foreach (var detail in details)
        {
            var wasteType = await _wasteClient.GetWasteTypeAsync(detail.WasteTypeId)
                ?? throw new InvalidOperationException($"Waste type not found: {detail.WasteTypeId}");
            if (!wasteType.IsActive)
                throw new InvalidOperationException($"Waste type is inactive: {detail.WasteTypeId}");
            pointsEarned += (int)Math.Round(wasteType.RewardPoints * detail.ActualWeight);
        }

        if (pointsEarned <= 0)
            throw new InvalidOperationException("Calculated reward points is 0. Please verify waste type reward points and actual weights.");

        return pointsEarned;
    }

    private async Task SyncCompletionAsync(CollectorAssignment assignment, WasteReportDto report, int pointsEarned)
    {
        try
        {
            await _wasteClient.UpdateReportStatusAsync(assignment.Request.ReportId, "Collected");
        }
        catch (Exception ex)
        {
            await MarkRequestStatusAsync(assignment.Request, "SyncFailed");
            _logger.LogError(ex, "Failed to sync waste report {ReportId} after completing assignment {AssignmentId}", assignment.Request.ReportId, assignment.AssignmentId);
            throw;
        }

        try
        {
            await _engagementClient.CreateRewardTransactionAsync(new CreateRewardTransactionRequest
            {
                UserId = report.SubmittedBy,
                ReportId = report.ReportId,
                Points = pointsEarned,
                Type = "Earned",
                Description = $"Earned points for waste collection (Request #{assignment.RequestId})",
                AdjustUserPoints = true,
                CreateNotification = true,
                NotificationContent = $"Your reported waste has been successfully collected! You have earned {pointsEarned} reward points.",
                SourceType = "Collection",
                ReferenceId = assignment.RequestId.ToString()
            });
        }
        catch (Exception ex)
        {
            await MarkRequestStatusAsync(assignment.Request, "RewardFailed");
            _logger.LogError(ex, "Failed to create reward transaction for assignment {AssignmentId} and request {RequestId}", assignment.AssignmentId, assignment.RequestId);
            throw;
        }

        if (!string.Equals(assignment.Request.Status, "Completed", StringComparison.OrdinalIgnoreCase))
            await MarkRequestStatusAsync(assignment.Request, "Completed");
    }

    private async Task MarkRequestStatusAsync(CollectionRequest request, string status)
    {
        request.Status = status;
        _uow.CollectionRequests.Update(request);
        await _uow.SaveChangesAsync();
    }

    private static CompleteCollectionResponseDto BuildCompleteResponse(CollectorAssignment assignment, CollectionConfirmation confirmation, int pointsEarned) => new()
    {
        AssignmentId = assignment.AssignmentId,
        RequestId = assignment.RequestId,
        ConfirmationId = confirmation.ConfirmationId,
        Status = assignment.Status,
        CompletedAt = confirmation.ConfirmedAt,
        BeforeImageUrl = confirmation.BeforeImageUrl,
        AfterImageUrl = confirmation.AfterImageUrl,
        Note = confirmation.Note,
        EarnedPoints = pointsEarned
    };

    private async Task<CollectorAssignment> GetOwnedAssignmentAsync(int assignmentId, int collectorId)
    {
        var assignment = await _uow.CollectorAssignments.GetByIdWithDetailsAsync(assignmentId)
            ?? throw new InvalidOperationException("Assignment not found");
        if (assignment.AssignedCollector != collectorId)
            throw new UnauthorizedAccessException("You can only access your own assignments");
        return assignment;
    }

    private static async Task<string> SaveProofImageAsync(IFormFile image, string prefix)
    {
        if (image == null || image.Length <= 0)
            throw new ArgumentException("Invalid image file");

        var ext = Path.GetExtension(image.FileName);
        var fileName = $"{prefix}_{Guid.NewGuid():N}{ext}";
        var root = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "collection-proofs");
        Directory.CreateDirectory(root);
        var fullPath = Path.Combine(root, fileName);
        await using var stream = new FileStream(fullPath, FileMode.Create);
        await image.CopyToAsync(stream);
        return $"/uploads/collection-proofs/{fileName}";
    }

    private static async Task<string> SaveIssueProofImageAsync(IFormFile image)
    {
        if (image == null || image.Length <= 0)
            throw new ArgumentException("Invalid image file");

        var ext = Path.GetExtension(image.FileName);
        var fileName = $"{Guid.NewGuid():N}{ext}";
        var root = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "issue-proofs");
        Directory.CreateDirectory(root);
        var fullPath = Path.Combine(root, fileName);
        await using var stream = new FileStream(fullPath, FileMode.Create);
        await image.CopyToAsync(stream);
        return $"/uploads/issue-proofs/{fileName}";
    }
}
