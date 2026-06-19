using Contracts;
using System.Net.Http.Json;

namespace CollectionService.Application.Clients;

public sealed class IdentityClient : IIdentityClient
{
    private readonly HttpClient _httpClient;

    public IdentityClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<UserDto?> GetUserAsync(int userId) => _httpClient.GetFromJsonAsync<UserDto>($"/internal/identity/users/{userId}");
    public Task<CollectorProfileDto?> GetCollectorAsync(int collectorId) => _httpClient.GetFromJsonAsync<CollectorProfileDto>($"/internal/identity/collectors/{collectorId}");
    public async Task<IEnumerable<CollectorProfileDto>> GetCollectorsByEnterpriseAsync(int enterpriseId)
        => await _httpClient.GetFromJsonAsync<List<CollectorProfileDto>>($"/internal/identity/collectors/by-enterprise/{enterpriseId}") ?? new List<CollectorProfileDto>();
}
