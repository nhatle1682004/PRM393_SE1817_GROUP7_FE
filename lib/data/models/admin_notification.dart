class AdminNotification {
  final int notificationId;
  final int userId;
  final String userName;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  AdminNotification({
    required this.notificationId,
    required this.userId,
    required this.userName,
    required this.content,
    this.isRead = false,
    this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      notificationId: json['notificationId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
