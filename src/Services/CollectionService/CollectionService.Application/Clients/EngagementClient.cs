using Contracts;
using System.Net.Http.Json;

namespace CollectionService.Application.Clients;

public sealed class EngagementClient : IEngagementClient
{
    private readonly HttpClient _httpClient;

    public EngagementClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task CreateNotificationAsync(CreateNotificationRequest request)
    {
        var response = await _httpClient.PostAsJsonAsync("/internal/engagement/notifications", request);
        response.EnsureSuccessStatusCode();
    }

    public async Task CreateRewardTransactionAsync(CreateRewardTransactionRequest request)
    {
        var response = await _httpClient.PostAsJsonAsync("/internal/engagement/reward-transactions", request);
        response.EnsureSuccessStatusCode();
    }
}
