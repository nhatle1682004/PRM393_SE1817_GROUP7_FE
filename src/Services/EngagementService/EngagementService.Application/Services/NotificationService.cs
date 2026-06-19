using Contracts;
using EngagementService.Application.DTOs.Notification;
using EngagementService.Application.Repositories;
using EngagementService.Domain.Entities;

namespace EngagementService.Application.Services;

public sealed class NotificationService : INotificationService
{
    private readonly IEngagementUnitOfWork _uow;

    public NotificationService(IEngagementUnitOfWork uow)
    {
        _uow = uow;
    }

    public Task<IEnumerable<EngagementService.Application.DTOs.Notification.NotificationDto>> GetUserNotificationsAsync(int userId)
    {
        var notifications = _uow.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .AsEnumerable()
            .Select(ToDto);

        return Task.FromResult(notifications);
    }

    public async Task MarkAsReadAsync(int notificationId, int userId)
    {
        var notification = _uow.Notifications.FirstOrDefault(n => n.NotificationId == notificationId);
        if (notification != null && notification.UserId == userId)
        {
            notification.IsRead = true;
            _uow.UpdateNotification(notification);
            await _uow.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsReadAsync(int userId)
    {
        var unread = _uow.Notifications.Where(n => n.UserId == userId && (n.IsRead == false || n.IsRead == null)).ToList();
        foreach (var n in unread)
        {
            n.IsRead = true;
            _uow.UpdateNotification(n);
        }
        await _uow.SaveChangesAsync();
    }

    public async Task<Contracts.NotificationDto> CreateAsync(CreateNotificationRequest request)
    {
        var notification = new Notification
        {
            UserId = request.UserId,
            Content = request.Content,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };
        await _uow.AddNotificationAsync(notification);
        await _uow.SaveChangesAsync();
        return new Contracts.NotificationDto
        {
            NotificationId = notification.NotificationId,
            UserId = notification.UserId,
            Content = notification.Content ?? string.Empty,
            IsRead = notification.IsRead ?? false,
            CreatedAt = notification.CreatedAt
        };
    }

    private static EngagementService.Application.DTOs.Notification.NotificationDto ToDto(Notification n) => new()
    {
        NotificationId = n.NotificationId,
        UserId = n.UserId,
        Content = n.Content ?? string.Empty,
        IsRead = n.IsRead ?? false,
        CreatedAt = n.CreatedAt
    };
}
