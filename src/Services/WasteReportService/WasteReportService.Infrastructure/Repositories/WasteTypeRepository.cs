using Microsoft.EntityFrameworkCore;
using WasteReportService.Application.Repositories;
using WasteReportService.Domain.Entities;
using WasteReportService.Infrastructure.Persistence;

namespace WasteReportService.Infrastructure.Repositories;

public sealed class WasteTypeRepository : IWasteTypeRepository
{
    private readonly WasteReportDbContext _context;

    public WasteTypeRepository(WasteReportDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<WasteType>> GetAllAsync() => await _context.WasteTypes.OrderBy(x => x.WasteTypeId).ToListAsync();
    public Task<WasteType?> GetByIdAsync(int id) => _context.WasteTypes.FirstOrDefaultAsync(x => x.WasteTypeId == id);
    public Task<bool> NameExistsAsync(string name) => _context.WasteTypes.AnyAsync(x => x.Name == name);
    public Task<bool> NameExistsAsync(string name, int excludeWasteTypeId) => _context.WasteTypes.AnyAsync(x => x.Name == name && x.WasteTypeId != excludeWasteTypeId);
    public Task AddAsync(WasteType entity) => _context.WasteTypes.AddAsync(entity).AsTask();
    public void Update(WasteType entity) => _context.WasteTypes.Update(entity);
}
