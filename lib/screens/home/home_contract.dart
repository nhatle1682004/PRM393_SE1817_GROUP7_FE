abstract class HomeView {
  void onTabUpdated(int index);
  // Add other view methods here as needed, e.g., showLoading, showError, refreshData
}

abstract class HomePresenter {
  void handleTabChange(int index);
  void dispose();
}
