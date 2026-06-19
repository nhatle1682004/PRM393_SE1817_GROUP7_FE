using Contracts;
using IdentityService.Application.DTOs.User;

namespace IdentityService.Application.Services;

public interface IUserService
{
    Task<UserResponseDto> CreateUserAsync(CreateUserRequestDto request);
    Task<UserResponseDto?> GetByIdAsync(int id);
    Task<IEnumerable<UserResponseDto>> GetAllAsync();
    Task<UserResponseDto> UpdateUserAsync(int id, UpdateUserRequestDto request);
    Task<UserResponseDto> SoftDeleteUserAsync(int id);
    Task<UserResponseDto> ReactivateUserAsync(int id);
    Task DeleteUserAsync(int id);
    Task ChangePasswordAsync(int userId, ChangePasswordDto dto);
    Task<UserResponseDto> UpdateCollectorAvailabilityAsync(int userId, bool isAvailable);
    Task<UserResponseDto> UpdateMyProfileAsync(int userId, UpdateProfileRequestDto request);
    Task<Contracts.UserDto?> GetInternalUserAsync(int userId);
    Task<EnterpriseProfileDto?> GetEnterpriseProfileAsync(int enterpriseId);
    Task<EnterpriseProfileDto?> GetEnterpriseByDistrictAsync(int districtId);
    Task<CollectorProfileDto?> GetCollectorProfileAsync(int collectorId);
    Task<IEnumerable<CollectorProfileDto>> GetCollectorsByEnterpriseAsync(int enterpriseId);
    Task<int> AddPointsAsync(int userId, int points);
    Task<int> DeductPointsAsync(int userId, int points);
    Task<CollectorProfileDto> AddCollectorWarningAsync(int collectorId, int points);
    Task<IdentityDashboardStatsDto> GetDashboardStatsAsync(int year);
}
