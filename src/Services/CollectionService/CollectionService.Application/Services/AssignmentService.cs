using CollectionService.Application.Clients;
using CollectionService.Application.DTOs.Assignment;
using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using Contracts;

namespace CollectionService.Application.Services;

public sealed class AssignmentService : IAssignmentService
{
    private const int MaxOpenAssignmentsPerCollector = 5;
    private readonly ICollectionUnitOfWork _uow;
    private readonly IIdentityClient _identityClient;
    private readonly IWasteReportClient _wasteClient;
    private readonly IEngagementClient _engagementClient;

    public AssignmentService(ICollectionUnitOfWork uow, IIdentityClient identityClient, IWasteReportClient wasteClient, IEngagementClient engagementClient)
    {
        _uow = uow;
        _identityClient = identityClient;
        _wasteClient = wasteClient;
        _engagementClient = engagementClient;
    }

    public async Task<CollectorAssignmentResponseDto> AssignCollectorAsync(int requestId, int enterpriseId, AssignCollectorDto dto)
    {
        var request = await _uow.CollectionRequests.GetByIdAsync(requestId) ?? throw new InvalidOperationException("Collection request not found");
        if (request.EnterpriseId != enterpriseId)
            throw new UnauthorizedAccessException("You can only assign collectors to your own collection requests");

        var collector = await ValidateCollectorForEnterpriseAsync(dto.CollectorId, enterpriseId);
        var openAssignments = await _uow.CollectorAssignments.CountOpenAssignmentsByCollectorAsync(dto.CollectorId);
        if (openAssignments >= MaxOpenAssignmentsPerCollector)
            throw new InvalidOperationException($"Collector has reached maximum capacity ({MaxOpenAssignmentsPerCollector} open assignments).");

        var existingAssignments = await _uow.CollectorAssignments.GetByRequestIdAsync(requestId);
        if (existingAssignments.Any(x => x.AssignedCollector == dto.CollectorId && x.Status != "Cancelled"))
            throw new InvalidOperationException("This collector is already assigned to this request");
        if (existingAssignments.Any(x => x.AssignedCollector == dto.CollectorId && x.Status == "Cancelled"))
            throw new InvalidOperationException("This collector was previously removed from this request due to a complaint. Please assign a different collector.");

        var assignment = new CollectorAssignment
        {
            RequestId = requestId,
            AssignedCollector = dto.CollectorId,
            AssignedBy = enterpriseId,
            Status = "Assigned",
            AssignedAt = DateTime.UtcNow
        };

        await _uow.CollectorAssignments.AddAsync(assignment);
        request.Status = "Assigned";
        _uow.CollectionRequests.Update(request);
        await _uow.SaveChangesAsync();

        await _engagementClient.CreateNotificationAsync(new CreateNotificationRequest
        {
            UserId = dto.CollectorId,
            Content = $"You have been assigned to collect waste for request #{requestId}."
        });

        var enterprise = await _identityClient.GetUserAsync(enterpriseId);
        return new CollectorAssignmentResponseDto
        {
            AssignmentId = assignment.AssignmentId,
            RequestId = assignment.RequestId,
            AssignedCollector = assignment.AssignedCollector,
            CollectorName = collector.FullName,
            AssignedBy = assignment.AssignedBy,
            AssignedByName = enterprise?.FullName,
            Status = assignment.Status,
            AssignedAt = assignment.AssignedAt
        };
    }

    public async Task<CollectorAssignmentResponseDto> ReassignCollectorAsync(int assignmentId, int enterpriseId, ReassignCollectorDto dto)
    {
        var assignment = await _uow.CollectorAssignments.GetByIdAsync(assignmentId) ?? throw new InvalidOperationException("Assignment not found");
        var request = await _uow.CollectionRequests.GetByIdAsync(assignment.RequestId) ?? throw new InvalidOperationException("Collection request not found");
        if (request.EnterpriseId != enterpriseId)
            throw new UnauthorizedAccessException("You can only reassign collectors for your own collection requests");
        if (!string.Equals(assignment.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only reassign collector when assignment status is 'Assigned'");
        if (assignment.AssignedCollector == dto.NewCollectorId)
            throw new InvalidOperationException("New collector is the same as current collector");

        var newCollector = await ValidateCollectorForEnterpriseAsync(dto.NewCollectorId, enterpriseId);
        assignment.AssignedCollector = dto.NewCollectorId;
        assignment.AssignedBy = enterpriseId;
        assignment.AssignedAt = DateTime.UtcNow;
        _uow.CollectorAssignments.Update(assignment);
        await _uow.SaveChangesAsync();

        await _engagementClient.CreateNotificationAsync(new CreateNotificationRequest
        {
            UserId = dto.NewCollectorId,
            Content = $"You have been assigned to collect waste for request #{assignment.RequestId}."
        });

        var enterprise = await _identityClient.GetUserAsync(enterpriseId);
        return new CollectorAssignmentResponseDto
        {
            AssignmentId = assignment.AssignmentId,
            RequestId = assignment.RequestId,
            AssignedCollector = assignment.AssignedCollector,
            CollectorName = newCollector.FullName,
            AssignedBy = assignment.AssignedBy,
            AssignedByName = enterprise?.FullName,
            Status = assignment.Status,
            AssignedAt = assignment.AssignedAt
        };
    }

    public async Task<CancelAssignmentResponseDto> CancelAssignmentAsync(int assignmentId, int userId, string userRole)
    {
        var assignment = await _uow.CollectorAssignments.GetByIdAsync(assignmentId) ?? throw new InvalidOperationException("Assignment not found");
        if (!string.Equals(assignment.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Can only cancel assignment when status is 'Assigned'");

        if (string.Equals(userRole, "Enterprise", StringComparison.OrdinalIgnoreCase))
        {
            var request = await _uow.CollectionRequests.GetByIdAsync(assignment.RequestId);
            if (request == null || request.EnterpriseId != userId)
                throw new UnauthorizedAccessException("You can only cancel assignments for your own collection requests");
        }
        else if (string.Equals(userRole, "Collector", StringComparison.OrdinalIgnoreCase))
        {
            if (assignment.AssignedCollector != userId)
                throw new UnauthorizedAccessException("You can only cancel assignments assigned to you");
        }
        else
        {
            throw new UnauthorizedAccessException("Only Enterprise or Collector can cancel assignments");
        }

        assignment.Status = "Cancelled";
        _uow.CollectorAssignments.Update(assignment);
        var collectionRequest = await _uow.CollectionRequests.GetByIdAsync(assignment.RequestId);
        if (collectionRequest != null)
        {
            collectionRequest.Status = "Pending";
            _uow.CollectionRequests.Update(collectionRequest);
        }
        await _uow.SaveChangesAsync();

        return new CancelAssignmentResponseDto { AssignmentId = assignment.AssignmentId, RequestId = assignment.RequestId, Status = assignment.Status };
    }

    public async Task<IEnumerable<AssignmentDto>> GetAllAssignmentsByEnterpriseAsync(int enterpriseId)
    {
        var assignments = await _uow.CollectorAssignments.GetByEnterpriseIdAsync(enterpriseId);
        var result = new List<AssignmentDto>();
        foreach (var a in assignments)
            result.Add(await MapAssignmentDtoAsync(a));
        return result;
    }

    public async Task<IEnumerable<AssignmentHistoryDto>> GetAssignmentHistoryByRequestAsync(int requestId, int enterpriseId)
    {
        var request = await _uow.CollectionRequests.GetByIdAsync(requestId) ?? throw new InvalidOperationException("Collection request not found");
        if (request.EnterpriseId != enterpriseId)
            throw new UnauthorizedAccessException("You can only view assignments for your own collection requests");

        var assignments = await _uow.CollectorAssignments.GetByRequestIdAsync(requestId);
        var result = new List<AssignmentHistoryDto>();
        foreach (var a in assignments)
        {
            var collector = await _identityClient.GetUserAsync(a.AssignedCollector);
            var assignedBy = await _identityClient.GetUserAsync(a.AssignedBy);
            result.Add(new AssignmentHistoryDto
            {
                AssignmentId = a.AssignmentId,
                AssignedCollector = a.AssignedCollector,
                CollectorName = collector?.FullName,
                CollectorPhone = collector?.Phone,
                AssignedBy = a.AssignedBy,
                AssignedByName = assignedBy?.FullName,
                Status = a.Status,
                AssignedAt = a.AssignedAt
            });
        }
        return result;
    }

    public async Task<IEnumerable<MyAssignmentDto>> GetMyAssignmentsAsync(int collectorId)
    {
        var assignments = await _uow.CollectorAssignments.GetByCollectorIdAsync(collectorId);
        var result = new List<MyAssignmentDto>();
        foreach (var a in assignments)
            result.Add(await MapMyAssignmentDtoAsync(a));
        return result;
    }

    public async Task<MyAssignmentDto?> GetAssignmentDetailAsync(int assignmentId, int collectorId)
    {
        var assignment = await _uow.CollectorAssignments.GetByIdWithDetailsAsync(assignmentId);
        if (assignment == null)
            return null;
        if (assignment.AssignedCollector != collectorId)
            throw new UnauthorizedAccessException("You can only view your own assignments");
        return await MapMyAssignmentDtoAsync(assignment);
    }

    private async Task<CollectorProfileDto> ValidateCollectorForEnterpriseAsync(int collectorId, int enterpriseId)
    {
        var collector = await _identityClient.GetCollectorAsync(collectorId);
        if (collector == null)
            throw new ArgumentException("Collector not found");
        if (!string.Equals(collector.Status, "Active", StringComparison.OrdinalIgnoreCase))
            throw new ArgumentException("Selected user is not active");
        if (collector.EnterpriseId != enterpriseId)
            throw new UnauthorizedAccessException("You can only assign collectors from your own enterprise");
        if (!collector.IsAvailable)
            throw new InvalidOperationException("Collector is currently offline and cannot receive new assignments");
        return collector;
    }

    private async Task<AssignmentDto> MapAssignmentDtoAsync(CollectorAssignment a)
    {
        var collector = await _identityClient.GetUserAsync(a.AssignedCollector);
        var assignedBy = await _identityClient.GetUserAsync(a.AssignedBy);
        var report = await _wasteClient.GetReportAsync(a.Request.ReportId);
        var citizen = report == null ? null : await _identityClient.GetUserAsync(report.SubmittedBy);
        return new AssignmentDto
        {
            AssignmentId = a.AssignmentId,
            RequestId = a.RequestId,
            AssignedCollector = a.AssignedCollector,
            CollectorName = collector?.FullName,
            CollectorEmail = collector?.Email,
            CollectorPhone = collector?.Phone,
            AssignedBy = a.AssignedBy,
            AssignedByName = assignedBy?.FullName,
            Status = a.Status,
            AssignedAt = a.AssignedAt,
            StartedAt = a.StartedAt,
            ArrivedAt = a.ArrivedAt,
            CompletedAt = a.CollectionConfirmation?.ConfirmedAt,
            BeforeImageUrl = a.BeforeImageUrl,
            RequestStatus = a.Request.Status,
            RequestCreatedAt = a.Request.CreatedAt,
            ReportId = a.Request.ReportId,
            WasteTypeName = report?.WasteTypeNames != null ? string.Join(", ", report.WasteTypeNames) : string.Empty,
            ReportImageUrl = report?.ImageUrl,
            Latitude = report?.Latitude,
            Longitude = report?.Longitude,
            ReportDescription = report?.Description,
            ReportStatus = report?.Status,
            CitizenId = report?.SubmittedBy ?? 0,
            CitizenName = citizen?.FullName
        };
    }

    private async Task<MyAssignmentDto> MapMyAssignmentDtoAsync(CollectorAssignment a)
    {
        var enterprise = await _identityClient.GetUserAsync(a.Request.EnterpriseId);
        var report = await _wasteClient.GetReportAsync(a.Request.ReportId);
        var citizen = report == null ? null : await _identityClient.GetUserAsync(report.SubmittedBy);
        var details = a.CollectionConfirmation?.CollectionDetails ?? new List<CollectionDetail>();
        var summaryParts = new List<string>();
        foreach (var d in details)
        {
            var wt = await _wasteClient.GetWasteTypeAsync(d.WasteTypeId);
            summaryParts.Add($"{wt?.Name ?? $"Type {d.WasteTypeId}"}: {d.ActualWeight:0.##} kg");
        }

        return new MyAssignmentDto
        {
            AssignmentId = a.AssignmentId,
            RequestId = a.RequestId,
            Status = a.Status ?? string.Empty,
            AssignedAt = a.AssignedAt,
            StartedAt = a.StartedAt,
            ArrivedAt = a.ArrivedAt,
            CompletedAt = a.CollectionConfirmation?.ConfirmedAt,
            BeforeImageUrl = a.BeforeImageUrl,
            AfterImageUrl = a.CollectionConfirmation?.AfterImageUrl,
            CompletionNote = a.CollectionConfirmation?.Note,
            EnterpriseId = a.Request.EnterpriseId,
            EnterpriseName = enterprise?.FullName,
            EnterprisePhone = enterprise?.Phone,
            ReportId = a.Request.ReportId,
            ReportImageUrl = report?.ImageUrl,
            WasteTypeIds = report?.WasteTypeIds ?? new List<int>(),
            WasteTypeName = report?.WasteTypeNames != null ? string.Join(", ", report.WasteTypeNames) : string.Empty,
            WasteItems = report?.WasteTypeIds.Zip(report.WasteTypeNames, (id, name) => new EstimatedWasteItemDto { WasteTypeId = id, WasteTypeName = name }).ToList() ?? new List<EstimatedWasteItemDto>(),
            Latitude = report == null ? 0 : (double)report.Latitude,
            Longitude = report == null ? 0 : (double)report.Longitude,
            Description = report?.Description,
            ReportStatus = report?.Status,
            ReportCreatedAt = report?.CreatedAt,
            CitizenName = citizen?.FullName,
            CitizenPhone = citizen?.Phone,
            Note = a.Request.Note,
            IssueReport = a.Request.IssueReport,
            IssueReason = a.Request.IssueReason,
            IssueImageUrl = a.Request.IssueImageUrl,
            TotalCollectedWeight = (decimal)details.Sum(d => d.ActualWeight),
            CollectedWasteSummary = summaryParts.Any() ? string.Join(", ", summaryParts) : null
        };
    }
}
