import 'json_helpers.dart';

class NotificationItem {
  final int notificationId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationItem({
    this.notificationId = 0,
    this.title = '',
    this.message = '',
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: JsonHelpers.intValue(json, [
        'notificationId',
        'NotificationId',
        'id',
        'Id',
      ]),
      title: JsonHelpers.stringValue(json, ['title', 'Title']),
      message: JsonHelpers.stringValue(json, [
        'message',
        'Message',
        'content',
        'Content',
      ]),
      isRead: JsonHelpers.boolValue(json, ['isRead', 'IsRead']),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
    );
  }
}
