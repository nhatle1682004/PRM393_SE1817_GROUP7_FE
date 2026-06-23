using Contracts;
using System.Net;
using System.Net.Http.Json;

namespace EngagementService.Application.Clients;

public sealed class CollectionClient : ICollectionClient
{
    private readonly HttpClient _httpClient;

    public CollectionClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<CollectionFeedbackContextDto?> GetFeedbackContextByReportAsync(int reportId)
        => GetOrNullAsync<CollectionFeedbackContextDto>($"/internal/collection/feedback-context/by-report/{reportId}");

    public async Task CancelAssignmentForComplaintAsync(CancelAssignmentForComplaintRequest request)
    {
        var response = await _httpClient.PutAsJsonAsync("/internal/collection/assignments/cancel-for-complaint", request);
        response.EnsureSuccessStatusCode();
    }

    public Task<CollectionDashboardStatsDto?> GetDashboardStatsAsync()
        => GetOrNullAsync<CollectionDashboardStatsDto>("/internal/collection/dashboard");

    private async Task<T?> GetOrNullAsync<T>(string url)
    {
        var response = await _httpClient.GetAsync(url);
        if (response.StatusCode == HttpStatusCode.NotFound)
            return default;

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<T>();
    }
}
