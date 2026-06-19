using WasteReportService.Application.DTOs.District;
using WasteReportService.Application.Repositories;

namespace WasteReportService.Application.Services;

public sealed class DistrictService : IDistrictService
{
    private readonly IWasteUnitOfWork _uow;

    public DistrictService(IWasteUnitOfWork uow)
    {
        _uow = uow;
    }

    public Task<IEnumerable<DistrictResponseDto>> GetAllAsync()
    {
        var districts = _uow.Districts
            .Where(d => d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => new DistrictResponseDto
            {
                DistrictId = d.DistrictId,
                Name = d.Name,
                Code = d.Code ?? string.Empty
            })
            .AsEnumerable();

        return Task.FromResult(districts);
    }
}
