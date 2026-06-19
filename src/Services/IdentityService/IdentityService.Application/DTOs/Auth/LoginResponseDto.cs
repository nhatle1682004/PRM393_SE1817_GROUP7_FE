using IdentityService.Application.DTOs.User;

namespace IdentityService.Application.DTOs.Auth
{
    public class LoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public UserDto User { get; set; } = null!;
    }
}
