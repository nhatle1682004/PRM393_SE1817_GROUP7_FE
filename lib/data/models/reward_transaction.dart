import 'json_helpers.dart';

class RewardTransaction {
  final int transactionId;
  final int reportId;
  final int rewardId;
  final int points;
  final String type;
  final String description;
  final DateTime? createdAt;

  const RewardTransaction({
    this.transactionId = 0,
    this.reportId = 0,
    this.rewardId = 0,
    this.points = 0,
    this.type = '',
    this.description = '',
    this.createdAt,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      transactionId: JsonHelpers.intValue(json, [
        'transactionId',
        'TransactionId',
        'id',
        'Id',
      ]),
      reportId: JsonHelpers.intValue(json, ['reportId', 'ReportId']),
      rewardId: JsonHelpers.intValue(json, ['rewardId', 'RewardId']),
      points: JsonHelpers.intValue(json, ['points', 'Points']),
      type: JsonHelpers.stringValue(json, [
        'type',
        'Type',
        'transactionType',
        'TransactionType',
      ]),
      description: JsonHelpers.stringValue(json, [
        'description',
        'Description',
      ]),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
    );
  }
}
