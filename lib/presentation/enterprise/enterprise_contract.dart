import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

abstract class EnterpriseView {
  void onLoadingStateChanged(bool isLoading);
  void onStatsLoaded(EnterpriseStats stats);
  void onUserProfileLoaded(UserProfile? profile);
  void onNotificationsLoaded(List<EnterpriseNotification> notifications);
  void onDashboardDataLoaded(List<EnterpriseCollectionRequest> requests, List<EnterpriseReport> recentReports);
  void onTabUpdated(int index);
  void onPendingAssignmentSet(int? requestId);
  void onError(String? message);
  void navigateToLogin();
}

abstract class EnterprisePresenter {
  void loadStats();
  void loadUserProfile();
  void loadNotifications();
  void loadDashboardData();
  void markAllNotificationsRead();
  void markNotificationRead(int id);
  void handleLogout();
  void setTab(int index);
  void setPendingAssignment(int requestId);
  void dispose();
}
