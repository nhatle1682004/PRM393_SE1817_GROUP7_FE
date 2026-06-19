namespace WasteReportService.Domain.Entities;

public sealed class AiWastePrediction
{
    public int PredictionId { get; set; }
    public int ReportId { get; set; }
    public string? SuggestedType { get; set; }
    public decimal? Confidence { get; set; }
    public DateTime? CreatedAt { get; set; }
    public WasteReport Report { get; set; } = null!;
}
