using Contracts;
using System.Net;
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
        return await GetOrNullAsync<UserDto>($"/internal/identity/users/{userId}");
    }

    public async Task<EnterpriseProfileDto?> GetEnterpriseAsync(int enterpriseId)
    {
        return await GetOrNullAsync<EnterpriseProfileDto>($"/internal/identity/enterprises/{enterpriseId}");
    }

    public async Task<EnterpriseProfileDto?> GetEnterpriseByDistrictAsync(int districtId)
    {
        return await GetOrNullAsync<EnterpriseProfileDto>($"/internal/identity/enterprises/by-district/{districtId}");
    }

    private async Task<T?> GetOrNullAsync<T>(string url)
    {
        var response = await _httpClient.GetAsync(url);
        if (response.StatusCode == HttpStatusCode.NotFound)
            return default;

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<T>();
    }
}
