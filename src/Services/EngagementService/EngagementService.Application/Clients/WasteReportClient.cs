using Contracts;
using System.Net;
using System.Net.Http.Json;

namespace EngagementService.Application.Clients;

public sealed class WasteReportClient : IWasteReportClient
{
    private readonly HttpClient _httpClient;

    public WasteReportClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<WasteReportDto?> GetReportAsync(int reportId) => GetOrNullAsync<WasteReportDto>($"/internal/waste/reports/{reportId}");

    public Task<IEnumerable<WasteReportDto>> GetReportsByDistrictAsync(int districtId) =>
        GetListAsync<WasteReportDto>($"/internal/waste/reports/by-district/{districtId}");

    public async Task UpdateReportStatusAsync(int reportId, string status)
    {
        var response = await _httpClient.PutAsJsonAsync($"/internal/waste/reports/{reportId}/status", new WasteReportStatusUpdateRequest { Status = status });
        response.EnsureSuccessStatusCode();
    }

    public Task<WasteDashboardStatsDto?> GetDashboardStatsAsync(int year) => GetOrNullAsync<WasteDashboardStatsDto>($"/internal/waste/dashboard/{year}");

    private async Task<T?> GetOrNullAsync<T>(string url)
    {
        var response = await _httpClient.GetAsync(url);
        if (response.StatusCode == HttpStatusCode.NotFound)
            return default;

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<T>();
    }

    private async Task<IEnumerable<T>> GetListAsync<T>(string url)
    {
        var response = await _httpClient.GetAsync(url);
        if (response.StatusCode == HttpStatusCode.NotFound)
            return Enumerable.Empty<T>();

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<IEnumerable<T>>() ?? Enumerable.Empty<T>();
    }
}
