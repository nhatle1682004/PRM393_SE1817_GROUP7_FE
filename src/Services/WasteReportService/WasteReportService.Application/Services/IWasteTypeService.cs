using WasteReportService.Application.DTOs.WasteType;
using WasteReportService.Domain.Entities;

namespace WasteReportService.Application.Services;

public interface IWasteTypeService
{
    Task<IEnumerable<WasteType>> GetAllAsync(bool onlyActive = true);
    Task<WasteType?> GetByIdAsync(int id);
    Task<WasteType> CreateAsync(CreateWasteTypeDto dto);
    Task<WasteType> UpdateAsync(int id, UpdateWasteTypeDto dto);
    Task DeleteAsync(int id);
}
