import 'json_helpers.dart';

class Reward {
  final int rewardId;
  final String name;
  final String description;
  final int points;
  final bool status;

  const Reward({
    this.rewardId = 0,
    this.name = '',
    this.description = '',
    this.points = 0,
    this.status = true,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      rewardId: JsonHelpers.intValue(json, [
        'rewardId',
        'RewardId',
        'id',
        'Id',
      ]),
      name: JsonHelpers.stringValue(json, ['name', 'Name']),
      description: JsonHelpers.stringValue(json, [
        'description',
        'Description',
      ]),
      points: JsonHelpers.intValue(json, [
        'points',
        'Points',
        'requiredPoints',
        'RequiredPoints',
      ]),
      status: JsonHelpers.boolValue(json, [
        'status',
        'Status',
        'isActive',
        'IsActive',
      ], fallback: true),
    );
  }
}
