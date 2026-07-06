import 'json_helpers.dart';

class CollectionRequest {
  final int requestId;
  final int reportId;
  final int enterpriseId;
  final String enterpriseName;
  final String status;
  final DateTime? createdAt;
  final int currentAssignmentId;
  final int assignedCollectorId;
  final String assignedCollectorName;
  final String assignmentStatus;
  final String reportDescription;
  final String reportImageUrl;
  final double latitude;
  final double longitude;

  const CollectionRequest({
    this.requestId = 0,
    this.reportId = 0,
    this.enterpriseId = 0,
    this.enterpriseName = '',
    this.status = '',
    this.createdAt,
    this.currentAssignmentId = 0,
    this.assignedCollectorId = 0,
    this.assignedCollectorName = '',
    this.assignmentStatus = '',
    this.reportDescription = '',
    this.reportImageUrl = '',
    this.latitude = 0,
    this.longitude = 0,
  });

  factory CollectionRequest.fromJson(Map<String, dynamic> json) {
    return CollectionRequest(
      requestId: JsonHelpers.intValue(json, [
        'requestId',
        'RequestId',
        'id',
        'Id',
      ]),
      reportId: JsonHelpers.intValue(json, ['reportId', 'ReportId']),
      enterpriseId: JsonHelpers.intValue(json, [
        'enterpriseId',
        'EnterpriseId',
      ]),
      enterpriseName: JsonHelpers.stringValue(json, [
        'enterpriseName',
        'EnterpriseName',
      ]),
      status: JsonHelpers.stringValue(json, ['status', 'Status']),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
      currentAssignmentId: JsonHelpers.intValue(json, [
        'currentAssignmentId',
        'CurrentAssignmentId',
      ]),
      assignedCollectorId: JsonHelpers.intValue(json, [
        'assignedCollectorId',
        'AssignedCollectorId',
      ]),
      assignedCollectorName: JsonHelpers.stringValue(json, [
        'assignedCollectorName',
        'AssignedCollectorName',
      ]),
      assignmentStatus: JsonHelpers.stringValue(json, [
        'assignmentStatus',
        'AssignmentStatus',
      ]),
      reportDescription: JsonHelpers.stringValue(json, [
        'reportDescription',
        'ReportDescription',
        'description',
        'Description',
      ]),
      reportImageUrl: JsonHelpers.stringValue(json, [
        'reportImageUrl',
        'ReportImageUrl',
        'imageUrl',
        'ImageUrl',
      ]),
      latitude: JsonHelpers.doubleValue(json, ['latitude', 'Latitude']),
      longitude: JsonHelpers.doubleValue(json, ['longitude', 'Longitude']),
    );
  }
}
