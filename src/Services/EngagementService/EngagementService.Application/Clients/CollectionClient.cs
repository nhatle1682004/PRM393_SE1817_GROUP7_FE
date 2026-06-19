using Contracts;
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
        => _httpClient.GetFromJsonAsync<CollectionFeedbackContextDto>($"/internal/collection/feedback-context/by-report/{reportId}");

    public async Task CancelAssignmentForComplaintAsync(CancelAssignmentForComplaintRequest request)
    {
        var response = await _httpClient.PutAsJsonAsync("/internal/collection/assignments/cancel-for-complaint", request);
        response.EnsureSuccessStatusCode();
    }

    public Task<CollectionDashboardStatsDto?> GetDashboardStatsAsync()
        => _httpClient.GetFromJsonAsync<CollectionDashboardStatsDto>("/internal/collection/dashboard");
}
