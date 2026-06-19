using WasteReportService.Application.DTOs.WasteType;
using WasteReportService.Application.Repositories;
using WasteReportService.Domain.Entities;

namespace WasteReportService.Application.Services;

public sealed class WasteTypeService : IWasteTypeService
{
    private readonly IWasteUnitOfWork _uow;

    public WasteTypeService(IWasteUnitOfWork uow)
    {
        _uow = uow;
    }

    public async Task<IEnumerable<WasteType>> GetAllAsync(bool onlyActive = true)
    {
        var all = await _uow.WasteTypes.GetAllAsync();
        return onlyActive ? all.Where(wt => wt.IsActive).ToList() : all;
    }

    public Task<WasteType?> GetByIdAsync(int id) => _uow.WasteTypes.GetByIdAsync(id);

    public async Task<WasteType> CreateAsync(CreateWasteTypeDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Name))
            throw new ArgumentException("Name is required");
        if (await _uow.WasteTypes.NameExistsAsync(dto.Name))
            throw new InvalidOperationException("WasteType name already exists");

        var entity = new WasteType { Name = dto.Name, Description = dto.Description, RewardPoints = dto.RewardPoints, IsActive = true };
        await _uow.WasteTypes.AddAsync(entity);
        await _uow.SaveChangesAsync();
        return entity;
    }

    public async Task<WasteType> UpdateAsync(int id, UpdateWasteTypeDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Name))
            throw new ArgumentException("Name is required");

        var existing = await _uow.WasteTypes.GetByIdAsync(id) ?? throw new InvalidOperationException("WasteType not found");
        if (await _uow.WasteTypes.NameExistsAsync(dto.Name, id))
            throw new InvalidOperationException("WasteType name already exists");

        existing.Name = dto.Name;
        existing.Description = dto.Description;
        existing.RewardPoints = dto.RewardPoints;
        if (dto.IsActive.HasValue)
            existing.IsActive = dto.IsActive.Value;

        _uow.WasteTypes.Update(existing);
        await _uow.SaveChangesAsync();
        return existing;
    }

    public async Task DeleteAsync(int id)
    {
        var existing = await _uow.WasteTypes.GetByIdAsync(id) ?? throw new InvalidOperationException("WasteType not found");
        existing.IsActive = false;
        _uow.WasteTypes.Update(existing);
        await _uow.SaveChangesAsync();
    }
}
