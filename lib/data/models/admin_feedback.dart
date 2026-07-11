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
  final String? resolveFailureReason;

  final String? reportDescription;
  final String? reportStatus;
  final String? reportImageUrl;
  final double? latitude;
  final double? longitude;
  final List<String> wasteTypeNames;

  final int? assignmentId;
  final String? assignmentStatus;
  final int? collectorId;
  final String? collectorName;
  final int? collectorWarningCount;
  final String? beforeImageUrl;

  final int? confirmationId;
  final String? confirmationNote;
  final String? confirmationBeforeImageUrl;
  final String? confirmationAfterImageUrl;

  final int? enterpriseId;
  final String? enterpriseName;

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
    this.resolveFailureReason,
    this.reportDescription,
    this.reportStatus,
    this.reportImageUrl,
    this.latitude,
    this.longitude,
    this.wasteTypeNames = const [],
    this.assignmentId,
    this.assignmentStatus,
    this.collectorId,
    this.collectorName,
    this.collectorWarningCount,
    this.beforeImageUrl,
    this.confirmationId,
    this.confirmationNote,
    this.confirmationBeforeImageUrl,
    this.confirmationAfterImageUrl,
    this.enterpriseId,
    this.enterpriseName,
  });

  factory AdminFeedback.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? toNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double? toNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    DateTime? toDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return AdminFeedback(
      feedbackId: toInt(json['feedbackId']),
      userId: toInt(json['userId']),
      userName: json['userName']?.toString() ?? '',
      reportId: toInt(json['reportId']),
      content: json['content']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? json['feedbackImageUrl'],
      status: json['status']?.toString() ?? 'Pending',
      createdAt: toDate(json['createdAt']),
      resolvedAt: toDate(json['resolvedAt']),
      resolution: json['resolutionNote'] ?? json['resolution'],
      resolveFailureReason: json['resolveFailureReason'],
      reportDescription: json['reportDescription'],
      reportStatus: json['reportStatus'],
      reportImageUrl: json['reportImageUrl'],
      latitude: toNullableDouble(json['latitude']),
      longitude: toNullableDouble(json['longitude']),
      wasteTypeNames: (json['wasteTypeNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      assignmentId: toNullableInt(json['assignmentId']),
      assignmentStatus: json['assignmentStatus'],
      collectorId: toNullableInt(json['collectorId']),
      collectorName: json['collectorName'],
      collectorWarningCount: toNullableInt(json['collectorWarningCount']),
      beforeImageUrl: json['beforeImageUrl'],
      confirmationId: toNullableInt(json['confirmationId']),
      confirmationNote: json['confirmationNote'],
      confirmationBeforeImageUrl: json['confirmationBeforeImageUrl'],
      confirmationAfterImageUrl: json['confirmationAfterImageUrl'],
      enterpriseId: toNullableInt(json['enterpriseId']),
      enterpriseName: json['enterpriseName'],
    );
  }
}

class ResolveFeedbackRequest {
  final String action;
  final String adminNote;

  ResolveFeedbackRequest({
    required this.action,
    required this.adminNote,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'adminNote': adminNote,
      };
}
