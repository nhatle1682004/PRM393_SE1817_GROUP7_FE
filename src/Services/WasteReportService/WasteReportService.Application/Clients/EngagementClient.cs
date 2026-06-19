using Contracts;
using System.Net.Http.Json;

namespace WasteReportService.Application.Clients;

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
}
