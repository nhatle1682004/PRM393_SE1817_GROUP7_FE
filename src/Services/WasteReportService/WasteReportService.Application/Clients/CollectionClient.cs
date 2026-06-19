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
}
