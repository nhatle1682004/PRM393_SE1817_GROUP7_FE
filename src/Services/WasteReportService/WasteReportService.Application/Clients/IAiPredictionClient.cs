namespace WasteReportService.Application.Clients;

public interface IAiPredictionClient
{
    Task<AiPredictionResult?> PredictAsync(string imageFilePath, CancellationToken cancellationToken = default);
}

public sealed class AiPredictionResult
{
    public string? Label { get; set; }
    public decimal Confidence { get; set; }
}
