using WasteReportService.Domain.Entities;

namespace WasteReportService.Application.Repositories;

public interface IWasteUnitOfWork
{
    IWasteTypeRepository WasteTypes { get; }
    IWasteReportRepository WasteReports { get; }
    IQueryable<District> Districts { get; }
    Task<int?> ResolveDistrictIdAsync(decimal latitude, decimal longitude);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
