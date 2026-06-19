using Contracts;
using System.Net.Http.Json;

namespace CollectionService.Application.Clients;

public sealed class WasteReportClient : IWasteReportClient
{
    private readonly HttpClient _httpClient;

    public WasteReportClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<WasteReportDto?> GetReportAsync(int reportId) => _httpClient.GetFromJsonAsync<WasteReportDto>($"/internal/waste/reports/{reportId}");
    public Task<WasteTypeDto?> GetWasteTypeAsync(int wasteTypeId) => _httpClient.GetFromJsonAsync<WasteTypeDto>($"/internal/waste/waste-types/{wasteTypeId}");

    public async Task UpdateReportStatusAsync(int reportId, string status)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/waste/reports/{reportId}/status", new WasteReportStatusUpdateRequest { Status = status });
        response.EnsureSuccessStatusCode();
    }
}
