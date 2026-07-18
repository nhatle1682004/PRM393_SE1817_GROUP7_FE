part of '../enterprise_models.dart';

class EnterpriseFeedback {
  final int feedbackId;
  final String? userName, imageUrl, resolution;
  final String content, status;
  final int? reportId;
  final DateTime? createdAt, resolvedAt;

  EnterpriseFeedback({required this.feedbackId, this.userName, required this.content, this.reportId, this.status = 'Pending', this.imageUrl, this.resolution, this.createdAt, this.resolvedAt});

  factory EnterpriseFeedback.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseFeedback(feedbackId: 0, content: '');
    int toInt(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return EnterpriseFeedback(
      feedbackId: toInt(json['feedbackId'] ?? json['id']), userName: json['userName'] ?? json['fullName'], content: json['content'] ?? json['description'] ?? '',
      reportId: json['reportId'] != null ? toInt(json['reportId']) : null, status: json['status'] ?? 'Pending', imageUrl: json['imageUrl'] ?? json['feedbackImageUrl'],
      resolution: json['resolutionNote'] ?? json['resolution'], createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.tryParse(json['resolvedAt'].toString()) : null,
    );
  }
}

class ResolveFeedbackRequest {
  final String action, adminNote;
  ResolveFeedbackRequest({required this.action, required this.adminNote});
  Map<String, dynamic> toJson() => {'action': action, 'adminNote': adminNote};
}
