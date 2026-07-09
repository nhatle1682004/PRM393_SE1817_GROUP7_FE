namespace IdentityService.Application.DTOs.User
{
    public class UserDto
    {
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string RoleName { get; set; } = string.Empty;
        public int? ManagedDistrictId { get; set; }
        public int? EnterpriseId { get; set; }
    }
}
