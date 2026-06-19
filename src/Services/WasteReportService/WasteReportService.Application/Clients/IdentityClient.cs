using Contracts;
using System.Net.Http.Json;

namespace WasteReportService.Application.Clients;

public sealed class IdentityClient : IIdentityClient
{
    private readonly HttpClient _httpClient;

    public IdentityClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<UserDto?> GetUserAsync(int userId)
    {
        return await _httpClient.GetFromJsonAsync<UserDto>($"/internal/identity/users/{userId}");
    }

    public async Task<EnterpriseProfileDto?> GetEnterpriseAsync(int enterpriseId)
    {
        return await _httpClient.GetFromJsonAsync<EnterpriseProfileDto>($"/internal/identity/enterprises/{enterpriseId}");
    }

    public async Task<EnterpriseProfileDto?> GetEnterpriseByDistrictAsync(int districtId)
    {
        return await _httpClient.GetFromJsonAsync<EnterpriseProfileDto>($"/internal/identity/enterprises/by-district/{districtId}");
    }
}
