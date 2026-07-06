import '../../data/models/home_stats.dart';

abstract class HomeView {
  void onTabUpdated(int index);
  void onStatsLoaded(HomeStats stats);
  void onLoadingStateChanged(bool isLoading);
  void onError(String? error);
}

abstract class HomePresenter {
  void handleTabChange(int index);
  void loadDashboardData();
  void dispose();
}
