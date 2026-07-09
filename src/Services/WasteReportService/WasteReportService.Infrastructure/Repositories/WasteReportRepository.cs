using Microsoft.EntityFrameworkCore;
using WasteReportService.Application.Repositories;
using WasteReportService.Domain.Entities;
using WasteReportService.Infrastructure.Persistence;

namespace WasteReportService.Infrastructure.Repositories;

public sealed class WasteReportRepository : IWasteReportRepository
{
    private readonly WasteReportDbContext _context;

    public WasteReportRepository(WasteReportDbContext context)
    {
        _context = context;
    }

    public Task AddAsync(WasteReport entity) => _context.WasteReports.AddAsync(entity).AsTask();

    public Task<WasteReport?> GetByIdAsync(int reportId) => _context.WasteReports
        .Include(x => x.WasteTypes)
        .Include(x => x.AiWastePredictions)
        .FirstOrDefaultAsync(x => x.ReportId == reportId);

    public async Task<bool> TrySetStatusToAcceptedAsync(int reportId)
    {
        var rowsAffected = await _context.Database.ExecuteSqlRawAsync(
            @"UPDATE waste.waste_reports 
              SET status = 'Accepted' 
              WHERE report_id = {0} AND status = 'Pending'", 
            reportId);
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<WasteReport>> GetAllAsync() => await _context.WasteReports
        .Include(x => x.WasteTypes)
        .OrderByDescending(x => x.CreatedAt)
        .ToListAsync();

    public async Task<IEnumerable<WasteReport>> GetByUserIdAsync(int userId) => await _context.WasteReports
        .Include(x => x.WasteTypes)
        .Where(x => x.SubmittedBy == userId)
        .OrderByDescending(x => x.CreatedAt)
        .ToListAsync();

    public async Task<IEnumerable<WasteReport>> GetByDistrictIdAsync(int districtId) => await _context.WasteReports
        .Include(x => x.WasteTypes)
        .Where(x => x.DistrictId == districtId)
        .OrderByDescending(x => x.CreatedAt)
        .ToListAsync();

    public async Task<IEnumerable<WasteReport>> FindPotentialDuplicatesAsync(
        List<int> wasteTypeIds,
        decimal latitude,
        decimal longitude,
        decimal latDelta,
        decimal lonDelta,
        int? excludeReportId = null)
    {
        return await _context.WasteReports
            .Include(x => x.WasteTypes)
            .Where(x => x.WasteTypes.Any(wt => wasteTypeIds.Contains(wt.WasteTypeId))
                && x.Latitude >= latitude - latDelta
                && x.Latitude <= latitude + latDelta
                && x.Longitude >= longitude - lonDelta
                && x.Longitude <= longitude + lonDelta
                && x.Status != "Cancelled"
                && x.Status != "Rejected"
                && (!excludeReportId.HasValue || x.ReportId != excludeReportId.Value))
            .OrderBy(x => x.CreatedAt)
            .ToListAsync();
    }

    public void Update(WasteReport entity) => _context.WasteReports.Update(entity);
}
