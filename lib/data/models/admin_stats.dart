class AdminStats {
  final int totalUsers;
  final int totalReports;
  final int totalCollections;
  final int totalFeedbacks;
  final int pendingReports;
  final int pendingFeedbacks;
  final List<MonthlyData> monthlyReports;
  final List<MonthlyData> monthlyCollections;
  final Map<String, int> reportStatusBreakdown;
  final Map<String, int> userRoleBreakdown;

  AdminStats({
    this.totalUsers = 0,
    this.totalReports = 0,
    this.totalCollections = 0,
    this.totalFeedbacks = 0,
    this.pendingReports = 0,
    this.pendingFeedbacks = 0,
    this.monthlyReports = const [],
    this.monthlyCollections = const [],
    this.reportStatusBreakdown = const {},
    this.userRoleBreakdown = const {},
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    Map<String, int> _toMap(dynamic val) {
      if (val == null || val is! Map) return {};
      final rawMap = Map<String, dynamic>.from(val);
      return rawMap.map((key, value) => MapEntry(key, _toInt(value)));
    }

    return AdminStats(
      totalUsers: _toInt(json['totalUsers']),
      totalReports: _toInt(json['totalReports']),
      totalCollections: _toInt(json['totalCollections']),
      totalFeedbacks: _toInt(json['totalFeedbacks']),
      pendingReports: _toInt(json['pendingReports']),
      pendingFeedbacks: _toInt(json['pendingFeedbacks']),
      monthlyReports: (json['monthlyReports'] as List<dynamic>?)
              ?.map((e) => MonthlyData.fromJson(e))
              .toList() ??
          [],
      monthlyCollections: (json['monthlyCollections'] as List<dynamic>?)
              ?.map((e) => MonthlyData.fromJson(e))
              .toList() ??
          [],
      reportStatusBreakdown: _toMap(json['reportStatusBreakdown']),
      userRoleBreakdown: _toMap(json['userRoleBreakdown']),
    );
  }
}

class MonthlyData {
  final String month;
  final int count;

  MonthlyData({required this.month, required this.count});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
