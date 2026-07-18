part of '../enterprise_models.dart';

class EnterpriseReport {
  final int reportId;
  final int? requestId, assignmentId;
  final String submittedByName, status;
  final List<String> wasteTypeNames;
  final String? description, imageUrl, assignedCollectorName, estimatedSize;
  final int? assignedCollectorId;
  final double latitude, longitude;
  final DateTime? createdAt;

  EnterpriseReport({required this.reportId, this.requestId, this.assignmentId, required this.submittedByName, this.wasteTypeNames = const [], required this.status, this.description, this.imageUrl, this.latitude = 0.0, this.longitude = 0.0, this.createdAt, this.assignedCollectorName, this.assignedCollectorId, this.estimatedSize});

  factory EnterpriseReport.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseReport(reportId: 0, submittedByName: '', status: 'Pending');
    int toInt(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    double toDouble(dynamic v) => (v is num) ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0.0);
    return EnterpriseReport(
      reportId: toInt(json['reportId'] ?? json['id']), requestId: json['requestId'] ?? json['RequestId'], assignmentId: json['assignmentId'] ?? json['AssignmentId'],
      submittedByName: json['submittedByName'] ?? json['citizenName'] ?? json['userName'] ?? '',
      wasteTypeNames: (json['wasteTypeNames'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? (json['wasteTypeName'] != null ? [json['wasteTypeName'].toString()] : []),
      status: json['status'] ?? 'Pending', description: json['description'],
      imageUrl: json['imageUrl'] ?? json['reportImageUrl'] ?? json['image'] ?? json['image_url'] ?? json['evidenceImage'] ?? json['evidenceUrl'],
      latitude: toDouble(json['latitude']), longitude: toDouble(json['longitude']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      assignedCollectorName: json['assignedCollectorName'] ?? json['collectorName'], assignedCollectorId: json['assignedCollectorId'] ?? json['collectorId'], estimatedSize: json['estimatedSize'] ?? json['EstimatedSize'],
    );
  }

  EnterpriseReport copyWith({int? reportId, int? requestId, int? assignmentId, String? submittedByName, List<String>? wasteTypeNames, String? status, String? description, String? imageUrl, double? latitude, double? longitude, DateTime? createdAt, String? assignedCollectorName, int? assignedCollectorId, String? estimatedSize}) => EnterpriseReport(reportId: reportId ?? this.reportId, requestId: requestId ?? this.requestId, assignmentId: assignmentId ?? this.assignmentId, submittedByName: submittedByName ?? this.submittedByName, wasteTypeNames: wasteTypeNames ?? this.wasteTypeNames, status: status ?? this.status, description: description ?? this.description, imageUrl: imageUrl ?? this.imageUrl, latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude, createdAt: createdAt ?? this.createdAt, assignedCollectorName: assignedCollectorName ?? this.assignedCollectorName, assignedCollectorId: assignedCollectorId ?? this.assignedCollectorId, estimatedSize: estimatedSize ?? this.estimatedSize);

  String get location => (latitude != 0.0 && longitude != 0.0)
      ? '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}
