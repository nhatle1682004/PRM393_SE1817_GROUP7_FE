using Contracts;
using System.Net.Http.Json;

namespace WasteReportService.Application.Clients;

public sealed class CollectionClient : ICollectionClient
{
    private readonly HttpClient _httpClient;

    public CollectionClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<CollectionRequestDto?> CreateFromReportAsync(CreateCollectionRequestFromReportRequest request)
    {
        var response = await _httpClient.PostAsJsonAsync("/internal/collection/requests/from-report", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CollectionRequestDto>();
    }

    public async Task DeleteRequestByReportIdAsync(int reportId)
    {
        var response = await _httpClient.DeleteAsync($"/internal/collection/requests/by-report/{reportId}");
        response.EnsureSuccessStatusCode();
    }

    public async Task<CollectionFeedbackContextDto?> GetFeedbackContextAsync(int reportId)
    {
        return await _httpClient.GetFromJsonAsync<CollectionFeedbackContextDto>($"/internal/collection/feedback-context/by-report/{reportId}");
    }
}
