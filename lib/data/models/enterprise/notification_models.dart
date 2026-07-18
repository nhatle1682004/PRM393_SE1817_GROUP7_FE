part of '../enterprise_models.dart';

class EnterpriseNotification {
  final int notificationId;
  final String? title;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  EnterpriseNotification({required this.notificationId, this.title, required this.content, this.isRead = false, this.createdAt});

  factory EnterpriseNotification.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseNotification(notificationId: 0, content: '');
    int toInt(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return EnterpriseNotification(notificationId: toInt(json['notificationId'] ?? json['id']), title: json['title'], content: json['content'] ?? json['message'] ?? '', isRead: json['isRead'] ?? false, createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null);
  }

  EnterpriseNotification copyWith({int? notificationId, String? title, String? content, bool? isRead, DateTime? createdAt}) => EnterpriseNotification(notificationId: notificationId ?? this.notificationId, title: title ?? this.title, content: content ?? this.content, isRead: isRead ?? this.isRead, createdAt: createdAt ?? this.createdAt);
}
