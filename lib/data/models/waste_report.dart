import 'json_helpers.dart';

class WasteReport {
  final int reportId;
  final int submittedBy;
  final String submittedByName;
  final List<int> wasteTypeIds;
  final List<String> wasteTypeNames;
  final String imageUrl;
  final String description;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime? createdAt;

  const WasteReport({
    this.reportId = 0,
    this.submittedBy = 0,
    this.submittedByName = '',
    this.wasteTypeIds = const [],
    this.wasteTypeNames = const [],
    this.imageUrl = '',
    this.description = '',
    this.latitude,
    this.longitude,
    this.status = '',
    this.createdAt,
  });

  factory WasteReport.fromJson(Map<String, dynamic> json) {
    return WasteReport(
      reportId: JsonHelpers.intValue(json, [
        'reportId',
        'ReportId',
        'id',
        'Id',
      ]),
      submittedBy: JsonHelpers.intValue(json, [
        'submittedBy',
        'SubmittedBy',
        'userId',
        'UserId',
      ]),
      submittedByName: JsonHelpers.stringValue(json, [
        'submittedByName',
        'SubmittedByName',
      ]),
      wasteTypeIds: JsonHelpers.intList(json, ['wasteTypeIds', 'WasteTypeIds']),
      wasteTypeNames: JsonHelpers.stringList(json, [
        'wasteTypeNames',
        'WasteTypeNames',
        'wasteTypeName',
        'WasteTypeName',
      ]),
      imageUrl: JsonHelpers.stringValue(json, [
        'imageUrl',
        'ImageUrl',
        'reportImageUrl',
        'ReportImageUrl',
      ]),
      description: JsonHelpers.stringValue(json, [
        'description',
        'Description',
      ]),
      latitude: JsonHelpers.doubleValue(json, ['latitude', 'Latitude']),
      longitude: JsonHelpers.doubleValue(json, ['longitude', 'Longitude']),
      status: JsonHelpers.stringValue(json, ['status', 'Status']),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
    );
  }

  bool get canCancel => status == 'Pending';
  bool get canFeedback => status == 'Completed' || status == 'Collected';
}
