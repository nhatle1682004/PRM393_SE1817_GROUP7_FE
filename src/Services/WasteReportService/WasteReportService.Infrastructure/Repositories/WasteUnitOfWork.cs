using WasteReportService.Application.Repositories;
using WasteReportService.Domain.Entities;
using WasteReportService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace WasteReportService.Infrastructure.Repositories;

public sealed class WasteUnitOfWork : IWasteUnitOfWork
{
    private readonly WasteReportDbContext _context;

    public WasteUnitOfWork(WasteReportDbContext context, IWasteTypeRepository wasteTypes, IWasteReportRepository wasteReports)
    {
        _context = context;
        WasteTypes = wasteTypes;
        WasteReports = wasteReports;
    }

    public IWasteTypeRepository WasteTypes { get; }
    public IWasteReportRepository WasteReports { get; }
    public IQueryable<District> Districts => _context.Districts;

    public async Task<int?> ResolveDistrictIdAsync(decimal latitude, decimal longitude)
    {
        var conn = _context.Database.GetDbConnection();
        if (conn.State != System.Data.ConnectionState.Open)
            await conn.OpenAsync();

        await using var cmd = conn.CreateCommand();
        cmd.CommandText = @"
            select district_id
            from waste.districts
            where is_active = true
              and st_contains(
                    boundary,
                    st_setsrid(st_point(@lng, @lat), 4326)
                  )
            limit 1;";

        var latParam = cmd.CreateParameter();
        latParam.ParameterName = "@lat";
        latParam.Value = latitude;
        cmd.Parameters.Add(latParam);

        var lngParam = cmd.CreateParameter();
        lngParam.ParameterName = "@lng";
        lngParam.Value = longitude;
        cmd.Parameters.Add(lngParam);

        var result = await cmd.ExecuteScalarAsync();
        return result == null || result == DBNull.Value ? null : Convert.ToInt32(result);
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) => _context.SaveChangesAsync(cancellationToken);
}
