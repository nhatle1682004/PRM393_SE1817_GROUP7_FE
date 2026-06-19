using Contracts;

namespace WasteReportService.Application.Clients;

public interface IIdentityClient
{
    Task<UserDto?> GetUserAsync(int userId);
    Task<EnterpriseProfileDto?> GetEnterpriseAsync(int enterpriseId);
    Task<EnterpriseProfileDto?> GetEnterpriseByDistrictAsync(int districtId);
}
