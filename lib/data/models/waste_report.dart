class WasteReport {
  final List<String> types;
  final String description;
  final double? latitude;
  final double? longitude;
  final bool hasImage;

  WasteReport({
    required this.types,
    required this.description,
    this.latitude,
    this.longitude,
    this.hasImage = false,
  });
}
