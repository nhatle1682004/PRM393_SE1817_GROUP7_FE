using WasteReportService.Application.DTOs.District;

namespace WasteReportService.Application.Services;

public interface IDistrictService
{
    Task<IEnumerable<DistrictResponseDto>> GetAllAsync();
}
