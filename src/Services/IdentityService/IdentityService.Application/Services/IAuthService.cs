using IdentityService.Application.DTOs.Auth;
using IdentityService.Domain.Entities;

namespace IdentityService.Application.Services;

public interface IAuthService
{
    Task RegisterCitizenAsync(RegisterRequestDto request);
    Task<User> VerifyOtpAndCreateUserAsync(string email, string otp);
    User? Authenticate(string email, string password);
    Task<string> GenerateJwtToken(User user);
    Task ForgotPasswordAsync(ForgotPasswordRequestDto request);
    Task ResetPasswordAsync(ResetPasswordRequestDto request);
}
