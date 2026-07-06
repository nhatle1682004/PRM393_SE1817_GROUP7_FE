class JsonHelpers {
  const JsonHelpers._();

  static dynamic pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) return json[key];
    }
    return null;
  }

  static int intValue(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    final value = pick(json, keys);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double doubleValue(
    Map<String, dynamic> json,
    List<String> keys, {
    double fallback = 0,
  }) {
    final value = pick(json, keys);
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool boolValue(
    Map<String, dynamic> json,
    List<String> keys, {
    bool fallback = false,
  }) {
    final value = pick(json, keys);
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return fallback;
  }

  static String stringValue(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    final value = pick(json, keys);
    return value?.toString() ?? fallback;
  }

  static DateTime? dateValue(Map<String, dynamic> json, List<String> keys) {
    final value = pick(json, keys);
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static List<int> intList(Map<String, dynamic> json, List<String> keys) {
    final value = pick(json, keys);
    if (value is List) {
      return value
          .map((item) => int.tryParse(item.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }
    return const [];
  }

  static List<String> stringList(Map<String, dynamic> json, List<String> keys) {
    final value = pick(json, keys);
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.isNotEmpty) return [value];
    return const [];
  }
}
