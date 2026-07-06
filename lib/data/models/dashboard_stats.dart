import 'json_helpers.dart';

class DashboardStats {
  final int totalUsers;
  final int totalReports;
  final int totalCompletedCollections;
  final int totalAssignments;
  final int totalRewards;

  const DashboardStats({
    this.totalUsers = 0,
    this.totalReports = 0,
    this.totalCompletedCollections = 0,
    this.totalAssignments = 0,
    this.totalRewards = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: JsonHelpers.intValue(json, ['totalUsers', 'TotalUsers']),
      totalReports: JsonHelpers.intValue(json, [
        'totalReports',
        'TotalReports',
      ]),
      totalCompletedCollections: JsonHelpers.intValue(json, [
        'totalCompletedCollections',
        'TotalCompletedCollections',
        'completedCollections',
        'CompletedCollections',
      ]),
      totalAssignments: JsonHelpers.intValue(json, [
        'totalAssignments',
        'TotalAssignments',
      ]),
      totalRewards: JsonHelpers.intValue(json, [
        'totalRewards',
        'TotalRewards',
        'totalPoints',
        'TotalPoints',
      ]),
    );
  }
}
