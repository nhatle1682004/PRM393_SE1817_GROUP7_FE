part of '../enterprise_models.dart';

class EnterpriseAssignment {
  final int assignmentId, requestId, assignedCollector, assignedBy, reportId, citizenId;
  final String? collectorName, collectorEmail, collectorPhone, assignedByName, status, beforeImageUrl, afterImageUrl, completionNote, collectedWasteSummary, requestStatus, wasteTypeName, reportImageUrl, reportDescription, reportStatus, citizenName;
  final DateTime? assignedAt, startedAt, arrivedAt, completedAt, requestCreatedAt;
  final double totalCollectedWeight;
  final List<int>? wasteTypeIds;
  final List<EstimatedWasteItem>? wasteItems;
  final double? latitude, longitude;

  EnterpriseAssignment({
    required this.assignmentId, required this.requestId, required this.assignedCollector, this.collectorName, this.collectorEmail, this.collectorPhone,
    required this.assignedBy, this.assignedByName, this.status, this.assignedAt, this.startedAt, this.arrivedAt, this.completedAt, this.beforeImageUrl,
    this.afterImageUrl, this.completionNote, this.totalCollectedWeight = 0, this.collectedWasteSummary, this.requestStatus, this.requestCreatedAt,
    required this.reportId, this.wasteTypeIds = const [], this.wasteItems = const [], this.wasteTypeName, this.reportImageUrl, this.latitude, this.longitude,
    this.reportDescription, this.reportStatus, required this.citizenId, this.citizenName,
  });

  factory EnterpriseAssignment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseAssignment(assignmentId: 0, requestId: 0, assignedCollector: 0, assignedBy: 0, reportId: 0, citizenId: 0);
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return EnterpriseAssignment(
      assignmentId: toI(json['assignmentId'] ?? json['id']), requestId: toI(json['requestId']), assignedCollector: toI(json['assignedCollector']),
      collectorName: json['collectorName']?.toString(), collectorEmail: json['collectorEmail']?.toString(), collectorPhone: json['collectorPhone']?.toString(),
      assignedBy: toI(json['assignedBy']), assignedByName: json['assignedByName']?.toString(), status: json['status']?.toString(),
      assignedAt: json['assignedAt'] != null ? DateTime.tryParse(json['assignedAt'].toString()) : null,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      arrivedAt: json['arrivedAt'] != null ? DateTime.tryParse(json['arrivedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      beforeImageUrl: json['beforeImageUrl']?.toString(), afterImageUrl: json['afterImageUrl']?.toString(), completionNote: json['completionNote']?.toString(),
      totalCollectedWeight: (json['totalCollectedWeight'] as num?)?.toDouble() ?? 0,
      collectedWasteSummary: json['collectedWasteSummary']?.toString(), requestStatus: json['requestStatus']?.toString(),
      requestCreatedAt: json['requestCreatedAt'] != null ? DateTime.tryParse(json['requestCreatedAt'].toString()) : null,
      reportId: toI(json['reportId']),
      wasteTypeIds: (json['wasteTypeIds'] as List?)?.map((e) => toI(e)).toList() ?? const [],
      wasteItems: (json['wasteItems'] as List?)?.map((e) => EstimatedWasteItem.fromJson(e as Map<String, dynamic>?)).toList() ?? const [],
      wasteTypeName: json['wasteTypeName']?.toString(), reportImageUrl: json['reportImageUrl']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(), longitude: (json['longitude'] as num?)?.toDouble(),
      reportDescription: json['reportDescription']?.toString(), reportStatus: json['reportStatus']?.toString(),
      citizenId: toI(json['citizenId']), citizenName: json['citizenName']?.toString(),
    );
  }

  String get location => (latitude != null && longitude != null)
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}

class EstimatedWasteItem {
  final int wasteTypeId;
  final String? wasteTypeName;
  const EstimatedWasteItem({required this.wasteTypeId, this.wasteTypeName});
  factory EstimatedWasteItem.fromJson(Map<String, dynamic>? json) {
    final rawId = json?['wasteTypeId'] ?? json?['WasteTypeId'];
    return EstimatedWasteItem(wasteTypeId: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0, wasteTypeName: json?['wasteTypeName']?.toString() ?? json?['WasteTypeName']?.toString());
  }
}

class AssignmentHistoryDto {
  final int assignmentId, assignedCollector, assignedBy;
  final String? collectorName, collectorPhone, assignedByName, status, beforeImageUrl, afterImageUrl, confirmationNote;
  final DateTime? assignedAt, startedAt, arrivedAt, completedAt;
  final List<CollectionDetailHistoryDto>? collectionDetails;

  AssignmentHistoryDto({required this.assignmentId, required this.assignedCollector, this.collectorName, this.collectorPhone, required this.assignedBy, this.assignedByName, this.status, this.assignedAt, this.startedAt, this.arrivedAt, this.completedAt, this.beforeImageUrl, this.afterImageUrl, this.confirmationNote, this.collectionDetails});

  factory AssignmentHistoryDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AssignmentHistoryDto(assignmentId: 0, assignedCollector: 0, assignedBy: 0);
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return AssignmentHistoryDto(
      assignmentId: toI(json['assignmentId']), assignedCollector: toI(json['assignedCollector']), collectorName: json['collectorName']?.toString(), collectorPhone: json['collectorPhone']?.toString(),
      assignedBy: toI(json['assignedBy']), assignedByName: json['assignedByName']?.toString(), status: json['status']?.toString(),
      assignedAt: json['assignedAt'] != null ? DateTime.tryParse(json['assignedAt'].toString()) : null,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      arrivedAt: json['arrivedAt'] != null ? DateTime.tryParse(json['arrivedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      beforeImageUrl: json['beforeImageUrl']?.toString(), afterImageUrl: json['afterImageUrl']?.toString(), confirmationNote: json['confirmationNote']?.toString(),
      collectionDetails: (json['collectionDetails'] as List?)?.map((e) => CollectionDetailHistoryDto.fromJson(e as Map<String, dynamic>?)).toList(),
    );
  }
}

class CollectionDetailHistoryDto {
  final int wasteTypeId;
  final String? wasteTypeName;
  final double actualWeight;
  CollectionDetailHistoryDto({required this.wasteTypeId, this.wasteTypeName, required this.actualWeight});
  factory CollectionDetailHistoryDto.fromJson(Map<String, dynamic>? json) => CollectionDetailHistoryDto(wasteTypeId: (json?['wasteTypeId'] is int) ? json!['wasteTypeId'] : (int.tryParse(json?['wasteTypeId']?.toString() ?? '') ?? 0), wasteTypeName: json?['wasteTypeName']?.toString(), actualWeight: (json?['actualWeight'] as num?)?.toDouble() ?? 0.0);
}

class AssignCollectorRequest {
  final int requestId, collectorId;
  AssignCollectorRequest({required this.requestId, required this.collectorId});
  Map<String, dynamic> toJson() => {'requestId': requestId, 'collectorId': collectorId};
}

class CollectorAssignmentResponse {
  final int assignmentId, requestId, assignedCollector, assignedBy;
  final String? collectorName, assignedByName, status;
  final DateTime? assignedAt;
  CollectorAssignmentResponse({
    required this.assignmentId,
    required this.requestId,
    required this.assignedCollector,
    required this.assignedBy,
    this.collectorName,
    this.assignedByName,
    this.status,
    this.assignedAt,
  });
  factory CollectorAssignmentResponse.fromJson(Map<String, dynamic>? json) {
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return CollectorAssignmentResponse(
      assignmentId: toI(json?['assignmentId']),
      requestId: toI(json?['requestId']),
      assignedCollector: toI(json?['assignedCollector']),
      assignedBy: toI(json?['assignedBy']),
      collectorName: json?['collectorName']?.toString(),
      assignedByName: json?['assignedByName']?.toString(),
      status: json?['status']?.toString(),
      assignedAt: json?['assignedAt'] != null ? DateTime.tryParse(json?['assignedAt']?.toString() ?? '') : null,
    );
  }
}

class CancelAssignmentResponse {
  final int assignmentId, requestId;
  final String? status;
  CancelAssignmentResponse({
    required this.assignmentId,
    required this.requestId,
    this.status,
  });
  factory CancelAssignmentResponse.fromJson(Map<String, dynamic>? json) {
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return CancelAssignmentResponse(
      assignmentId: toI(json?['assignmentId']),
      requestId: toI(json?['requestId']),
      status: json?['status']?.toString(),
    );
  }
}
