using Contracts;
using System.Net;
using System.Net.Http.Json;

namespace CollectionService.Application.Clients;

public sealed class WasteReportClient : IWasteReportClient
{
    private readonly HttpClient _httpClient;

    public WasteReportClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<WasteReportDto?> GetReportAsync(int reportId) => GetOrNullAsync<WasteReportDto>($"/internal/waste/reports/{reportId}");
    public Task<WasteTypeDto?> GetWasteTypeAsync(int wasteTypeId) => GetOrNullAsync<WasteTypeDto>($"/internal/waste/waste-types/{wasteTypeId}");

    public async Task UpdateReportStatusAsync(int reportId, string status)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/waste/reports/{reportId}/status", new WasteReportStatusUpdateRequest { Status = status });
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
