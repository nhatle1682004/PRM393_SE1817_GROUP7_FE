// ============ ENTERPRISE MODELS - Match BE DTOs Exactly ============

// ============ DASHBOARD ============
class EnterpriseStats {
  final int totalCollectors;
  final int totalCollections;
  final int pendingCollections;
  final int completedCollections;
  final int inProgressCollections;
  final int cancelledCollections;
  final int totalReports;
  final int pendingReports;
  final int acceptedReports;
  final int collectedReports;
  final int rejectedReports;
  final int staffCount;
  final Map<String, int>? collectorStatusBreakdown;
  final List<RecentCollectionDto>? recentCollections;
  final List<RecentReportDto>? recentReports;

  EnterpriseStats({
    this.totalCollectors = 0,
    this.totalCollections = 0,
    this.pendingCollections = 0,
    this.completedCollections = 0,
    this.inProgressCollections = 0,
    this.cancelledCollections = 0,
    this.totalReports = 0,
    this.pendingReports = 0,
    this.acceptedReports = 0,
    this.collectedReports = 0,
    this.rejectedReports = 0,
    this.staffCount = 0,
    this.collectorStatusBreakdown,
    this.recentCollections,
    this.recentReports,
  });

  factory EnterpriseStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseStats();

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    Map<String, int>? breakdown;
    if (json['collectorStatusBreakdown'] != null) {
      try {
        final Map<String, dynamic> rawMap = Map<String, dynamic>.from(json['collectorStatusBreakdown']);
        breakdown = rawMap.map((key, value) => MapEntry(key, _toInt(value)));
      } catch (_) {}
    }

    List<RecentCollectionDto>? recentCollections;
    if (json['recentCollections'] != null) {
      try {
        recentCollections = (json['recentCollections'] as List)
            .map((e) => RecentCollectionDto.fromJson(e))
            .toList();
      } catch (_) {}
    }

    List<RecentReportDto>? recentReports;
    if (json['recentReports'] != null) {
      try {
        recentReports = (json['recentReports'] as List)
            .map((e) => RecentReportDto.fromJson(e))
            .toList();
      } catch (_) {}
    }

    return EnterpriseStats(
      totalCollectors: _toInt(json['totalCollectors'] ?? json['totalCollector']),
      totalCollections: _toInt(json['totalCollections'] ?? json['totalCollection']),
      pendingCollections: _toInt(json['pendingCollections'] ?? json['pendingCollection']),
      completedCollections: _toInt(json['completedCollections'] ?? json['completedCollection']),
      inProgressCollections: _toInt(json['inProgressCollections'] ?? json['inProgressCollection']),
      cancelledCollections: _toInt(json['cancelledCollections'] ?? json['cancelledCollection']),
      totalReports: _toInt(json['totalReports'] ?? json['totalReport']),
      pendingReports: _toInt(json['pendingReports'] ?? json['pendingReport']),
      acceptedReports: _toInt(json['acceptedReports']),
      collectedReports: _toInt(json['collectedReports']),
      rejectedReports: _toInt(json['rejectedReports']),
      staffCount: _toInt(json['staffCount']),
      collectorStatusBreakdown: breakdown,
      recentCollections: recentCollections,
      recentReports: recentReports,
    );
  }
}

class RecentCollectionDto {
  final int requestId;
  final String status;
  final String? collectorName;
  final String? citizenName;
  final String? address;
  final DateTime? createdAt;
  final DateTime? completedAt;

  RecentCollectionDto({
    this.requestId = 0,
    this.status = '',
    this.collectorName,
    this.citizenName,
    this.address,
    this.createdAt,
    this.completedAt,
  });

  factory RecentCollectionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecentCollectionDto();
    return RecentCollectionDto(
      requestId: json['requestId'] ?? 0,
      status: json['status'] ?? '',
      collectorName: json['collectorName'],
      citizenName: json['citizenName'],
      address: json['address'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
    );
  }
}

class RecentReportDto {
  final int reportId;
  final String submittedByName;
  final String? description;
  final String status;
  final List<String> wasteTypeNames;
  final DateTime? createdAt;

  RecentReportDto({
    this.reportId = 0,
    this.submittedByName = '',
    this.description,
    this.status = '',
    this.wasteTypeNames = const [],
    this.createdAt,
  });

  factory RecentReportDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecentReportDto();
    return RecentReportDto(
      reportId: json['reportId'] ?? 0,
      submittedByName: json['submittedByName'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      wasteTypeNames: json['wasteTypeNames'] != null
          ? (json['wasteTypeNames'] as List).map((e) => e?.toString() ?? '').toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

// ============ COLLECTOR - matches CollectorDto ============
class EnterpriseCollector {
  final int collectorId;
  final String? fullName;
  final String? email;
  final String? phone;
  final bool isAvailable;
  final String status;
  final int warningCount;
  final DateTime? availabilityUpdatedAt;
  final DateTime? createdAt;
  final int completedCount;
  final int totalAssignments;

  final int? managedDistrictId;

  EnterpriseCollector({
    required this.collectorId,
    this.fullName,
    this.email,
    this.phone,
    this.isAvailable = false,
    this.status = 'Active',
    this.warningCount = 0,
    this.availabilityUpdatedAt,
    this.createdAt,
    this.completedCount = 0,
    this.totalAssignments = 0,
    this.managedDistrictId,
  });

  factory EnterpriseCollector.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseCollector(collectorId: 0);

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return EnterpriseCollector(
      collectorId: _toInt(json['collectorId'] ?? json['id']),
      fullName: json['fullName'] ?? json['name'],
      email: json['email'],
      phone: json['phone'] ?? json['phoneNumber'],
      isAvailable: json['isAvailable'] ?? false,
      status: json['status'] ?? 'Active',
      warningCount: _toInt(json['warningCount']),
      availabilityUpdatedAt: json['availabilityUpdatedAt'] != null
          ? DateTime.tryParse(json['availabilityUpdatedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      completedCount: _toInt(json['completedCount']),
      totalAssignments: _toInt(json['totalAssignments']),
      managedDistrictId: json['managedDistrictId'] is int 
          ? json['managedDistrictId'] 
          : int.tryParse(json['managedDistrictId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'collectorId': collectorId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'isAvailable': isAvailable,
    'status': status,
    'warningCount': warningCount,
    'availabilityUpdatedAt': availabilityUpdatedAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'completedCount': completedCount,
    'totalAssignments': totalAssignments,
    'managedDistrictId': managedDistrictId,
  };

  EnterpriseCollector copyWith({
    int? collectorId,
    String? fullName,
    String? email,
    String? phone,
    bool? isAvailable,
    String? status,
    int? warningCount,
    DateTime? availabilityUpdatedAt,
    DateTime? createdAt,
    int? completedCount,
    int? totalAssignments,
    int? managedDistrictId,
  }) {
    return EnterpriseCollector(
      collectorId: collectorId ?? this.collectorId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      warningCount: warningCount ?? this.warningCount,
      availabilityUpdatedAt: availabilityUpdatedAt ?? this.availabilityUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      completedCount: completedCount ?? this.completedCount,
      totalAssignments: totalAssignments ?? this.totalAssignments,
      managedDistrictId: managedDistrictId ?? this.managedDistrictId,
    );
  }
}

class CreateCollectorRequest {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final int? managedDistrictId;

  CreateCollectorRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    this.managedDistrictId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
        'managedDistrictId': managedDistrictId,
      };
}

class UpdateCollectorRequest {
  final String fullName;
  final String email;
  final String phone;
  final String status;
  final int? managedDistrictId;

  UpdateCollectorRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    this.managedDistrictId,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'status': status,
        'managedDistrictId': managedDistrictId,
      };
}

// ============ COLLECTION REQUEST - matches CollectionRequestDto ============
class EnterpriseCollectionRequest {
  final int requestId;
  final int reportId;
  final int enterpriseId;
  final String? enterpriseName;
  final String? status;
  final DateTime? createdAt;

  // Waste report info
  final String? wasteTypeId;
  final String? wasteTypeName;
  final String? reportImageUrl;
  final double? latitude;
  final double? longitude;
  final String? reportDescription;
  final String? reportStatus;
  final DateTime? reportCreatedAt;

  // Current assignment info
  final int? currentAssignmentId;
  final int? assignedCollectorId;
  final String? assignedCollectorName;
  final String? assignmentStatus;
  final DateTime? assignedAt;

  EnterpriseCollectionRequest({
    required this.requestId,
    required this.reportId,
    required this.enterpriseId,
    this.enterpriseName,
    this.status,
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

  factory EnterpriseCollectionRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EnterpriseCollectionRequest(
        requestId: 0,
        reportId: 0,
        enterpriseId: 0,
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    double? _toDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return EnterpriseCollectionRequest(
      requestId: _toInt(json['requestId'] ?? json['id']),
      reportId: _toInt(json['reportId']),
      enterpriseId: _toInt(json['enterpriseId']),
      enterpriseName: json['enterpriseName'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      wasteTypeId: json['wasteTypeId']?.toString(),
      wasteTypeName: json['wasteTypeName'],
      reportImageUrl: json['reportImageUrl'] ?? json['ReportImageUrl'],
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      reportDescription: json['reportDescription'],
      reportStatus: json['reportStatus'],
      reportCreatedAt: json['reportCreatedAt'] != null
          ? DateTime.tryParse(json['reportCreatedAt'].toString())
          : null,
      currentAssignmentId: json['currentAssignmentId'] != null ? _toInt(json['currentAssignmentId']) : null,
      assignedCollectorId: json['assignedCollectorId'] != null ? _toInt(json['assignedCollectorId']) : null,
      assignedCollectorName: json['assignedCollectorName'],
      assignmentStatus: json['assignmentStatus'],
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
    );
  }

  String get location => (latitude != null && longitude != null)
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}

// ============ COLLECTION REQUEST DETAIL - matches CollectionRequestDetailDto ============
class CollectionRequestDetail {
  final int requestId;
  final int reportId;
  final int enterpriseId;
  final String? enterpriseName;
  final String? enterpriseEmail;
  final String? enterprisePhone;
  final String? status;
  final DateTime? createdAt;
  final WasteReportInfo? report;
  final List<AssignmentHistoryDto>? assignmentHistory;

  CollectionRequestDetail({
    required this.requestId,
    required this.reportId,
    required this.enterpriseId,
    this.enterpriseName,
    this.enterpriseEmail,
    this.enterprisePhone,
    this.status,
    this.createdAt,
    this.report,
    this.assignmentHistory,
  });

  factory CollectionRequestDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CollectionRequestDetail(
        requestId: 0,
        reportId: 0,
        enterpriseId: 0,
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return CollectionRequestDetail(
      requestId: _toInt(json['requestId'] ?? json['id']),
      reportId: _toInt(json['reportId']),
      enterpriseId: _toInt(json['enterpriseId']),
      enterpriseName: json['enterpriseName'],
      enterpriseEmail: json['enterpriseEmail'],
      enterprisePhone: json['enterprisePhone'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      report: json['report'] != null
          ? WasteReportInfo.fromJson(json['report'])
          : null,
      assignmentHistory: json['assignmentHistory'] != null
          ? (json['assignmentHistory'] as List)
              .map((e) => AssignmentHistoryDto.fromJson(e))
              .toList()
          : null,
    );
  }
}

class WasteReportInfo {
  final int reportId;
  final int submittedBy;
  final String? citizenName;
  final String? citizenEmail;
  final List<int> wasteTypeIds;
  final List<String> wasteTypeNames;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final List<AiPredictionDto> aiPredictions;

  WasteReportInfo({
    required this.reportId,
    required this.submittedBy,
    this.citizenName,
    this.citizenEmail,
    this.wasteTypeIds = const [],
    this.wasteTypeNames = const [],
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.description,
    this.status,
    this.createdAt,
    this.aiPredictions = const [],
  });

  factory WasteReportInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WasteReportInfo(reportId: 0, submittedBy: 0);
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return WasteReportInfo(
      reportId: _toInt(json['reportId']),
      submittedBy: _toInt(json['submittedBy']),
      citizenName: json['citizenName'],
      citizenEmail: json['citizenEmail'],
      wasteTypeIds: json['wasteTypeIds'] != null
          ? (json['wasteTypeIds'] as List).map((e) => _toInt(e)).toList()
          : [],
      wasteTypeNames: json['wasteTypeNames'] != null
          ? (json['wasteTypeNames'] as List).map((e) => e?.toString() ?? '').toList()
          : [],
      imageUrl: json['imageUrl'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      description: json['description'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      aiPredictions: json['aiPredictions'] != null
          ? (json['aiPredictions'] as List).map((e) => AiPredictionDto.fromJson(e)).toList()
          : [],
    );
  }

  String get location => (latitude != null && longitude != null)
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}

class AiPredictionDto {
  final String? suggestedType;
  final double? confidence;

  AiPredictionDto({
    this.suggestedType,
    this.confidence,
  });

  factory AiPredictionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AiPredictionDto();
    return AiPredictionDto(
      suggestedType: json['suggestedType'],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

// ============ ASSIGNMENT - matches AssignmentDto ============
class EnterpriseAssignment {
  final int assignmentId;
  final int requestId;
  final int assignedCollector;
  final String? collectorName;
  final String? collectorEmail;
  final String? collectorPhone;
  final int assignedBy;
  final String? assignedByName;
  final String? status;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? beforeImageUrl;

  // Collection request info
  final String? requestStatus;
  final DateTime? requestCreatedAt;

  // Waste report info
  final int reportId;
  final String? wasteTypeName;
  final String? reportImageUrl;
  final double? latitude;
  final double? longitude;
  final String? reportDescription;
  final String? reportStatus;

  // Citizen info
  final int citizenId;
  final String? citizenName;

  EnterpriseAssignment({
    required this.assignmentId,
    required this.requestId,
    required this.assignedCollector,
    this.collectorName,
    this.collectorEmail,
    this.collectorPhone,
    required this.assignedBy,
    this.assignedByName,
    this.status,
    this.assignedAt,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
    this.beforeImageUrl,
    this.requestStatus,
    this.requestCreatedAt,
    required this.reportId,
    this.wasteTypeName,
    this.reportImageUrl,
    this.latitude,
    this.longitude,
    this.reportDescription,
    this.reportStatus,
    required this.citizenId,
    this.citizenName,
  });

  factory EnterpriseAssignment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EnterpriseAssignment(
        assignmentId: 0,
        requestId: 0,
        assignedCollector: 0,
        assignedBy: 0,
        reportId: 0,
        citizenId: 0,
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return EnterpriseAssignment(
      assignmentId: _toInt(json['assignmentId'] ?? json['id']),
      requestId: _toInt(json['requestId']),
      assignedCollector: _toInt(json['assignedCollector']),
      collectorName: json['collectorName'],
      collectorEmail: json['collectorEmail'],
      collectorPhone: json['collectorPhone'],
      assignedBy: _toInt(json['assignedBy']),
      assignedByName: json['assignedByName'],
      status: json['status'],
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      arrivedAt: json['arrivedAt'] != null
          ? DateTime.tryParse(json['arrivedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      beforeImageUrl: json['beforeImageUrl'],
      requestStatus: json['requestStatus'],
      requestCreatedAt: json['requestCreatedAt'] != null
          ? DateTime.tryParse(json['requestCreatedAt'].toString())
          : null,
      reportId: _toInt(json['reportId']),
      wasteTypeName: json['wasteTypeName'],
      reportImageUrl: json['reportImageUrl'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      reportDescription: json['reportDescription'],
      reportStatus: json['reportStatus'],
      citizenId: _toInt(json['citizenId']),
      citizenName: json['citizenName'],
    );
  }

  String get location => (latitude != null && longitude != null)
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : 'Chưa có vị trí';
}

// ============ ASSIGNMENT HISTORY - matches AssignmentHistoryDto ============
class AssignmentHistoryDto {
  final int assignmentId;
  final int assignedCollector;
  final String? collectorName;
  final String? collectorPhone;
  final int assignedBy;
  final String? assignedByName;
  final String? status;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final String? confirmationNote;
  final List<CollectionDetailHistoryDto>? collectionDetails;

  AssignmentHistoryDto({
    required this.assignmentId,
    required this.assignedCollector,
    this.collectorName,
    this.collectorPhone,
    required this.assignedBy,
    this.assignedByName,
    this.status,
    this.assignedAt,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.confirmationNote,
    this.collectionDetails,
  });

  factory AssignmentHistoryDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AssignmentHistoryDto(
        assignmentId: 0,
        assignedCollector: 0,
        assignedBy: 0,
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return AssignmentHistoryDto(
      assignmentId: _toInt(json['assignmentId']),
      assignedCollector: _toInt(json['assignedCollector']),
      collectorName: json['collectorName'],
      collectorPhone: json['collectorPhone'],
      assignedBy: _toInt(json['assignedBy']),
      assignedByName: json['assignedByName'],
      status: json['status'],
      assignedAt: json['assignedAt'] != null ? DateTime.tryParse(json['assignedAt'].toString()) : null,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      arrivedAt: json['arrivedAt'] != null ? DateTime.tryParse(json['arrivedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      beforeImageUrl: json['beforeImageUrl'],
      afterImageUrl: json['afterImageUrl'],
      confirmationNote: json['confirmationNote'],
      collectionDetails: json['collectionDetails'] != null
          ? (json['collectionDetails'] as List).map((e) => CollectionDetailHistoryDto.fromJson(e)).toList()
          : null,
    );
  }
}

class CollectionDetailHistoryDto {
  final int wasteTypeId;
  final String? wasteTypeName;
  final double actualWeight;

  CollectionDetailHistoryDto({
    required this.wasteTypeId,
    this.wasteTypeName,
    required this.actualWeight,
  });

  factory CollectionDetailHistoryDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CollectionDetailHistoryDto(wasteTypeId: 0, actualWeight: 0);
    return CollectionDetailHistoryDto(
      wasteTypeId: json['wasteTypeId'] ?? 0,
      wasteTypeName: json['wasteTypeName'],
      actualWeight: (json['actualWeight'] ?? 0).toDouble(),
    );
  }
}

// ============ REQUEST BODY - matches AssignCollectorDto ============
class AssignCollectorRequest {
  final int requestId;
  final int collectorId;

  AssignCollectorRequest({
    required this.requestId,
    required this.collectorId,
  });

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'collectorId': collectorId,
  };
}

// ============ RESPONSE - matches CollectorAssignmentResponseDto ============
class CollectorAssignmentResponse {
  final int assignmentId;
  final int requestId;
  final int assignedCollector;
  final String? collectorName;
  final int assignedBy;
  final String? assignedByName;
  final String? status;
  final DateTime? assignedAt;

  CollectorAssignmentResponse({
    required this.assignmentId,
    required this.requestId,
    required this.assignedCollector,
    this.collectorName,
    required this.assignedBy,
    this.assignedByName,
    this.status,
    this.assignedAt,
  });

  factory CollectorAssignmentResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CollectorAssignmentResponse(
        assignmentId: 0,
        requestId: 0,
        assignedCollector: 0,
        assignedBy: 0,
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return CollectorAssignmentResponse(
      assignmentId: _toInt(json['assignmentId']),
      requestId: _toInt(json['requestId']),
      assignedCollector: _toInt(json['assignedCollector']),
      collectorName: json['collectorName'],
      assignedBy: _toInt(json['assignedBy']),
      assignedByName: json['assignedByName'],
      status: json['status'],
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
    );
  }
}

// ============ CANCEL RESPONSE - matches CancelAssignmentResponseDto ============
class CancelAssignmentResponse {
  final int assignmentId;
  final int requestId;
  final String? status;

  CancelAssignmentResponse({
    required this.assignmentId,
    required this.requestId,
    this.status,
  });

  factory CancelAssignmentResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CancelAssignmentResponse(
        assignmentId: 0,
        requestId: 0,
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return CancelAssignmentResponse(
      assignmentId: _toInt(json['assignmentId']),
      requestId: _toInt(json['requestId']),
      status: json['status'],
    );
  }
}

// ============ REPORT ============
class EnterpriseReport {
  final int reportId;
  final int? requestId;
  final int? assignmentId;
  final String submittedByName;
  final List<String> wasteTypeNames;
  final String status;
  final String? description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final String? assignedCollectorName;
  final int? assignedCollectorId;
  final String? estimatedSize;

  EnterpriseReport({
    required this.reportId,
    this.requestId,
    this.assignmentId,
    required this.submittedByName,
    this.wasteTypeNames = const [],
    required this.status,
    this.description,
    this.imageUrl,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.createdAt,
    this.assignedCollectorName,
    this.assignedCollectorId,
    this.estimatedSize,
  });

  factory EnterpriseReport.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EnterpriseReport(
        reportId: 0,
        submittedByName: '',
        status: 'Pending',
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    double _toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return EnterpriseReport(
      reportId: _toInt(json['reportId'] ?? json['id']),
      requestId: json['requestId'] ?? json['RequestId'],
      assignmentId: json['assignmentId'] ?? json['AssignmentId'],
      submittedByName: json['submittedByName'] ?? json['citizenName'] ?? json['userName'] ?? '',
      wasteTypeNames: json['wasteTypeNames'] != null
          ? (json['wasteTypeNames'] as List).map((e) => e?.toString() ?? '').toList()
          : (json['wasteTypeName'] != null ? [json['wasteTypeName'].toString()] : []),
      status: json['status'] ?? 'Pending',
      description: json['description'],
      imageUrl: json['imageUrl'] 
          ?? json['reportImageUrl'] 
          ?? json['image'] 
          ?? json['image_url'] 
          ?? json['evidenceImage'] 
          ?? json['evidenceUrl'],
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedCollectorName: json['assignedCollectorName'] ?? json['collectorName'],
      assignedCollectorId: json['assignedCollectorId'] ?? json['collectorId'],
      estimatedSize: json['estimatedSize'] ?? json['EstimatedSize'],
    );
  }

  EnterpriseReport copyWith({
    int? reportId,
    int? requestId,
    int? assignmentId,
    String? submittedByName,
    List<String>? wasteTypeNames,
    String? status,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? assignedCollectorName,
    int? assignedCollectorId,
    String? estimatedSize,
  }) {
    return EnterpriseReport(
      reportId: reportId ?? this.reportId,
      requestId: requestId ?? this.requestId,
      assignmentId: assignmentId ?? this.assignmentId,
      submittedByName: submittedByName ?? this.submittedByName,
      wasteTypeNames: wasteTypeNames ?? this.wasteTypeNames,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      assignedCollectorName: assignedCollectorName ?? this.assignedCollectorName,
      assignedCollectorId: assignedCollectorId ?? this.assignedCollectorId,
      estimatedSize: estimatedSize ?? this.estimatedSize,
    );
  }
}

// ============ FEEDBACK ============
class EnterpriseFeedback {
  final int feedbackId;
  final String? userName;
  final String content;
  final int? reportId;
  final String status;
  final String? imageUrl;
  final String? resolution;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  EnterpriseFeedback({
    required this.feedbackId,
    this.userName,
    required this.content,
    this.reportId,
    this.status = 'Pending',
    this.imageUrl,
    this.resolution,
    this.createdAt,
    this.resolvedAt,
  });

  factory EnterpriseFeedback.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EnterpriseFeedback(
        feedbackId: 0,
        content: '',
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return EnterpriseFeedback(
      feedbackId: _toInt(json['feedbackId'] ?? json['id']),
      userName: json['userName'] ?? json['fullName'],
      content: json['content'] ?? json['description'] ?? '',
      reportId: json['reportId'] != null ? _toInt(json['reportId']) : null,
      status: json['status'] ?? 'Pending',
      imageUrl: json['imageUrl'] ?? json['feedbackImageUrl'],
      resolution: json['resolutionNote'] ?? json['resolution'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
    );
  }
}

class ResolveFeedbackRequest {
  final String action; // "warn" or "reassign"
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

// ============ NOTIFICATION ============
class EnterpriseNotification {
  final int notificationId;
  final String? title;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  EnterpriseNotification({
    required this.notificationId,
    this.title,
    required this.content,
    this.isRead = false,
    this.createdAt,
  });

  factory EnterpriseNotification.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EnterpriseNotification(
        notificationId: 0,
        content: '',
      );
    }

    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return EnterpriseNotification(
      notificationId: _toInt(json['notificationId'] ?? json['id']),
      title: json['title'],
      content: json['content'] ?? json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  EnterpriseNotification copyWith({
    int? notificationId,
    String? title,
    String? content,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return EnterpriseNotification(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
