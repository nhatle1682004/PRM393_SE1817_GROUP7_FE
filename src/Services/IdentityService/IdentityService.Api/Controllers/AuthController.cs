using IdentityService.Application.DTOs.Auth;
using IdentityService.Application.DTOs.User;
using IdentityService.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.Api.Controllers;

[Route("api/auth")]
[ApiController]
public sealed class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IUserService _userService;

    public AuthController(IAuthService authService, IUserService userService)
    {
        _authService = authService;
        _userService = userService;
    }

    public sealed class LoginRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        var user = _authService.Authenticate(request.Email, request.Password);
        if (user == null)
            return Unauthorized(new { message = "Incorrect email or password." });

        var token = _authService.GenerateJwtToken(user);
        return Ok(new
        {
            message = "Login successful",
            token,
            user = new { user.UserId, user.FullName, user.Email, user.RoleId }
        });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequestDto request)
    {
        await _authService.RegisterCitizenAsync(request);
        return Ok(new { message = "OTP sent to email" });
    }

    [HttpPost("verify-otp")]
    public async Task<IActionResult> VerifyOtp(VerifyOtpRequestDto request)
    {
        var user = await _authService.VerifyOtpAndCreateUserAsync(request.Email, request.Otp);
        return Ok(new { message = "Register successful", user.UserId });
    }

    [HttpPut("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new { message = "Invalid or missing UserId claim" });

        try
        {
            await _userService.ChangePasswordAsync(userId, dto);
            return Ok(new { message = "Password changed successfully" });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequestDto request)
    {
        try
        {
            await _authService.ForgotPasswordAsync(request);
            return Ok(new { message = "OTP has been sent to your email" });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequestDto request)
    {
        try
        {
            await _authService.ResetPasswordAsync(request);
            return Ok(new { message = "Password has been reset successfully" });
        }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out int userId)
    {
        var claim = User.FindFirst("UserId")?.Value;
        return int.TryParse(claim, out userId);
    }
}
