using Contracts;
using System.Net.Http.Json;

namespace EngagementService.Application.Clients;

public sealed class IdentityClient : IIdentityClient
{
    private readonly HttpClient _httpClient;

    public IdentityClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<UserDto?> GetUserAsync(int userId) => _httpClient.GetFromJsonAsync<UserDto>($"/internal/identity/users/{userId}");

    public async Task<int> AddPointsAsync(int userId, int points, string reason)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/identity/users/{userId}/points/add", new PointAdjustmentRequest { Points = points, Reason = reason });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<PointBalanceResponse>())?.TotalPoints ?? 0;
    }

    public async Task<int> DeductPointsAsync(int userId, int points, string reason)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/identity/users/{userId}/points/deduct", new PointAdjustmentRequest { Points = points, Reason = reason });
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<PointBalanceResponse>())?.TotalPoints ?? 0;
    }

    public async Task<CollectorProfileDto?> AddCollectorWarningAsync(int collectorId, int points, string reason)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/identity/collectors/{collectorId}/warnings", new WarningAdjustmentRequest { Warnings = points, Reason = reason });
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CollectorProfileDto>();
    }

    public Task<IdentityDashboardStatsDto?> GetDashboardStatsAsync(int year) => _httpClient.GetFromJsonAsync<IdentityDashboardStatsDto>($"/internal/identity/dashboard/{year}");

    private sealed class PointBalanceResponse
    {
        public int TotalPoints { get; set; }
    }
}
