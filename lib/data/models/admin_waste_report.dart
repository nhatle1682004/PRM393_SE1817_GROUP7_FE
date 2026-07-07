class AdminWasteReport {
  final int reportId;
  final int submittedBy;
  final String submittedByName;
  final List<int> wasteTypeIds;
  final List<String> wasteTypeNames;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String? description;
  final String status;
  final DateTime? createdAt;

  AdminWasteReport({
    required this.reportId,
    required this.submittedBy,
    required this.submittedByName,
    this.wasteTypeIds = const [],
    this.wasteTypeNames = const [],
    this.imageUrl = '',
    this.latitude = 0,
    this.longitude = 0,
    this.description,
    this.status = '',
    this.createdAt,
  });

  factory AdminWasteReport.fromJson(Map<String, dynamic> json) {
    return AdminWasteReport(
      reportId: json['reportId'] ?? 0,
      submittedBy: json['submittedBy'] ?? 0,
      submittedByName: json['submittedByName'] ?? '',
      wasteTypeIds:
          List<int>.from(json['wasteTypeIds'] ?? json['waste_type_ids'] ?? []),
      wasteTypeNames: List<String>.from(
          json['wasteTypeNames'] ?? json['waste_type_names'] ?? []),
      imageUrl: json['ImageUrl'] ?? json['imageUrl'] ?? json['image_url'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      description: json['description'],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'submittedBy': submittedBy,
        'submittedByName': submittedByName,
        'wasteTypeIds': wasteTypeIds,
        'wasteTypeNames': wasteTypeNames,
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
