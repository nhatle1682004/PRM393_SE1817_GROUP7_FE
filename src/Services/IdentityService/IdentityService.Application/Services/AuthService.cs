using IdentityService.Application.CacheModels;
using IdentityService.Application.DTOs.Auth;
using IdentityService.Application.Repositories;
using IdentityService.Domain.Entities;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace IdentityService.Application.Services;

public sealed class AuthService : IAuthService
{
    private readonly IIdentityUnitOfWork _uow;
    private readonly IConfiguration _configuration;
    private readonly IMemoryCache _cache;
    private readonly IEmailService _emailService;

    public AuthService(
        IIdentityUnitOfWork uow,
        IConfiguration configuration,
        IMemoryCache cache,
        IEmailService emailService)
    {
        _uow = uow;
        _configuration = configuration;
        _cache = cache;
        _emailService = emailService;
    }

    public async Task RegisterCitizenAsync(RegisterRequestDto request)
    {
        if (request.Password != request.ConfirmPassword)
            throw new ArgumentException("Password confirmation does not match");

        if (await _uow.Users.EmailExistsAsync(request.Email))
            throw new InvalidOperationException("Email already exists");

        var otp = new Random().Next(100000, 999999).ToString();
        _cache.Set($"OTP_{request.Email}", new RegisterCacheModel
        {
            Otp = otp,
            Email = request.Email,
            Password = request.Password,
            FullName = request.FullName
        }, TimeSpan.FromMinutes(5));

        var html = LoadEmailTemplate("OtpVerification.html")
            .Replace("{{FullName}}", request.FullName)
            .Replace("{{OTP}}", otp);

        await _emailService.SendEmailAsync(request.Email, "Xac minh dang ky", html, isHtml: true);
    }

    public async Task<User> VerifyOtpAndCreateUserAsync(string email, string otp)
    {
        if (await _uow.Users.EmailExistsAsync(email))
            throw new InvalidOperationException("User already registered");

        if (!_cache.TryGetValue($"OTP_{email}", out RegisterCacheModel? cached) || cached == null)
            throw new InvalidOperationException("OTP expired or not found");

        if (cached.Otp != otp)
            throw new InvalidOperationException("Invalid OTP");

        var user = new User
        {
            Email = cached.Email,
            FullName = cached.FullName,
            Password = BCrypt.Net.BCrypt.HashPassword(cached.Password),
            RoleId = 1,
            Status = "Active",
            CreatedAt = DateTime.UtcNow
        };

        await _uow.Users.AddAsync(user);
        await _uow.SaveChangesAsync();
        _cache.Remove($"OTP_{email}");
        return user;
    }

    public User? Authenticate(string email, string password)
    {
        var user = _uow.Users.GetByEmailAsync(email).GetAwaiter().GetResult();
        if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.Password))
            return null;

        return user.Status == "Active" ? user : null;
    }

    public string GenerateJwtToken(User user)
    {
        var jwtSettings = _configuration.GetSection("Jwt");
        var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);
        var roleName = user.Role?.RoleName ?? _uow.Roles.FirstOrDefault(r => r.RoleId == user.RoleId)?.RoleName ?? string.Empty;

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Email),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim("UserId", user.UserId.ToString()),
            new Claim("FullName", user.FullName),
            new Claim("RoleId", user.RoleId.ToString()),
            new Claim(ClaimTypes.Role, roleName)
        };

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(3),
            signingCredentials: new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256));

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public async Task ForgotPasswordAsync(ForgotPasswordRequestDto request)
    {
        var user = await _uow.Users.GetByEmailAsync(request.Email);
        if (user == null)
            throw new InvalidOperationException("Email not found");

        var otp = new Random().Next(100000, 999999).ToString();
        _cache.Set($"RESET_PASSWORD_OTP_{request.Email}", otp, TimeSpan.FromMinutes(5));

        var html = LoadEmailTemplate("OtpVerification.html")
            .Replace("{{FullName}}", user.FullName)
            .Replace("{{OTP}}", otp);

        await _emailService.SendEmailAsync(request.Email, "Reset Password OTP", html, isHtml: true);
    }

    public async Task ResetPasswordAsync(ResetPasswordRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.NewPassword))
            throw new ArgumentException("New password is required");

        if (request.NewPassword != request.ConfirmPassword)
            throw new ArgumentException("New password and confirm password do not match");

        if (!_cache.TryGetValue($"RESET_PASSWORD_OTP_{request.Email}", out string? cachedOtp) || cachedOtp == null)
            throw new InvalidOperationException("OTP expired or not found");

        if (cachedOtp != request.Otp)
            throw new InvalidOperationException("Invalid OTP");

        var user = await _uow.Users.GetByEmailAsync(request.Email);
        if (user == null)
            throw new InvalidOperationException("User not found");

        user.Password = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        _uow.Users.Update(user);
        await _uow.SaveChangesAsync();
        _cache.Remove($"RESET_PASSWORD_OTP_{request.Email}");
    }

    private static string LoadEmailTemplate(string fileName)
    {
        var outputPath = Path.Combine(AppContext.BaseDirectory, "EmailTemplates", fileName);
        var workingDirectoryPath = Path.Combine(Directory.GetCurrentDirectory(), "EmailTemplates", fileName);
        var path = File.Exists(outputPath) ? outputPath : workingDirectoryPath;
        if (!File.Exists(path))
            throw new FileNotFoundException($"Email template not found. Checked: {outputPath}; {workingDirectoryPath}");

        return File.ReadAllText(path);
    }
}
