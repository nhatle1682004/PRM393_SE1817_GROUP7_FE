import 'json_helpers.dart';

class FeedbackItem {
  final int feedbackId;
  final int reportId;
  final int userId;
  final String userName;
  final String content;
  final String status;
  final DateTime? createdAt;

  const FeedbackItem({
    this.feedbackId = 0,
    this.reportId = 0,
    this.userId = 0,
    this.userName = '',
    this.content = '',
    this.status = '',
    this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      feedbackId: JsonHelpers.intValue(json, [
        'feedbackId',
        'FeedbackId',
        'id',
        'Id',
      ]),
      reportId: JsonHelpers.intValue(json, ['reportId', 'ReportId']),
      userId: JsonHelpers.intValue(json, [
        'userId',
        'UserId',
        'submittedBy',
        'SubmittedBy',
      ]),
      userName: JsonHelpers.stringValue(json, [
        'userName',
        'UserName',
        'submittedByName',
        'SubmittedByName',
      ]),
      content: JsonHelpers.stringValue(json, [
        'content',
        'Content',
        'message',
        'Message',
        'description',
        'Description',
      ]),
      status: JsonHelpers.stringValue(json, ['status', 'Status']),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
    );
  }
}
