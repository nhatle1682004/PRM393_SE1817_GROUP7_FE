using Contracts;
using System.Net;
using System.Net.Http.Json;

namespace CollectionService.Application.Clients;

public sealed class IdentityClient : IIdentityClient
{
    private readonly HttpClient _httpClient;

    public IdentityClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<UserDto?> GetUserAsync(int userId) => GetOrNullAsync<UserDto>($"/internal/identity/users/{userId}");
    public Task<CollectorProfileDto?> GetCollectorAsync(int collectorId) => GetOrNullAsync<CollectorProfileDto>($"/internal/identity/collectors/{collectorId}");
    public async Task<IEnumerable<CollectorProfileDto>> GetCollectorsByEnterpriseAsync(int enterpriseId)
        => await GetOrNullAsync<List<CollectorProfileDto>>($"/internal/identity/collectors/by-enterprise/{enterpriseId}") ?? new List<CollectorProfileDto>();

    public async Task UpdateCollectorAvailabilityAsync(int collectorId, bool isAvailable)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/identity/collectors/{collectorId}/availability", isAvailable);
        response.EnsureSuccessStatusCode();
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
