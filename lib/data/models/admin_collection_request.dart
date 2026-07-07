class AdminCollectionRequest {
  final int requestId;
  final int reportId;
  final int enterpriseId;
  final String? enterpriseName;
  final String status;
  final DateTime? createdAt;
  final String? wasteTypeId;
  final String? wasteTypeName;
  final String? reportImageUrl;
  final double? latitude;
  final double? longitude;
  final String? reportDescription;
  final String? reportStatus;
  final DateTime? reportCreatedAt;
  final int? currentAssignmentId;
  final int? assignedCollectorId;
  final String? assignedCollectorName;
  final String? assignmentStatus;
  final DateTime? assignedAt;

  AdminCollectionRequest({
    required this.requestId,
    required this.reportId,
    required this.enterpriseId,
    this.enterpriseName,
    this.status = '',
    this.createdAt,
    this.wasteTypeId,
    this.wasteTypeName,
    this.reportImageUrl,
    this.latitude,
    this.longitude,
    this.reportDescription,
    this.reportStatus,
    this.reportCreatedAt,
    this.currentAssignmentId,
    this.assignedCollectorId,
    this.assignedCollectorName,
    this.assignmentStatus,
    this.assignedAt,
  });

  factory AdminCollectionRequest.fromJson(Map<String, dynamic> json) {
    return AdminCollectionRequest(
      requestId: json['requestId'] ?? 0,
      reportId: json['reportId'] ?? 0,
      enterpriseId: json['enterpriseId'] ?? 0,
      enterpriseName: json['enterpriseName'],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      wasteTypeId: json['wasteTypeId']?.toString(),
      wasteTypeName: json['wasteTypeName'],
      reportImageUrl: json['ReportImageUrl'] ?? json['reportImageUrl'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      reportDescription: json['reportDescription'],
      reportStatus: json['reportStatus'],
      reportCreatedAt: json['reportCreatedAt'] != null
          ? DateTime.tryParse(json['reportCreatedAt'].toString())
          : null,
      currentAssignmentId: json['currentAssignmentId'],
      assignedCollectorId: json['assignedCollectorId'],
      assignedCollectorName: json['assignedCollectorName'],
      assignmentStatus: json['assignmentStatus'],
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
    );
  }
}
