using WasteReportService.Domain.Entities;

namespace WasteReportService.Application.Repositories;

public interface IWasteTypeRepository
{
    Task<IEnumerable<WasteType>> GetAllAsync();
    Task<WasteType?> GetByIdAsync(int id);
    Task<bool> NameExistsAsync(string name);
    Task<bool> NameExistsAsync(string name, int excludeWasteTypeId);
    Task AddAsync(WasteType entity);
    void Update(WasteType entity);
}
