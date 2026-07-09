using CollectionService.Application.Clients;
using CollectionService.Application.DTOs.Assignment;
using CollectionService.Application.DTOs.CollectionRequest;
using CollectionService.Application.Repositories;
using CollectionService.Domain.Entities;
using Contracts;
using PublicCollectionRequestDto = CollectionService.Application.DTOs.CollectionRequest.CollectionRequestDto;
using CollectorDtoLocal = CollectionService.Application.DTOs.Assignment.CollectorDto;

namespace CollectionService.Application.Services;

public sealed class CollectionRequestService : ICollectionRequestService
{
    private static readonly string[] VisibleAssignmentStatuses = { "Assigned", "OnTheWay", "Arrived", "ReportedIssue", "Failed" };
    private readonly ICollectionUnitOfWork _uow;
    private readonly IIdentityClient _identityClient;
    private readonly IWasteReportClient _wasteClient;

    public CollectionRequestService(ICollectionUnitOfWork uow, IIdentityClient identityClient, IWasteReportClient wasteClient)
    {
        _uow = uow;
        _identityClient = identityClient;
        _wasteClient = wasteClient;
    }

    public async Task<IEnumerable<PublicCollectionRequestDto>> GetCollectionRequestsByEnterpriseAsync(int enterpriseId)
    {
        var requests = await _uow.CollectionRequests.GetByEnterpriseIdAsync(enterpriseId);
        var result = new List<PublicCollectionRequestDto>();
        foreach (var request in requests)
            result.Add(await MapListDtoAsync(request));
        return result;
    }

    public async Task<CollectionRequestDetailDto?> GetCollectionRequestDetailAsync(int requestId, int enterpriseId)
    {
        var request = await _uow.CollectionRequests.GetByIdAsync(requestId);
        if (request == null)
            return null;
        if (request.EnterpriseId != enterpriseId)
            throw new UnauthorizedAccessException("You can only view your own collection requests");

        return await MapDetailDtoAsync(request);
    }

    public async Task<IEnumerable<PublicCollectionRequestDto>> GetAllCollectionRequestsAsync()
    {
        var requests = await _uow.CollectionRequests.GetAllAsync();
        var result = new List<PublicCollectionRequestDto>();
        foreach (var request in requests)
            result.Add(await MapListDtoAsync(request));
        return result;
    }

    public async Task<IEnumerable<AssignmentHistoryDto>> GetAssignmentHistoryByRequestAsync(int requestId, int enterpriseId)
    {
        var request = await _uow.CollectionRequests.GetByIdAsync(requestId) ?? throw new InvalidOperationException("Collection request not found");
        if (request.EnterpriseId != enterpriseId)
            throw new UnauthorizedAccessException("You can only view assignments for your own collection requests");

        var assignments = await _uow.CollectorAssignments.GetByRequestIdAsync(requestId);
        return await MapHistoryAsync(assignments);
    }

    public async Task<Contracts.CollectionRequestDto> CreateFromReportAsync(CreateCollectionRequestFromReportRequest request)
    {
        var existing = await _uow.CollectionRequests.GetByReportIdAsync(request.ReportId);
        if (existing != null)
            return ToContract(existing);

        var entity = new CollectionRequest
        {
            ReportId = request.ReportId,
            EnterpriseId = request.EnterpriseId,
            Status = request.Status,
            CreatedAt = DateTime.UtcNow
        };

        await _uow.CollectionRequests.AddAsync(entity);
        await _uow.SaveChangesAsync();
        return ToContract(entity);
    }

    public async Task DeleteByReportIdAsync(int reportId)
    {
        var request = await _uow.CollectionRequests.GetByReportIdAsync(reportId);
        if (request != null)
        {
            _uow.CollectionRequests.Delete(request);
            await _uow.SaveChangesAsync();
        }
    }

    public async Task<CollectionFeedbackContextDto?> GetFeedbackContextByReportAsync(int reportId)
    {
        var request = await _uow.CollectionRequests.GetByReportIdAsync(reportId);
        if (request == null)
            return null;

        var assignment = request.CollectorAssignments.OrderByDescending(a => a.AssignedAt).FirstOrDefault();
        var confirmation = assignment?.CollectionConfirmation;
        return new CollectionFeedbackContextDto
        {
            RequestId = request.RequestId,
            EnterpriseId = request.EnterpriseId,
            AssignmentId = assignment?.AssignmentId,
            CollectorId = assignment?.AssignedCollector,
            AssignmentStatus = assignment?.Status,
            AssignedAt = assignment?.AssignedAt,
            StartedAt = assignment?.StartedAt,
            ArrivedAt = assignment?.ArrivedAt,
            BeforeImageUrl = assignment?.BeforeImageUrl,
            ConfirmationId = confirmation?.ConfirmationId,
            ConfirmationNote = confirmation?.Note,
            ConfirmedAt = confirmation?.ConfirmedAt,
            ConfirmationBeforeImageUrl = confirmation?.BeforeImageUrl,
            ConfirmationAfterImageUrl = confirmation?.AfterImageUrl
        };
    }

    public async Task CancelAssignmentForComplaintAsync(CancelAssignmentForComplaintRequest request)
    {
        var assignment = await _uow.CollectorAssignments.GetByIdAsync(request.AssignmentId) ?? throw new InvalidOperationException("Assignment not found");
        var collectionRequest = await _uow.CollectionRequests.GetByIdAsync(request.RequestId) ?? throw new InvalidOperationException("Collection request not found");
        assignment.Status = "Cancelled";
        collectionRequest.Status = request.RequestStatus;
        _uow.CollectorAssignments.Update(assignment);
        _uow.CollectionRequests.Update(collectionRequest);
        await _uow.SaveChangesAsync();
    }

    public async Task<CollectionDashboardStatsDto> GetDashboardStatsAsync()
    {
        var requests = await _uow.CollectionRequests.GetAllAsync();
        var allAssignments = requests.SelectMany(r => r.CollectorAssignments).ToList();
        var completed = allAssignments.Where(a => a.Status == "Completed").ToList();
        var top = completed.GroupBy(a => a.AssignedCollector)
            .OrderByDescending(g => g.Count())
            .Take(5)
            .Select(g => new TopCollectorDto { UserId = g.Key, FullName = string.Empty, CompletedCount = g.Count() })
            .ToList();

        foreach (var item in top)
        {
            var user = await _identityClient.GetUserAsync(item.UserId);
            item.FullName = user?.FullName ?? "Unknown";
        }

        return new CollectionDashboardStatsDto
        {
            TotalAssignments = allAssignments.Count,
            CompletedAssignments = completed.Count,
            TopCollectors = top
        };
    }

    public async Task<IEnumerable<PublicCollectionRequestDto>> GetUnassignedRequestsAsync(int enterpriseId)
    {
        var requests = await _uow.CollectionRequests.GetByEnterpriseIdAsync(enterpriseId);
        var unassigned = requests.Where(r =>
            r.Status == "Pending" &&
            (r.CollectorAssignments == null || !r.CollectorAssignments.Any(a => a.Status != "Cancelled"))
        );

        var result = new List<PublicCollectionRequestDto>();
        foreach (var request in unassigned)
            result.Add(await MapListDtoAsync(request));
        return result;
    }

    public async Task<IEnumerable<CollectorDtoLocal>> GetCollectorsByEnterpriseAsync(int enterpriseId)
    {
        var collectors = await _identityClient.GetCollectorsByEnterpriseAsync(enterpriseId);
        var result = new List<CollectorDtoLocal>();

        foreach (var c in collectors)
        {
            var allAssignments = await _uow.CollectorAssignments.GetByCollectorIdAsync(c.CollectorId);
            var completedCount = allAssignments.Count(a => a.Status == "Completed");
            result.Add(new CollectorDtoLocal
            {
                CollectorId = c.CollectorId,
                FullName = c.FullName,
                Email = c.Email,
                Phone = c.Phone,
                IsAvailable = c.IsAvailable,
                WarningCount = c.WarningCount,
                CompletedCount = completedCount,
                TotalAssignments = allAssignments.Count()
            });
        }

        return result;
    }

    public async Task<CollectorDtoLocal?> GetCollectorDetailAsync(int collectorId, int enterpriseId)
    {
        var collector = await _identityClient.GetCollectorAsync(collectorId);
        if (collector == null || collector.EnterpriseId != enterpriseId)
            return null;

        var allAssignments = await _uow.CollectorAssignments.GetByCollectorIdAsync(collectorId);
        var completedCount = allAssignments.Count(a => a.Status == "Completed");

        return new CollectorDtoLocal
        {
            CollectorId = collector.CollectorId,
            FullName = collector.FullName,
            Email = collector.Email,
            Phone = collector.Phone,
            IsAvailable = collector.IsAvailable,
            WarningCount = collector.WarningCount,
            CompletedCount = completedCount,
            TotalAssignments = allAssignments.Count()
        };
    }

    public async Task<bool> UpdateCollectorAvailabilityAsync(int collectorId, int enterpriseId, bool isAvailable)
    {
        var collector = await _identityClient.GetCollectorAsync(collectorId);
        if (collector == null || collector.EnterpriseId != enterpriseId)
            throw new InvalidOperationException("Collector not found or does not belong to your enterprise");

        await _identityClient.UpdateCollectorAvailabilityAsync(collectorId, isAvailable);
        return true;
    }

    public async Task SoftDeleteCollectorAsync(int collectorId, int enterpriseId)
    {
        var collector = await _identityClient.GetCollectorAsync(collectorId);
        if (collector == null || collector.EnterpriseId != enterpriseId)
            throw new InvalidOperationException("Collector không tồn tại hoặc không thuộc quản lý của bạn");

        // Kiểm tra xem có lịch thu gom nào chưa hoàn thành không
        var openAssignmentsCount = await _uow.CollectorAssignments.CountOpenAssignmentsByCollectorAsync(collectorId);
        if (openAssignmentsCount > 0)
        {
            throw new InvalidOperationException("Không thể tạm dừng nhân viên đang có lịch thu gom chưa hoàn thành.");
        }

        await _identityClient.SoftDeleteUserAsync(collectorId);
    }

    public async Task ReactivateCollectorAsync(int collectorId, int enterpriseId)
    {
        var collector = await _identityClient.GetCollectorAsync(collectorId);
        if (collector == null || collector.EnterpriseId != enterpriseId)
            throw new InvalidOperationException("Collector không tồn tại hoặc không thuộc quản lý của bạn");

        await _identityClient.ReactivateUserAsync(collectorId);
    }

    private async Task<PublicCollectionRequestDto> MapListDtoAsync(CollectionRequest request)
    {
        var report = await _wasteClient.GetReportAsync(request.ReportId);
        var enterprise = await _identityClient.GetUserAsync(request.EnterpriseId);
        var currentAssignment = GetCurrentAssignment(request.CollectorAssignments);
        var collector = currentAssignment == null ? null : await _identityClient.GetUserAsync(currentAssignment.AssignedCollector);

        return new PublicCollectionRequestDto
        {
            RequestId = request.RequestId,
            ReportId = request.ReportId,
            EnterpriseId = request.EnterpriseId,
            EnterpriseName = enterprise?.FullName,
            Status = request.Status,
            CreatedAt = request.CreatedAt,
            WasteTypeId = report?.WasteTypeIds != null ? string.Join(", ", report.WasteTypeIds) : string.Empty,
            WasteTypeName = report?.WasteTypeNames != null ? string.Join(", ", report.WasteTypeNames) : string.Empty,
            ReportImageUrl = report?.ImageUrl,
            Latitude = report?.Latitude,
            Longitude = report?.Longitude,
            ReportDescription = report?.Description,
            EstimatedSize = report?.EstimatedSize,
            ReportStatus = report?.Status,
            ReportCreatedAt = report?.CreatedAt,
            CurrentAssignmentId = currentAssignment?.AssignmentId,
            AssignedCollectorId = currentAssignment?.AssignedCollector,
            AssignedCollectorName = collector?.FullName,
            AssignmentStatus = currentAssignment?.Status,
            AssignedAt = currentAssignment?.AssignedAt
        };
    }

    private async Task<CollectionRequestDetailDto> MapDetailDtoAsync(CollectionRequest request)
    {
        var report = await _wasteClient.GetReportAsync(request.ReportId);
        var enterprise = await _identityClient.GetUserAsync(request.EnterpriseId);
        var assignments = await _uow.CollectorAssignments.GetByRequestIdAsync(request.RequestId);
        var history = await MapHistoryAsync(assignments);
        UserDto? citizen = report == null ? null : await _identityClient.GetUserAsync(report.SubmittedBy);

        return new CollectionRequestDetailDto
        {
            RequestId = request.RequestId,
            ReportId = request.ReportId,
            EnterpriseId = request.EnterpriseId,
            EnterpriseName = enterprise?.FullName,
            EnterpriseEmail = enterprise?.Email,
            EnterprisePhone = enterprise?.Phone,
            Status = request.Status,
            CreatedAt = request.CreatedAt,
            Report = report == null ? null : new WasteReportInfo
            {
                ReportId = report.ReportId,
                SubmittedBy = report.SubmittedBy,
                CitizenName = citizen?.FullName,
                CitizenEmail = citizen?.Email,
                WasteTypeIds = report.WasteTypeIds,
                WasteTypeNames = report.WasteTypeNames,
                ImageUrl = report.ImageUrl,
                Latitude = report.Latitude,
                Longitude = report.Longitude,
                Description = report.Description,
                Status = report.Status,
                CreatedAt = report.CreatedAt
            },
            AssignmentHistory = history.ToList()
        };
    }

    private async Task<IEnumerable<AssignmentHistoryDto>> MapHistoryAsync(IEnumerable<CollectorAssignment> assignments)
    {
        var result = new List<AssignmentHistoryDto>();
        foreach (var a in assignments)
        {
            var collector = await _identityClient.GetUserAsync(a.AssignedCollector);
            var assignedBy = await _identityClient.GetUserAsync(a.AssignedBy);

            var historyItem = new AssignmentHistoryDto
            {
                AssignmentId = a.AssignmentId,
                AssignedCollector = a.AssignedCollector,
                CollectorName = collector?.FullName,
                CollectorPhone = collector?.Phone,
                AssignedBy = a.AssignedBy,
                AssignedByName = assignedBy?.FullName,
                Status = a.Status,
                AssignedAt = a.AssignedAt,
                StartedAt = a.StartedAt,
                ArrivedAt = a.ArrivedAt,
                BeforeImageUrl = a.BeforeImageUrl
            };

            if (a.CollectionConfirmation != null)
            {
                historyItem.CompletedAt = a.CollectionConfirmation.ConfirmedAt;
                historyItem.AfterImageUrl = a.CollectionConfirmation.AfterImageUrl;
                historyItem.ConfirmationNote = a.CollectionConfirmation.Note;

                if (a.CollectionConfirmation.CollectionDetails != null)
                {
                    var details = new List<CollectionDetailHistoryDto>();
                    foreach (var d in a.CollectionConfirmation.CollectionDetails)
                    {
                        var wasteType = await _wasteClient.GetWasteTypeAsync(d.WasteTypeId);
                        details.Add(new CollectionDetailHistoryDto
                        {
                            WasteTypeId = d.WasteTypeId,
                            WasteTypeName = wasteType?.Name ?? "Unknown",
                            ActualWeight = (decimal)d.ActualWeight
                        });
                    }
                    historyItem.CollectionDetails = details;
                }
            }

            result.Add(historyItem);
        }
        return result;
    }

    private static CollectorAssignment? GetCurrentAssignment(IEnumerable<CollectorAssignment> assignments)
    {
        return assignments
            .Where(a => !string.IsNullOrWhiteSpace(a.Status) && VisibleAssignmentStatuses.Contains(a.Status))
            .OrderByDescending(a => a.ArrivedAt ?? DateTime.MinValue)
            .ThenByDescending(a => a.StartedAt ?? DateTime.MinValue)
            .ThenByDescending(a => a.AssignedAt ?? DateTime.MinValue)
            .FirstOrDefault();
    }

    private static Contracts.CollectionRequestDto ToContract(CollectionRequest request) => new()
    {
        RequestId = request.RequestId,
        ReportId = request.ReportId,
        EnterpriseId = request.EnterpriseId,
        Status = request.Status,
        CreatedAt = request.CreatedAt,
        Note = request.Note,
        IssueReport = request.IssueReport,
        IssueReason = request.IssueReason,
        IssueImageUrl = request.IssueImageUrl
    };
}
