using IdentityService.Application.Repositories;
using IdentityService.Domain.Entities;
using IdentityService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Infrastructure.Repositories;

public sealed class UserRepository : IUserRepository
{
    private readonly IdentityDbContext _context;

    public UserRepository(IdentityDbContext context)
    {
        _context = context;
    }

    public Task<User?> GetByIdAsync(int id) => _context.Users
        .Include(u => u.Role)
        .Include(u => u.CollectorProfile)
        .Include(u => u.EnterpriseProfile)
        .FirstOrDefaultAsync(u => u.UserId == id);

    public Task<User?> GetByEmailAsync(string email) => _context.Users
        .Include(u => u.Role)
        .Include(u => u.CollectorProfile)
        .Include(u => u.EnterpriseProfile)
        .FirstOrDefaultAsync(u => u.Email == email);

    public Task<bool> EmailExistsAsync(string email) => _context.Users.AnyAsync(u => u.Email == email);
    public Task<bool> PhoneExistsAsync(string phone) => _context.Users.AnyAsync(u => u.Phone == phone);
    public Task<bool> EmailExistsExceptAsync(string email, int excludeUserId) => _context.Users.AnyAsync(u => u.Email == email && u.UserId != excludeUserId);
    public Task<bool> PhoneExistsExceptAsync(string phone, int excludeUserId) => _context.Users.AnyAsync(u => u.Phone == phone && u.UserId != excludeUserId);

    public async Task<IEnumerable<User>> GetAllAsync() => await _context.Users
        .Include(u => u.Role)
        .Include(u => u.CollectorProfile)
        .Include(u => u.EnterpriseProfile)
        .ToListAsync();

    public async Task<IEnumerable<User>> GetUsersByRoleAsync(string roleName) => await _context.Users
        .Include(u => u.Role)
        .Include(u => u.CollectorProfile)
        .Include(u => u.EnterpriseProfile)
        .Where(u => u.Role.RoleName == roleName)
        .ToListAsync();

    public Task AddAsync(User user) => _context.Users.AddAsync(user).AsTask();
    public void Update(User user) => _context.Users.Update(user);
    public void Delete(User user) => _context.Users.Remove(user);
}
