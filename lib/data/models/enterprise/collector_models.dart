part of '../enterprise_models.dart';

class EnterpriseCollector {
  final int collectorId, warningCount, completedCount, totalAssignments;
  final String? fullName, email, phone;
  final bool isAvailable;
  final String status;
  final DateTime? availabilityUpdatedAt, createdAt;
  final int? managedDistrictId, enterpriseId;

  EnterpriseCollector({
    required this.collectorId, this.fullName, this.email, this.phone, this.isAvailable = false, this.status = 'Active',
    this.warningCount = 0, this.availabilityUpdatedAt, this.createdAt, this.completedCount = 0, this.totalAssignments = 0,
    this.managedDistrictId, this.enterpriseId,
  });

  factory EnterpriseCollector.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EnterpriseCollector(collectorId: 0);
    int toInt(dynamic v) => (v is int) ? v : (int.tryParse(v?.toString() ?? '') ?? 0);
    return EnterpriseCollector(
      collectorId: toInt(json['collectorId'] ?? json['id']),
      fullName: json['fullName'] ?? json['name'],
      email: json['email'], phone: json['phone'] ?? json['phoneNumber'],
      isAvailable: json['isAvailable'] ?? false,
      status: json['status'] ?? 'Active',
      warningCount: toInt(json['warningCount']),
      availabilityUpdatedAt: json['availabilityUpdatedAt'] != null ? DateTime.tryParse(json['availabilityUpdatedAt'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      completedCount: toInt(json['completedCount']),
      totalAssignments: toInt(json['totalAssignments']),
      managedDistrictId: json['managedDistrictId'] is int ? json['managedDistrictId'] : int.tryParse(json['managedDistrictId']?.toString() ?? ''),
      enterpriseId: json['enterpriseId'] is int ? json['enterpriseId'] : int.tryParse(json['enterpriseId']?.toString() ?? ''),
    );
  }

  bool get canReceiveAssignment => isAvailable && status.trim().toLowerCase() == 'active';

  Map<String, dynamic> toJson() => {
    'collectorId': collectorId, 'fullName': fullName, 'email': email, 'phone': phone, 'isAvailable': isAvailable, 'status': status,
    'warningCount': warningCount, 'availabilityUpdatedAt': availabilityUpdatedAt?.toIso8601String(), 'createdAt': createdAt?.toIso8601String(),
    'completedCount': completedCount, 'totalAssignments': totalAssignments, 'managedDistrictId': managedDistrictId, 'enterpriseId': enterpriseId,
  };

  EnterpriseCollector copyWith({
    int? collectorId, String? fullName, String? email, String? phone, bool? isAvailable, String? status,
    int? warningCount, DateTime? availabilityUpdatedAt, DateTime? createdAt, int? completedCount,
    int? totalAssignments, int? managedDistrictId, int? enterpriseId,
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
      enterpriseId: enterpriseId ?? this.enterpriseId,
    );
  }
}

class CreateCollectorRequest {
  final String email, password, fullName, phone;
  final int? managedDistrictId;
  CreateCollectorRequest({required this.email, required this.password, required this.fullName, required this.phone, this.managedDistrictId});
  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'fullName': fullName, 'phone': phone, 'managedDistrictId': managedDistrictId};
}

class UpdateCollectorRequest {
  final String fullName, email, phone, status;
  final int? managedDistrictId;
  UpdateCollectorRequest({required this.fullName, required this.email, required this.phone, required this.status, this.managedDistrictId});
  Map<String, dynamic> toJson() => {'fullName': fullName, 'email': email, 'phone': phone, 'status': status, 'managedDistrictId': managedDistrictId};
}
