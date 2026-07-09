class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['districtId'] ?? json['id'] ?? 0,
      name: json['districtName'] ?? json['name'] ?? 'N/A',
    );
  }
}
