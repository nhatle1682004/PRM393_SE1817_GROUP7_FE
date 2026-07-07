class AdminFeedback {
  final int feedbackId;
  final int userId;
  final String userName;
  final int reportId;
  final String content;
  final String? imageUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String? resolution;

  AdminFeedback({
    required this.feedbackId,
    required this.userId,
    required this.userName,
    required this.reportId,
    required this.content,
    this.imageUrl,
    this.status = 'Pending',
    this.createdAt,
    this.resolvedAt,
    this.resolution,
  });

  factory AdminFeedback.fromJson(Map<String, dynamic> json) {
    return AdminFeedback(
      feedbackId: json['feedbackId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      reportId: json['reportId'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: json['ImageUrl'] ?? json['imageUrl'],
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() => {
        'feedbackId': feedbackId,
        'userId': userId,
        'userName': userName,
        'reportId': reportId,
        'content': content,
        'imageUrl': imageUrl,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'resolution': resolution,
      };
}

class ResolveFeedbackRequest {
  final String? resolution;

  ResolveFeedbackRequest({this.resolution});

  Map<String, dynamic> toJson() => {
        if (resolution != null) 'resolution': resolution,
      };
}
