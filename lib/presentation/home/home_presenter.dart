import '../../data/models/home_stats.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'home_contract.dart';

class HomePresenterImpl implements HomePresenter {
  final HomeView _view;

  HomePresenterImpl(this._view);

  @override
  void handleTabChange(int index) {
    _view.onTabUpdated(index);
  }

  @override
  void loadDashboardData() async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final profileResponse = await ApiService.get(ApiConfig.profile);
      final profileData = profileResponse.data as Map<String, dynamic>;

      String totalPoints = '0';
      String reportsSubmitted = '0';
      String rewardEvents = '0';

      try {
        final rewardsResponse = await ApiService.get(ApiConfig.rewardsBalance);
        final rewardsData = rewardsResponse.data as Map<String, dynamic>;
        totalPoints = (rewardsData['balance'] ?? rewardsData['points'] ?? 0).toString();
      } catch (_) {
        // Rewards endpoint not ready yet - keep default 0
      }

      try {
        final reportsResponse = await ApiService.get(ApiConfig.wasteReports);
        if (reportsResponse.data is List) {
          reportsSubmitted = (reportsResponse.data as List).length.toString();
        } else if (reportsResponse.data is Map && reportsResponse.data['data'] is List) {
          reportsSubmitted = (reportsResponse.data['data'] as List).length.toString();
        }
      } catch (_) {
        // Reports endpoint not ready yet - keep default 0
      }

      final stats = HomeStats(
        totalPoints: totalPoints,
        reportsSubmitted: reportsSubmitted,
        rewardEvents: rewardEvents,
        userName: profileData['fullName']?.toString() ?? '',
        userEmail: profileData['email']?.toString() ?? '',
      );

      _view.onStatsLoaded(stats);
    } catch (e) {
      // API error - don't show error, just load with empty stats
      // This allows the home page to display with demo/empty values
      _view.onStatsLoaded(HomeStats());
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void dispose() {}
}
