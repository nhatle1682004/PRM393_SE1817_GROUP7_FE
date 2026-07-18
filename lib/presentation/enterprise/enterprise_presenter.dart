import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'enterprise_contract.dart';

class EnterprisePresenterImpl implements EnterprisePresenter {
  final EnterpriseView _view;

  EnterprisePresenterImpl(this._view);

  @override
  Future<void> loadStats() async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final stats = await EnterpriseApiService.getEnterpriseDashboard();
      _view.onStatsLoaded(stats);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  Future<void> loadUserProfile() async {
    final profile = await AuthService.getProfile();
    _view.onUserProfileLoaded(profile);
  }

  @override
  Future<void> loadNotifications() async {
    try {
      final notifications = await EnterpriseApiService.getNotifications();
      _view.onNotificationsLoaded(notifications);
    } catch (_) {}
  }

  @override
  Future<void> loadDashboardData() async {
    final profile = await AuthService.getProfile();
    final districtId = profile?.managedDistrictId;
    try {
      final results = await Future.wait([
        EnterpriseApiService.getCollectionRequests(),
        districtId != null
          ? EnterpriseApiService.getReportsByDistrict(districtId)
          : EnterpriseApiService.getReports(),
      ]);

      final requests = results[0] as List<EnterpriseCollectionRequest>;
      final reports = results[1] as List<EnterpriseReport>;

      _view.onDashboardDataLoaded(requests, reports.take(5).toList());
    } catch (_) {}
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await EnterpriseApiService.markAllNotificationsRead();
      await loadNotifications();
    } catch (_) {}
  }

  @override
  Future<void> markNotificationRead(int id) async {
    try {
      await EnterpriseApiService.markNotificationRead(id);
      await loadNotifications();
    } catch (_) {}
  }

  @override
  Future<void> handleLogout() async {
    final authService = AuthService();
    await authService.logout();
    _view.navigateToLogin();
  }

  @override
  void setTab(int index) {
    _view.onTabUpdated(index);
  }

  @override
  void setPendingAssignment(int requestId) {
    _view.onPendingAssignmentSet(requestId);
    _view.onTabUpdated(1); // Chuyển sang tab Tiến độ xử lý
  }

  @override
  void dispose() {}
}
