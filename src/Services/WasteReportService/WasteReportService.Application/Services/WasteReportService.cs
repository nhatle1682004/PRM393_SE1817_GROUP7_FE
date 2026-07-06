using Contracts;
using WasteReportService.Application.Clients;
using WasteReportService.Application.DTOs.WasteReport;
using WasteReportService.Application.Repositories;
using WasteReportService.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace WasteReportService.Application.Services;

public sealed class WasteReportService : IWasteReportService
{
    private const int DuplicateRadiusMeters = 30;
    private readonly IWasteUnitOfWork _uow;
    private readonly IIdentityClient _identityClient;
    private readonly ICollectionClient _collectionClient;
    private readonly IEngagementClient _engagementClient;
    private readonly ILogger<WasteReportService> _logger;

    public WasteReportService(
        IWasteUnitOfWork uow,
        IIdentityClient identityClient,
        ICollectionClient collectionClient,
        IEngagementClient engagementClient,
        ILogger<WasteReportService> logger)
    {
        _uow = uow;
        _identityClient = identityClient;
        _collectionClient = collectionClient;
        _engagementClient = engagementClient;
        _logger = logger;
    }

    public async Task<WasteReportCreatedResponseDto> CreateAsync(int userId, CreateWasteReportDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Image))
            throw new ArgumentException("Image is required");
        ValidateCoordinates(dto.Latitude, dto.Longitude);
        if (dto.WasteTypeIds == null || !dto.WasteTypeIds.Any())
            throw new ArgumentException("At least one WasteTypeId is required");

        var wasteTypes = new List<WasteType>();
        foreach (var id in dto.WasteTypeIds)
        {
            var wt = await _uow.WasteTypes.GetByIdAsync(id);
            if (wt == null || !wt.IsActive)
                throw new ArgumentException($"WasteTypeId {id} is invalid");
            wasteTypes.Add(wt);
        }

        await EnsureNotDuplicateAsync(dto.WasteTypeIds, dto.Latitude, dto.Longitude);

        var districtId = await _uow.ResolveDistrictIdAsync(dto.Latitude, dto.Longitude);
        if (!districtId.HasValue)
            throw new InvalidOperationException("This location is outside supported service districts.");

        var nowUtc = DateTime.UtcNow;
        var entity = new WasteReport
        {
            SubmittedBy = userId,
            ImageUrl = dto.Image,
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            DistrictId = districtId.Value,
            Description = dto.Description,
            Status = "Pending",
            CreatedAt = nowUtc,
            WasteTypes = wasteTypes
        };

        await _uow.WasteReports.AddAsync(entity);
        await _uow.SaveChangesAsync();

        await _engagementClient.CreateNotificationAsync(new CreateNotificationRequest
        {
            UserId = userId,
            Content = "Your waste report has been submitted successfully and is pending approval."
        });

        var enterprise = await _identityClient.GetEnterpriseByDistrictAsync(districtId.Value);
        if (enterprise != null)
        {
            await _engagementClient.CreateNotificationAsync(new CreateNotificationRequest
            {
                UserId = enterprise.EnterpriseId,
                Content = "A new waste report (Pending) has been submitted in your managed district."
            });
        }

        return new WasteReportCreatedResponseDto
        {
            Id = entity.ReportId,
            Status = entity.Status,
            CreatedAt = entity.CreatedAt ?? nowUtc
        };
    }

    public async Task<WasteReportStatusResponseDto> AcceptAsync(int reportId, int enterpriseId)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId) ?? throw new InvalidOperationException("WasteReport not found");
        var enterprise = await _identityClient.GetEnterpriseAsync(enterpriseId);
        if (enterprise == null)
            throw new InvalidOperationException("Enterprise profile not found");

        if (!report.DistrictId.HasValue)
            throw new InvalidOperationException("Report district is missing");
        if (enterprise.ManagedDistrictId != report.DistrictId.Value)
            throw new UnauthorizedAccessException("You can only accept reports in your managed district.");
        if (!string.Equals(report.Status, "Pending", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Only Pending reports can be accepted");

        await _collectionClient.CreateFromReportAsync(new CreateCollectionRequestFromReportRequest
        {
            ReportId = reportId,
            EnterpriseId = enterpriseId,
            Status = "Pending"
        });

        report.Status = "Accepted";
        _uow.WasteReports.Update(report);
        await _uow.SaveChangesAsync();

        try
        {
            await _engagementClient.CreateNotificationAsync(new CreateNotificationRequest
            {
                UserId = report.SubmittedBy,
                Content = $"Your waste report #{reportId} has been accepted and is waiting for collection."
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create accepted notification for waste report {ReportId}", reportId);
        }

        return new WasteReportStatusResponseDto { Id = report.ReportId, Status = report.Status };
    }

    public async Task<WasteReportStatusResponseDto> RejectAsync(int reportId)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId) ?? throw new InvalidOperationException("WasteReport not found");
        if (!string.Equals(report.Status, "Pending", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Only Pending reports can be rejected");

        report.Status = "Rejected";
        _uow.WasteReports.Update(report);
        await _uow.SaveChangesAsync();

        await _engagementClient.CreateNotificationAsync(new CreateNotificationRequest
        {
            UserId = report.SubmittedBy,
            Content = $"Your waste report #{reportId} has been rejected."
        });

        return new WasteReportStatusResponseDto { Id = report.ReportId, Status = report.Status };
    }

    public async Task<IEnumerable<DTOs.WasteReport.WasteReportDto>> GetAllAsync(int? userId)
    {
        var reports = userId.HasValue
            ? await _uow.WasteReports.GetByUserIdAsync(userId.Value)
            : await _uow.WasteReports.GetAllAsync();

        var result = new List<DTOs.WasteReport.WasteReportDto>();
        foreach (var report in reports)
            result.Add(await MapToDtoAsync(report));
        return result;
    }

    public async Task<DTOs.WasteReport.WasteReportDto?> GetByIdAsync(int reportId, int? userId)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId);
        if (report == null || (userId.HasValue && report.SubmittedBy != userId.Value))
            return null;

        return await MapToDtoAsync(report);
    }

    public async Task<DTOs.WasteReport.WasteReportDto> UpdateAsync(int reportId, int userId, UpdateWasteReportDto dto)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId) ?? throw new InvalidOperationException("WasteReport not found");
        if (report.SubmittedBy != userId)
            throw new UnauthorizedAccessException("You can only update your own reports");
        if (!string.Equals(report.Status, "Pending", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Only Pending reports can be updated");

        ValidateCoordinates(dto.Latitude, dto.Longitude);
        if (dto.WasteTypeIds == null || !dto.WasteTypeIds.Any())
            throw new ArgumentException("At least one WasteTypeId is required");

        var newWasteTypes = new List<WasteType>();
        foreach (var id in dto.WasteTypeIds)
        {
            var wt = await _uow.WasteTypes.GetByIdAsync(id);
            if (wt == null || !wt.IsActive)
                throw new ArgumentException($"WasteTypeId {id} is invalid");
            newWasteTypes.Add(wt);
        }

        await EnsureNotDuplicateAsync(dto.WasteTypeIds, dto.Latitude, dto.Longitude, reportId);
        var districtId = await _uow.ResolveDistrictIdAsync(dto.Latitude, dto.Longitude);
        if (!districtId.HasValue)
            throw new InvalidOperationException("This location is outside supported service districts.");

        if (!string.IsNullOrWhiteSpace(dto.Image))
            report.ImageUrl = dto.Image;
        report.Latitude = dto.Latitude;
        report.Longitude = dto.Longitude;
        report.Description = dto.Description;
        report.DistrictId = districtId.Value;
        report.WasteTypes.Clear();
        foreach (var wt in newWasteTypes)
            report.WasteTypes.Add(wt);

        _uow.WasteReports.Update(report);
        await _uow.SaveChangesAsync();
        return await MapToDtoAsync(report);
    }

    public async Task<WasteReportStatusResponseDto> CancelAsync(int reportId, int userId)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId) ?? throw new InvalidOperationException("WasteReport not found");
        if (report.SubmittedBy != userId)
            throw new UnauthorizedAccessException("You can only cancel your own reports");
        if (!string.Equals(report.Status, "Pending", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Only Pending reports can be cancelled");

        report.Status = "Cancelled";
        _uow.WasteReports.Update(report);
        await _uow.SaveChangesAsync();
        return new WasteReportStatusResponseDto { Id = report.ReportId, Status = report.Status };
    }

    public async Task<Contracts.WasteReportDto?> GetInternalByIdAsync(int reportId)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId);
        if (report == null)
            return null;

        var user = await _identityClient.GetUserAsync(report.SubmittedBy);
        return new Contracts.WasteReportDto
        {
            ReportId = report.ReportId,
            SubmittedBy = report.SubmittedBy,
            SubmittedByName = user?.FullName,
            WasteTypeIds = report.WasteTypes.Select(w => w.WasteTypeId).ToList(),
            WasteTypeNames = report.WasteTypes.Select(w => w.Name).ToList(),
            ImageUrl = report.ImageUrl,
            Latitude = report.Latitude,
            Longitude = report.Longitude,
            DistrictId = report.DistrictId,
            Description = report.Description,
            Status = report.Status,
            CreatedAt = report.CreatedAt
        };
    }

    public async Task UpdateStatusAsync(int reportId, string status)
    {
        var report = await _uow.WasteReports.GetByIdAsync(reportId) ?? throw new InvalidOperationException("WasteReport not found");
        report.Status = status;
        _uow.WasteReports.Update(report);
        await _uow.SaveChangesAsync();
    }

    public async Task<WasteDashboardStatsDto> GetDashboardStatsAsync(int year)
    {
        var reports = (await _uow.WasteReports.GetAllAsync()).ToList();
        var statusCounts = reports.GroupBy(r => r.Status ?? "Unknown").ToDictionary(g => g.Key, g => g.Count());
        var monthNames = System.Globalization.CultureInfo.InvariantCulture.DateTimeFormat.AbbreviatedMonthNames;
        var reportMonthData = reports
            .Where(r => r.CreatedAt.HasValue && r.CreatedAt.Value.Year == year)
            .GroupBy(r => r.CreatedAt!.Value.Month)
            .ToDictionary(g => g.Key, g => g.Count());

        var recentReports = reports.OrderByDescending(r => r.CreatedAt).Take(5).ToList();
        var recentReportDtos = new List<RecentReportDto>();
        foreach (var recentReport in recentReports)
        {
            var submitter = await _identityClient.GetUserAsync(recentReport.SubmittedBy);
            recentReportDtos.Add(new RecentReportDto
            {
                ReportId = recentReport.ReportId,
                SubmittedByName = submitter?.FullName ?? "Unknown",
                Description = recentReport.Description,
                Status = recentReport.Status,
                WasteTypeNames = recentReport.WasteTypes.Select(w => w.Name).ToList(),
                CreatedAt = recentReport.CreatedAt
            });
        }

        return new WasteDashboardStatsDto
        {
            TotalReports = reports.Count,
            PendingReports = statusCounts.GetValueOrDefault("Pending"),
            AcceptedReports = statusCounts.GetValueOrDefault("Accepted"),
            CollectedReports = statusCounts.GetValueOrDefault("Collected"),
            CancelledReports = statusCounts.GetValueOrDefault("Cancelled"),
            RejectedReports = statusCounts.GetValueOrDefault("Rejected"),
            ReportStatusDistribution = statusCounts.Select(x => new StatusCountDto { Status = x.Key, Count = x.Value }).OrderByDescending(x => x.Count).ToList(),
            ReportsByMonth = Enumerable.Range(1, 12).Select(m => new MonthlyCountDto { Month = m, MonthName = monthNames[m - 1], Count = reportMonthData.GetValueOrDefault(m) }).ToList(),
            WasteTypeDistribution = reports.SelectMany(r => r.WasteTypes).GroupBy(w => w.Name).Select(g => new WasteTypeDistributionDto { Name = g.Key, Count = g.Count() }).OrderByDescending(x => x.Count).ToList(),
            RecentReports = recentReportDtos
        };
    }

    private async Task EnsureNotDuplicateAsync(List<int> wasteTypeIds, decimal latitude, decimal longitude, int? excludeReportId = null)
    {
        var nearbyReports = await _uow.WasteReports.FindPotentialDuplicatesAsync(wasteTypeIds, latitude, longitude, 0.001m, 0.001m, excludeReportId);
        var isDuplicate = nearbyReports.Any(r =>
            CalculateDistanceMeters((double)r.Latitude, (double)r.Longitude, (double)latitude, (double)longitude) <= DuplicateRadiusMeters);

        if (isDuplicate)
            throw new InvalidOperationException("A similar waste report already exists in this location.");
    }

    private async Task<DTOs.WasteReport.WasteReportDto> MapToDtoAsync(WasteReport report)
    {
        var user = await _identityClient.GetUserAsync(report.SubmittedBy);
        return new DTOs.WasteReport.WasteReportDto
        {
            ReportId = report.ReportId,
            SubmittedBy = report.SubmittedBy,
            SubmittedByName = user?.FullName ?? string.Empty,
            WasteTypeIds = report.WasteTypes.Select(wt => wt.WasteTypeId).ToList(),
            WasteTypeNames = report.WasteTypes.Select(wt => wt.Name).ToList(),
            ImageUrl = report.ImageUrl,
            Latitude = report.Latitude,
            Longitude = report.Longitude,
            Description = report.Description,
            Status = report.Status ?? string.Empty,
            CreatedAt = report.CreatedAt
        };
    }

    private static void ValidateCoordinates(decimal latitude, decimal longitude)
    {
        if (latitude < -90 || latitude > 90)
            throw new ArgumentException("Latitude must be between -90 and 90");
        if (longitude < -180 || longitude > 180)
            throw new ArgumentException("Longitude must be between -180 and 180");
    }

    private static double CalculateDistanceMeters(double lat1, double lon1, double lat2, double lon2)
    {
        const double EarthRadiusKm = 6371;
        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                + Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2))
                * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return EarthRadiusKm * c * 1000;
    }

    private static double DegreesToRadians(double degrees) => degrees * Math.PI / 180;
}
