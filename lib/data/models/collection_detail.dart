import 'json_helpers.dart';

class CollectionDetail {
  final int wasteTypeId;
  final String wasteTypeName;
  final double weight;

  const CollectionDetail({
    required this.wasteTypeId,
    this.wasteTypeName = '',
    required this.weight,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) {
    return CollectionDetail(
      wasteTypeId: JsonHelpers.intValue(json, ['wasteTypeId', 'WasteTypeId']),
      wasteTypeName: JsonHelpers.stringValue(json, [
        'wasteTypeName',
        'WasteTypeName',
        'name',
        'Name',
      ]),
      weight: JsonHelpers.doubleValue(json, [
        'weight',
        'Weight',
        'actualWeight',
        'ActualWeight',
      ]),
    );
  }
}
