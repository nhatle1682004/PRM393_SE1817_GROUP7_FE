using EngagementService.Application.DTOs.Feedback;

namespace EngagementService.Application.Services;

public interface IFeedbackService
{
    Task<FeedbackResponseDto> CreateFeedbackAsync(int userId, CreateFeedbackDto dto);
    Task<IEnumerable<FeedbackResponseDto>> GetFeedbacksByReportIdAsync(int reportId);
    Task<IEnumerable<FeedbackResponseDto>> GetAllFeedbacksAsync(int? districtId = null, int? requesterId = null);
    Task<FeedbackDetailDto> GetFeedbackDetailAsync(int feedbackId, int? requesterId = null);
    Task<FeedbackResponseDto> ResolveFeedbackAsync(int feedbackId, ResolveFeedbackDto dto, int? requesterId = null);
    Task<FeedbackResponseDto> RejectFeedbackAsync(int feedbackId, int? requesterId = null);
}
