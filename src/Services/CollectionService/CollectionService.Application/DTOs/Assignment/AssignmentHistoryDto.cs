namespace CollectionService.Application.DTOs.Assignment
{
    /// <summary>
    /// DTO for assignment history timeline
    /// </summary>
    public class AssignmentHistoryDto
    {
        public int AssignmentId { get; set; }
        public int AssignedCollector { get; set; }
        public string? CollectorName { get; set; }
        public string? CollectorPhone { get; set; }
        public int AssignedBy { get; set; }
        public string? AssignedByName { get; set; }
        public string? Status { get; set; }
        public DateTime? AssignedAt { get; set; }
        public DateTime? StartedAt { get; set; }
        public DateTime? ArrivedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public string? BeforeImageUrl { get; set; }
        public string? AfterImageUrl { get; set; }
        public string? ConfirmationNote { get; set; }
        public List<CollectionDetailHistoryDto>? CollectionDetails { get; set; }
    }

    public class CollectionDetailHistoryDto
    {
        public int WasteTypeId { get; set; }
        public string? WasteTypeName { get; set; }
        public decimal ActualWeight { get; set; }
    }
}
