using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace WasteReportService.Application.Clients;

public sealed class AiPredictionClient : IAiPredictionClient
{
    private readonly HttpClient _httpClient;

    public AiPredictionClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<AiPredictionResult?> PredictAsync(string imageFilePath, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(imageFilePath) || !File.Exists(imageFilePath))
            return null;

        await using var stream = File.OpenRead(imageFilePath);
        using var content = new MultipartFormDataContent();
        using var imageContent = new StreamContent(stream);
        imageContent.Headers.ContentType = new MediaTypeHeaderValue(GetContentType(imageFilePath));
        content.Add(imageContent, "file", Path.GetFileName(imageFilePath));

        var response = await _httpClient.PostAsync("/predict", content, cancellationToken);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AiPredictionResult>(cancellationToken: cancellationToken);
    }

    private static string GetContentType(string imageFilePath)
    {
        var ext = Path.GetExtension(imageFilePath).ToLowerInvariant();
        return ext switch
        {
            ".png" => "image/png",
            ".webp" => "image/webp",
            ".gif" => "image/gif",
            _ => "image/jpeg",
        };
    }
}
