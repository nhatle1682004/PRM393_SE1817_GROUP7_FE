import 'home_contract.dart';

class HomePresenterImpl implements HomePresenter {
  final HomeView _view;

  HomePresenterImpl(this._view);

  @override
  void handleTabChange(int index) {
    // Business logic can go here (e.g. analytics, data fetching on tab change)
    _view.onTabUpdated(index);
  }

  @override
  void dispose() {
    // Cleanup logic
  }
}
