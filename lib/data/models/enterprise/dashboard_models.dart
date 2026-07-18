part of '../enterprise_models.dart';

class EnterpriseStats {
  final int totalCollectors, totalCollections, pendingCollections, completedCollections, inProgressCollections, cancelledCollections;
  final int totalReports, pendingReports, acceptedReports, collectedReports, rejectedReports, staffCount;
  final Map<String, int>? collectorStatusBreakdown;
  final List<RecentCollectionDto>? recentCollections;
  final List<RecentReportDto>? recentReports;

  EnterpriseStats({
    this.totalCollectors = 0, this.totalCollections = 0, this.pendingCollections = 0, this.completedCollections = 0,
    this.inProgressCollections = 0, this.cancelledCollections = 0, this.totalReports = 0, this.pendingReports = 0,
    this.acceptedReports = 0, this.collectedReports = 0, this.rejectedReports = 0, this.staffCount = 0,
    this.collectorStatusBreakdown, this.recentCollections, this.recentReports,
  });

  factory EnterpriseStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseStats();
    int toI(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return EnterpriseStats(
      totalCollectors: toI(json['totalCollectors'] ?? json['totalCollector']),
      totalCollections: toI(json['totalCollections'] ?? json['totalCollection']),
      pendingCollections: toI(json['pendingCollections'] ?? json['pendingCollection']),
      completedCollections: toI(json['completedCollections'] ?? json['completedCollection']),
      inProgressCollections: toI(json['inProgressCollections'] ?? json['inProgressCollection']),
      cancelledCollections: toI(json['cancelledCollections'] ?? json['cancelledCollection']),
      totalReports: toI(json['totalReports'] ?? json['totalReport']),
      pendingReports: toI(json['pendingReports'] ?? json['pendingReport']),
      acceptedReports: toI(json['acceptedReports']),
      collectedReports: toI(json['collectedReports']),
      rejectedReports: toI(json['rejectedReports']),
      staffCount: toI(json['staffCount']),
      collectorStatusBreakdown: json['collectorStatusBreakdown'] != null ? Map<String, int>.from(json['collectorStatusBreakdown'].map((k, v) => MapEntry(k, toI(v)))) : null,
      recentCollections: (json['recentCollections'] as List?)?.map((e) => RecentCollectionDto.fromJson(e as Map<String, dynamic>?)).toList(),
      recentReports: (json['recentReports'] as List?)?.map((e) => RecentReportDto.fromJson(e as Map<String, dynamic>?)).toList(),
    );
  }
}

class RecentCollectionDto {
  final int requestId;
  final String status;
  final String? collectorName, citizenName, address;
  final DateTime? createdAt, completedAt;

  RecentCollectionDto({this.requestId = 0, this.status = '', this.collectorName, this.citizenName, this.address, this.createdAt, this.completedAt});

  factory RecentCollectionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecentCollectionDto();
    return RecentCollectionDto(
      requestId: json['requestId'] ?? 0,
      status: json['status']?.toString() ?? '',
      collectorName: json['collectorName']?.toString(), citizenName: json['citizenName']?.toString(), address: json['address']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
    );
  }
}

class RecentReportDto {
  final int reportId;
  final String submittedByName, status;
  final String? description;
  final List<String> wasteTypeNames;
  final DateTime? createdAt;

  RecentReportDto({this.reportId = 0, this.submittedByName = '', this.status = '', this.description, this.wasteTypeNames = const [], this.createdAt});

  factory RecentReportDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecentReportDto();
    return RecentReportDto(
      reportId: json['reportId'] ?? 0,
      submittedByName: json['submittedByName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      wasteTypeNames: (json['wasteTypeNames'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
