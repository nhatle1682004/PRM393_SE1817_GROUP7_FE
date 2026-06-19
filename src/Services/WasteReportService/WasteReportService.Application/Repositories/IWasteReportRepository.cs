using WasteReportService.Domain.Entities;

namespace WasteReportService.Application.Repositories;

public interface IWasteReportRepository
{
    Task AddAsync(WasteReport entity);
    Task<WasteReport?> GetByIdAsync(int reportId);
    Task<IEnumerable<WasteReport>> GetAllAsync();
    Task<IEnumerable<WasteReport>> GetByUserIdAsync(int userId);
    Task<IEnumerable<WasteReport>> FindPotentialDuplicatesAsync(List<int> wasteTypeIds, decimal latitude, decimal longitude, decimal latDelta, decimal lonDelta, int? excludeReportId = null);
    void Update(WasteReport entity);
}
