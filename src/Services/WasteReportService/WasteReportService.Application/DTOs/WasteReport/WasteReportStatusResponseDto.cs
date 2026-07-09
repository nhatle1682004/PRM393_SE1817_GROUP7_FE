namespace WasteReportService.Application.DTOs.WasteReport
{
    public class WasteReportStatusResponseDto
    {
        public int Id { get; set; }
        public string Status { get; set; } = string.Empty;
        public int? RequestId { get; set; }
    }
}

