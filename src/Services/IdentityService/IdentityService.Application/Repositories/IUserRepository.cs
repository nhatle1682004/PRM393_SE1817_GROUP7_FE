using IdentityService.Domain.Entities;

namespace IdentityService.Application.Repositories;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(int id);
    Task<User?> GetByEmailAsync(string email);
    Task<bool> EmailExistsAsync(string email);
    Task<bool> PhoneExistsAsync(string phone);
    Task<bool> EmailExistsExceptAsync(string email, int excludeUserId);
    Task<bool> PhoneExistsExceptAsync(string phone, int excludeUserId);
    Task<IEnumerable<User>> GetAllAsync();
    Task<IEnumerable<User>> GetUsersByRoleAsync(string roleName);
    Task<IEnumerable<User>> GetCollectorsByEnterpriseAsync(int enterpriseId);
    Task AddAsync(User user);
    void Update(User user);
    void Delete(User user);
}
