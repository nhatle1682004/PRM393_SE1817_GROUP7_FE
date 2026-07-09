using Contracts;
using IdentityService.Application.DTOs.User;
using IdentityService.Application.Repositories;
using IdentityService.Domain.Entities;
using System.Globalization;

namespace IdentityService.Application.Services;

public sealed class UserService : IUserService
{
    private const int WarningThreshold = 4;
    private readonly IIdentityUnitOfWork _uow;

    public UserService(IIdentityUnitOfWork uow)
    {
        _uow = uow;
    }

    public async Task<UserResponseDto> CreateUserAsync(CreateUserRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
            throw new ArgumentException("Email is required");
        if (string.IsNullOrWhiteSpace(request.Password))
            throw new ArgumentException("Password is required");
        if (await _uow.Users.EmailExistsAsync(request.Email))
            throw new InvalidOperationException("Email already exists");
        if (!string.IsNullOrWhiteSpace(request.Phone) && await _uow.Users.PhoneExistsAsync(request.Phone))
            throw new InvalidOperationException("Phone already exists");

        var role = _uow.Roles.FirstOrDefault(r => r.RoleId == request.RoleId);
        if (role == null)
            throw new InvalidOperationException("Role not found");

        if (string.Equals(role.RoleName, "Enterprise", StringComparison.OrdinalIgnoreCase)
            && !request.ManagedDistrictId.HasValue)
            throw new ArgumentException("ManagedDistrictId is required for Enterprise");

        if (string.Equals(role.RoleName, "Collector", StringComparison.OrdinalIgnoreCase)
            && !request.EnterpriseId.HasValue)
            throw new ArgumentException("EnterpriseId is required for Collector");

        var user = new User
        {
            Email = request.Email,
            Password = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName,
            Phone = request.Phone,
            RoleId = request.RoleId,
            Status = "Active",
            CreatedAt = DateTime.UtcNow
        };

        await _uow.Users.AddAsync(user);
        await _uow.SaveChangesAsync();

        if (string.Equals(role.RoleName, "Enterprise", StringComparison.OrdinalIgnoreCase))
        {
            _uow.AddEnterpriseProfile(new EnterpriseProfile
            {
                EnterpriseId = user.UserId,
                ManagedDistrictId = request.ManagedDistrictId!.Value,
                CreatedAt = DateTime.UtcNow
            });
        }
        else if (string.Equals(role.RoleName, "Collector", StringComparison.OrdinalIgnoreCase))
        {
            if (!request.EnterpriseId.HasValue)
                throw new ArgumentException("EnterpriseId is required for Collector");

            var enterpriseProfile = await _uow.GetEnterpriseProfileByUserIdAsync(request.EnterpriseId.Value);
            if (enterpriseProfile == null)
                throw new InvalidOperationException("Tài khoản doanh nghiệp của bạn chưa hoàn thiện hồ sơ (EnterpriseProfile), không thể tạo nhân viên trực thuộc.");

            _uow.AddCollectorProfile(new CollectorProfile
            {
                CollectorId = user.UserId,
                EnterpriseId = request.EnterpriseId!.Value,
                IsAvailable = true,
                AvailabilityUpdatedAt = DateTime.UtcNow,
                WarningCount = 0,
                CreatedAt = DateTime.UtcNow
            });
        }

        await _uow.SaveChangesAsync();
        return MapToDto((await _uow.Users.GetByIdAsync(user.UserId))!);
    }

    public async Task<UserResponseDto?> GetByIdAsync(int id)
    {
        var user = await _uow.Users.GetByIdAsync(id);
        return user == null ? null : MapToDto(user);
    }

    public async Task<IEnumerable<UserResponseDto>> GetAllAsync()
    {
        var users = await _uow.Users.GetAllAsync();
        return users.Select(MapToDto);
    }

    public async Task<UserResponseDto> UpdateUserAsync(int id, UpdateUserRequestDto request)
    {
        var user = await _uow.Users.GetByIdAsync(id);
        if (user == null)
            throw new InvalidOperationException("User not found");

        if (!string.IsNullOrWhiteSpace(request.Phone) && request.Phone != user.Phone
            && await _uow.Users.PhoneExistsExceptAsync(request.Phone, id))
            throw new InvalidOperationException("Phone already exists");

        if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != user.Email
            && await _uow.Users.EmailExistsExceptAsync(request.Email, id))
            throw new InvalidOperationException("Email already exists");

        if (!string.IsNullOrWhiteSpace(request.FullName))
            user.FullName = request.FullName;
        if (!string.IsNullOrWhiteSpace(request.Email))
            user.Email = request.Email;
        if (!string.IsNullOrWhiteSpace(request.Phone))
            user.Phone = request.Phone;
        if (!string.IsNullOrWhiteSpace(request.Status))
            user.Status = request.Status;

        var targetRoleId = request.RoleId > 0 ? request.RoleId : user.RoleId;
        var role = _uow.Roles.FirstOrDefault(r => r.RoleId == targetRoleId);
        if (role == null)
            throw new InvalidOperationException("Role not found");

        user.RoleId = targetRoleId;

        if (string.Equals(role.RoleName, "Enterprise", StringComparison.OrdinalIgnoreCase))
        {
            if (!request.ManagedDistrictId.HasValue)
                throw new ArgumentException("ManagedDistrictId is required for Enterprise");

            if (user.CollectorProfile != null)
                _uow.RemoveCollectorProfile(user.CollectorProfile);

            if (user.EnterpriseProfile == null)
                _uow.AddEnterpriseProfile(new EnterpriseProfile { EnterpriseId = user.UserId, ManagedDistrictId = request.ManagedDistrictId.Value, CreatedAt = DateTime.UtcNow });
            else
                user.EnterpriseProfile.ManagedDistrictId = request.ManagedDistrictId.Value;
        }
        else if (string.Equals(role.RoleName, "Collector", StringComparison.OrdinalIgnoreCase))
        {
            if (!request.EnterpriseId.HasValue)
                throw new ArgumentException("EnterpriseId is required for Collector");

            if (user.EnterpriseProfile != null)
                _uow.RemoveEnterpriseProfile(user.EnterpriseProfile);

            if (user.CollectorProfile == null)
                _uow.AddCollectorProfile(new CollectorProfile { CollectorId = user.UserId, EnterpriseId = request.EnterpriseId.Value, IsAvailable = true, AvailabilityUpdatedAt = DateTime.UtcNow, WarningCount = 0, CreatedAt = DateTime.UtcNow });
            else
                user.CollectorProfile.EnterpriseId = request.EnterpriseId.Value;
        }
        else
        {
            if (user.EnterpriseProfile != null)
                _uow.RemoveEnterpriseProfile(user.EnterpriseProfile);
            if (user.CollectorProfile != null)
                _uow.RemoveCollectorProfile(user.CollectorProfile);
        }

        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return MapToDto((await _uow.Users.GetByIdAsync(id))!);
    }

    public async Task<UserResponseDto> SoftDeleteUserAsync(int id)
    {
        var user = await _uow.Users.GetByIdAsync(id) ?? throw new InvalidOperationException("User not found");
        user.Status = "Inactive";
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return MapToDto((await _uow.Users.GetByIdAsync(id))!);
    }

    public async Task<UserResponseDto> ReactivateUserAsync(int id)
    {
        var user = await _uow.Users.GetByIdAsync(id) ?? throw new InvalidOperationException("User not found");
        user.Status = "Active";
        if (user.CollectorProfile != null)
            user.CollectorProfile.WarningCount = 0;
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return MapToDto((await _uow.Users.GetByIdAsync(id))!);
    }

    public async Task DeleteUserAsync(int id)
    {
        var user = await _uow.Users.GetByIdAsync(id) ?? throw new InvalidOperationException("User not found");
        if (user.EnterpriseProfile != null)
            _uow.RemoveEnterpriseProfile(user.EnterpriseProfile);
        if (user.CollectorProfile != null)
            _uow.RemoveCollectorProfile(user.CollectorProfile);
        _uow.Users.Delete(user);
        await _uow.SaveChangesAsync();
    }

    public async Task ChangePasswordAsync(int userId, ChangePasswordDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.OldPassword))
            throw new ArgumentException("Old password is required");
        if (string.IsNullOrWhiteSpace(dto.NewPassword))
            throw new ArgumentException("New password is required");
        if (dto.NewPassword != dto.ConfirmPassword)
            throw new ArgumentException("New password and confirm password do not match");

        var user = await _uow.Users.GetByIdAsync(userId) ?? throw new InvalidOperationException("User not found");
        if (!BCrypt.Net.BCrypt.Verify(dto.OldPassword, user.Password))
            throw new ArgumentException("Old password is incorrect");
        if (BCrypt.Net.BCrypt.Verify(dto.NewPassword, user.Password))
            throw new ArgumentException("New password must be different from old password");

        user.Password = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
    }

    public async Task<UserResponseDto> UpdateCollectorAvailabilityAsync(int userId, bool isAvailable)
    {
        var user = await _uow.Users.GetByIdAsync(userId) ?? throw new InvalidOperationException("User not found");
        if (!string.Equals(user.Role?.RoleName, "Collector", StringComparison.OrdinalIgnoreCase))
            throw new UnauthorizedAccessException("Only collectors can update availability");
        if (user.CollectorProfile == null)
            throw new InvalidOperationException("Collector profile not found");

        user.CollectorProfile.IsAvailable = isAvailable;
        user.CollectorProfile.AvailabilityUpdatedAt = DateTime.UtcNow;
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return MapToDto((await _uow.Users.GetByIdAsync(userId))!);
    }

    public async Task<UserResponseDto> UpdateMyProfileAsync(int userId, UpdateProfileRequestDto request)
    {
        var user = await _uow.Users.GetByIdAsync(userId) ?? throw new InvalidOperationException("User not found");
        if (!string.IsNullOrWhiteSpace(request.Phone) && request.Phone != user.Phone
            && await _uow.Users.PhoneExistsExceptAsync(request.Phone, userId))
            throw new InvalidOperationException("Phone already exists");

        if (!string.IsNullOrWhiteSpace(request.FullName))
            user.FullName = request.FullName;
        if (!string.IsNullOrWhiteSpace(request.Phone))
            user.Phone = request.Phone;

        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return MapToDto((await _uow.Users.GetByIdAsync(userId))!);
    }

    public async Task<Contracts.UserDto?> GetInternalUserAsync(int userId)
    {
        var user = await _uow.Users.GetByIdAsync(userId);
        return user == null ? null : MapToContract(user);
    }

    public async Task<EnterpriseProfileDto?> GetEnterpriseProfileAsync(int enterpriseId)
    {
        var user = await _uow.Users.GetByIdAsync(enterpriseId);
        return user?.EnterpriseProfile == null ? null : new EnterpriseProfileDto
        {
            EnterpriseId = user.UserId,
            ManagedDistrictId = user.EnterpriseProfile.ManagedDistrictId,
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone
        };
    }

    public async Task<EnterpriseProfileDto?> GetEnterpriseByDistrictAsync(int districtId)
    {
        var enterprises = await _uow.Users.GetUsersByRoleAsync("Enterprise");
        var user = enterprises.FirstOrDefault(e => e.EnterpriseProfile?.ManagedDistrictId == districtId);
        return user == null ? null : new EnterpriseProfileDto
        {
            EnterpriseId = user.UserId,
            ManagedDistrictId = user.EnterpriseProfile!.ManagedDistrictId,
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone
        };
    }

    public async Task<CollectorProfileDto?> GetCollectorProfileAsync(int collectorId)
    {
        var user = await _uow.Users.GetByIdAsync(collectorId);
        return user?.CollectorProfile == null ? null : MapCollector(user);
    }

    public async Task<IEnumerable<CollectorProfileDto>> GetCollectorsByEnterpriseAsync(int enterpriseId)
    {
        var collectors = await _uow.Users.GetCollectorsByEnterpriseAsync(enterpriseId);
        return collectors.Select(MapCollector);
    }

    public async Task<IEnumerable<UserResponseDto>> GetCollectorsByEnterpriseAsUserDtoAsync(int enterpriseId)
    {
        var collectors = await _uow.Users.GetCollectorsByEnterpriseAsync(enterpriseId);
        return collectors.Select(MapToDto);
    }

    public async Task<int> AddPointsAsync(int userId, int points)
    {
        if (points < 0)
            throw new ArgumentException("Points must be positive");
        var user = await _uow.Users.GetByIdAsync(userId) ?? throw new InvalidOperationException("User not found");
        user.TotalPoints += points;
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return user.TotalPoints;
    }

    public async Task<int> DeductPointsAsync(int userId, int points)
    {
        if (points < 0)
            throw new ArgumentException("Points must be positive");
        var user = await _uow.Users.GetByIdAsync(userId) ?? throw new InvalidOperationException("User not found");
        if (user.TotalPoints < points)
            throw new InvalidOperationException("Not enough points");
        user.TotalPoints -= points;
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return user.TotalPoints;
    }

    public async Task<CollectorProfileDto> AddCollectorWarningAsync(int collectorId, int points)
    {
        var user = await _uow.Users.GetByIdAsync(collectorId) ?? throw new InvalidOperationException("Collector not found");
        if (user.CollectorProfile == null)
            throw new InvalidOperationException("Collector profile not found");

        user.CollectorProfile.WarningCount += points;
        if (user.CollectorProfile.WarningCount >= WarningThreshold)
            user.Status = "Inactive";

        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        return MapCollector((await _uow.Users.GetByIdAsync(collectorId))!);
    }

    public async Task<IdentityDashboardStatsDto> GetDashboardStatsAsync(int year)
    {
        var users = (await _uow.Users.GetAllAsync()).ToList();
        var monthNames = CultureInfo.InvariantCulture.DateTimeFormat.AbbreviatedMonthNames;
        var byRole = users.GroupBy(u => u.Role.RoleName).ToDictionary(g => g.Key, g => g.Count());
        var regs = users
            .Where(u => u.CreatedAt.HasValue && u.CreatedAt.Value.Year == year)
            .GroupBy(u => u.CreatedAt!.Value.Month)
            .ToDictionary(g => g.Key, g => g.Count());

        return new IdentityDashboardStatsDto
        {
            TotalUsers = users.Count,
            TotalCitizens = byRole.GetValueOrDefault("Citizen"),
            TotalEnterprises = byRole.GetValueOrDefault("Enterprise"),
            TotalCollectors = byRole.GetValueOrDefault("Collector"),
            UserRegistrationsByMonth = Enumerable.Range(1, 12).Select(m => new MonthlyCountDto
            {
                Month = m,
                MonthName = monthNames[m - 1],
                Count = regs.GetValueOrDefault(m)
            }).ToList()
        };
    }

    public Task<int> GetCollectorRoleIdAsync()
    {
        var collectorRole = _uow.Roles.FirstOrDefault(r => r.RoleName.ToLower() == "collector");
        return Task.FromResult(collectorRole?.RoleId ?? 0);
    }

    private static UserResponseDto MapToDto(User user) => new()
    {
        UserId = user.UserId,
        RoleId = user.RoleId,
        Email = user.Email,
        FullName = user.FullName,
        Phone = user.Phone ?? string.Empty,
        RoleName = user.Role?.RoleName ?? string.Empty,
        Status = user.Status ?? string.Empty,
        CreatedAt = user.CreatedAt,
        IsAvailable = user.CollectorProfile?.IsAvailable ?? false,
        AvailabilityUpdatedAt = user.CollectorProfile?.AvailabilityUpdatedAt,
        ManagedDistrictId = user.EnterpriseProfile?.ManagedDistrictId,
        EnterpriseId = user.CollectorProfile?.EnterpriseId
    };

    private static Contracts.UserDto MapToContract(User user) => new()
    {
        UserId = user.UserId,
        RoleId = user.RoleId,
        RoleName = user.Role?.RoleName ?? string.Empty,
        FullName = user.FullName,
        Email = user.Email,
        Phone = user.Phone,
        Status = user.Status ?? string.Empty,
        TotalPoints = user.TotalPoints,
        ManagedDistrictId = user.EnterpriseProfile?.ManagedDistrictId,
        EnterpriseId = user.CollectorProfile?.EnterpriseId,
        IsAvailable = user.CollectorProfile?.IsAvailable,
        WarningCount = user.CollectorProfile?.WarningCount
    };

    private static CollectorProfileDto MapCollector(User user) => new()
    {
        CollectorId = user.UserId,
        EnterpriseId = user.CollectorProfile?.EnterpriseId ?? 0,
        FullName = user.FullName,
        Email = user.Email,
        Phone = user.Phone,
        IsAvailable = user.CollectorProfile?.IsAvailable ?? false,
        WarningCount = user.CollectorProfile?.WarningCount ?? 0,
        Status = user.Status ?? string.Empty
    };
}
