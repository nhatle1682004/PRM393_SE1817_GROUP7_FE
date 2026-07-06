import 'json_helpers.dart';

class Assignment {
  final int assignmentId;
  final int requestId;
  final int reportId;
  final String status;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String reportImageUrl;
  final String description;
  final double latitude;
  final double longitude;
  final String citizenName;
  final String citizenPhone;
  final String enterpriseName;
  final String enterprisePhone;
  final String beforeImageUrl;
  final String afterImageUrl;
  final String issueReason;
  final String issueImageUrl;
  final String note;
  final double totalCollectedWeight;
  final List<int> wasteTypeIds;

  const Assignment({
    this.assignmentId = 0,
    this.requestId = 0,
    this.reportId = 0,
    this.status = '',
    this.assignedAt,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
    this.reportImageUrl = '',
    this.description = '',
    this.latitude = 0,
    this.longitude = 0,
    this.citizenName = '',
    this.citizenPhone = '',
    this.enterpriseName = '',
    this.enterprisePhone = '',
    this.beforeImageUrl = '',
    this.afterImageUrl = '',
    this.issueReason = '',
    this.issueImageUrl = '',
    this.note = '',
    this.totalCollectedWeight = 0,
    this.wasteTypeIds = const [],
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: JsonHelpers.intValue(json, [
        'assignmentId',
        'AssignmentId',
        'id',
        'Id',
      ]),
      requestId: JsonHelpers.intValue(json, ['requestId', 'RequestId']),
      reportId: JsonHelpers.intValue(json, ['reportId', 'ReportId']),
      status: JsonHelpers.stringValue(json, ['status', 'Status']),
      assignedAt: JsonHelpers.dateValue(json, ['assignedAt', 'AssignedAt']),
      startedAt: JsonHelpers.dateValue(json, ['startedAt', 'StartedAt']),
      arrivedAt: JsonHelpers.dateValue(json, ['arrivedAt', 'ArrivedAt']),
      completedAt: JsonHelpers.dateValue(json, ['completedAt', 'CompletedAt']),
      reportImageUrl: JsonHelpers.stringValue(json, [
        'reportImageUrl',
        'ReportImageUrl',
        'imageUrl',
        'ImageUrl',
      ]),
      description: JsonHelpers.stringValue(json, [
        'description',
        'Description',
        'reportDescription',
        'ReportDescription',
      ]),
      latitude: JsonHelpers.doubleValue(json, ['latitude', 'Latitude']),
      longitude: JsonHelpers.doubleValue(json, ['longitude', 'Longitude']),
      citizenName: JsonHelpers.stringValue(json, [
        'citizenName',
        'CitizenName',
      ]),
      citizenPhone: JsonHelpers.stringValue(json, [
        'citizenPhone',
        'CitizenPhone',
      ]),
      enterpriseName: JsonHelpers.stringValue(json, [
        'enterpriseName',
        'EnterpriseName',
      ]),
      enterprisePhone: JsonHelpers.stringValue(json, [
        'enterprisePhone',
        'EnterprisePhone',
      ]),
      beforeImageUrl: JsonHelpers.stringValue(json, [
        'beforeImageUrl',
        'BeforeImageUrl',
      ]),
      afterImageUrl: JsonHelpers.stringValue(json, [
        'afterImageUrl',
        'AfterImageUrl',
      ]),
      issueReason: JsonHelpers.stringValue(json, [
        'issueReason',
        'IssueReason',
        'issueType',
        'IssueType',
      ]),
      issueImageUrl: JsonHelpers.stringValue(json, [
        'issueImageUrl',
        'IssueImageUrl',
      ]),
      note: JsonHelpers.stringValue(json, [
        'note',
        'Note',
        'completionNote',
        'CompletionNote',
      ]),
      totalCollectedWeight: JsonHelpers.doubleValue(json, [
        'totalCollectedWeight',
        'TotalCollectedWeight',
        'actualWeight',
        'ActualWeight',
      ]),
      wasteTypeIds: JsonHelpers.intList(json, ['wasteTypeIds', 'WasteTypeIds']),
    );
  }

  bool get isActive =>
      const ['Assigned', 'OnTheWay', 'Arrived', 'Issue'].contains(status);
  bool get isHistory =>
      const ['Completed', 'Cancelled', 'Declined', 'Issue'].contains(status);
}
