import 'json_helpers.dart';

class WasteType {
  final int wasteTypeId;
  final String name;
  final String description;
  final int rewardPoints;
  final bool isActive;

  const WasteType({
    required this.wasteTypeId,
    required this.name,
    this.description = '',
    this.rewardPoints = 0,
    this.isActive = true,
  });

  factory WasteType.fromJson(Map<String, dynamic> json) {
    return WasteType(
      wasteTypeId: JsonHelpers.intValue(json, [
        'wasteTypeId',
        'WasteTypeId',
        'id',
        'Id',
      ]),
      name: JsonHelpers.stringValue(json, ['name', 'Name']),
      description: JsonHelpers.stringValue(json, [
        'description',
        'Description',
      ]),
      rewardPoints: JsonHelpers.intValue(json, [
        'rewardPoints',
        'RewardPoints',
      ]),
      isActive: JsonHelpers.boolValue(json, [
        'isActive',
        'IsActive',
      ], fallback: true),
    );
  }
}
