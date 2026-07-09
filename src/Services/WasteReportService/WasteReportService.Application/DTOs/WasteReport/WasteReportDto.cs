namespace WasteReportService.Application.DTOs.WasteReport
{
    public class WasteReportDto
    {
        public int ReportId { get; set; }
        public int SubmittedBy { get; set; }
        public string SubmittedByName { get; set; } = string.Empty;
        public List<int> WasteTypeIds { get; set; } = new List<int>();
        public List<string> WasteTypeNames { get; set; } = new List<string>();
        public string ImageUrl { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string? Description { get; set; }
        public string? EstimatedSize { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime? CreatedAt { get; set; }
        public int? RequestId { get; set; }
        public int? AssignmentId { get; set; }
        public int? CollectorId { get; set; }
        public string? CollectorName { get; set; }
        public List<AiPredictionDto> AiPredictions { get; set; } = new();
    }

    public class AiPredictionDto
    {
        public string? SuggestedType { get; set; }
        public decimal? Confidence { get; set; }
    }
}
