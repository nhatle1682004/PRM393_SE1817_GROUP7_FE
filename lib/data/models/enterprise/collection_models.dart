part of '../enterprise_models.dart';

class EnterpriseCollectionRequest {
  final int requestId, reportId, enterpriseId;
  final String? enterpriseName, status, wasteTypeId, wasteTypeName, reportImageUrl, reportDescription, reportStatus;
  final double? latitude, longitude;
  final DateTime? createdAt, reportCreatedAt, assignedAt;
  final int? currentAssignmentId, assignedCollectorId;
  final String? assignedCollectorName, assignmentStatus;

  EnterpriseCollectionRequest({
    required this.requestId, required this.reportId, required this.enterpriseId, this.enterpriseName, this.status, this.createdAt,
    this.wasteTypeId, this.wasteTypeName, this.reportImageUrl, this.latitude, this.longitude, this.reportDescription, this.reportStatus,
    this.reportCreatedAt, this.currentAssignmentId, this.assignedCollectorId, this.assignedCollectorName, this.assignmentStatus, this.assignedAt,
  });

  factory EnterpriseCollectionRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseCollectionRequest(requestId: 0, reportId: 0, enterpriseId: 0);
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    double? toD(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    return EnterpriseCollectionRequest(
      requestId: toI(json['requestId'] ?? json['id']), reportId: toI(json['reportId']), enterpriseId: toI(json['enterpriseId']),
      enterpriseName: json['enterpriseName']?.toString(), status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      wasteTypeId: json['wasteTypeId']?.toString(), wasteTypeName: json['wasteTypeName']?.toString(), reportImageUrl: json['reportImageUrl'] ?? json['ReportImageUrl'],
      latitude: toD(json['latitude']), longitude: toD(json['longitude']), reportDescription: json['reportDescription']?.toString(), reportStatus: json['reportStatus']?.toString(),
      reportCreatedAt: json['reportCreatedAt'] != null ? DateTime.tryParse(json['reportCreatedAt'].toString()) : null,
      currentAssignmentId: json['currentAssignmentId'] != null ? toI(json['currentAssignmentId']) : null,
      assignedCollectorId: json['assignedCollectorId'] != null ? toI(json['assignedCollectorId']) : null,
      assignedCollectorName: json['assignedCollectorName']?.toString(), assignmentStatus: json['assignmentStatus']?.toString(),
      assignedAt: json['assignedAt'] != null ? DateTime.tryParse(json['assignedAt'].toString()) : null,
    );
  }

  String get location => (latitude != null && longitude != null)
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}

class CollectionRequestDetail {
  final int requestId, reportId, enterpriseId;
  final String? enterpriseName, enterpriseEmail, enterprisePhone, status;
  final DateTime? createdAt;
  final WasteReportInfo? report;
  final List<AssignmentHistoryDto>? assignmentHistory;

  CollectionRequestDetail({required this.requestId, required this.reportId, required this.enterpriseId, this.enterpriseName, this.enterpriseEmail, this.enterprisePhone, this.status, this.createdAt, this.report, this.assignmentHistory});

  factory CollectionRequestDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CollectionRequestDetail(requestId: 0, reportId: 0, enterpriseId: 0);
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return CollectionRequestDetail(
      requestId: toI(json['requestId'] ?? json['id']), reportId: toI(json['reportId']), enterpriseId: toI(json['enterpriseId']),
      enterpriseName: json['enterpriseName']?.toString(), enterpriseEmail: json['enterpriseEmail']?.toString(), enterprisePhone: json['enterprisePhone']?.toString(), status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      report: json['report'] != null ? WasteReportInfo.fromJson(json['report'] as Map<String, dynamic>?) : null,
      assignmentHistory: (json['assignmentHistory'] as List?)?.map((e) => AssignmentHistoryDto.fromJson(e as Map<String, dynamic>?)).toList(),
    );
  }
}

class WasteReportInfo {
  final int reportId, submittedBy;
  final String? citizenName, citizenEmail, imageUrl, description, status;
  final List<int> wasteTypeIds;
  final List<String> wasteTypeNames;
  final double? latitude, longitude;
  final DateTime? createdAt;
  final List<AiPredictionDto> aiPredictions;

  WasteReportInfo({required this.reportId, required this.submittedBy, this.citizenName, this.citizenEmail, this.wasteTypeIds = const [], this.wasteTypeNames = const [], this.imageUrl, this.latitude, this.longitude, this.description, this.status, this.createdAt, this.aiPredictions = const []});

  factory WasteReportInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WasteReportInfo(reportId: 0, submittedBy: 0);
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return WasteReportInfo(
      reportId: toI(json['reportId']), submittedBy: toI(json['submittedBy']), citizenName: json['citizenName']?.toString(), citizenEmail: json['citizenEmail']?.toString(),
      wasteTypeIds: (json['wasteTypeIds'] as List?)?.map((e) => toI(e)).toList() ?? [],
      wasteTypeNames: (json['wasteTypeNames'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
      imageUrl: json['imageUrl']?.toString(), latitude: (json['latitude'] as num?)?.toDouble(), longitude: (json['longitude'] as num?)?.toDouble(), description: json['description']?.toString(), status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      aiPredictions: (json['aiPredictions'] as List?)?.map((e) => AiPredictionDto.fromJson(e as Map<String, dynamic>?)).toList() ?? [],
    );
  }

  String get location => (latitude != null && longitude != null)
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}

class AiPredictionDto {
  final String? suggestedType;
  final double? confidence;
  AiPredictionDto({this.suggestedType, this.confidence});
  factory AiPredictionDto.fromJson(Map<String, dynamic>? json) => AiPredictionDto(suggestedType: json?['suggestedType']?.toString(), confidence: (json?['confidence'] as num?)?.toDouble());
}
