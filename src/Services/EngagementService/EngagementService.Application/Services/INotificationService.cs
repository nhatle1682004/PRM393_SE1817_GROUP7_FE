using Contracts;

namespace EngagementService.Application.Services;

public interface INotificationService
{
    Task<IEnumerable<EngagementService.Application.DTOs.Notification.NotificationDto>> GetUserNotificationsAsync(int userId);
    Task MarkAsReadAsync(int notificationId, int userId);
    Task MarkAllAsReadAsync(int userId);
    Task<Contracts.NotificationDto> CreateAsync(CreateNotificationRequest request);
}
