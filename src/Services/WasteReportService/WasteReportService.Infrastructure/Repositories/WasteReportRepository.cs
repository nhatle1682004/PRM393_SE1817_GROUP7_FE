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
        .FirstOrDefaultAsync(x => x.ReportId == reportId);

    public async Task<IEnumerable<WasteReport>> GetAllAsync() => await _context.WasteReports
        .Include(x => x.WasteTypes)
        .OrderByDescending(x => x.CreatedAt)
        .ToListAsync();

    public async Task<IEnumerable<WasteReport>> GetByUserIdAsync(int userId) => await _context.WasteReports
        .Include(x => x.WasteTypes)
        .Where(x => x.SubmittedBy == userId)
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
