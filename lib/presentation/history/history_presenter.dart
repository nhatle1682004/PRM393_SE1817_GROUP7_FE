import 'package:waste_collection_management_system/data/models/citizen_reward.dart';
import 'package:waste_collection_management_system/services/rewards_api_service.dart';
import 'package:waste_collection_management_system/services/citizen_api_service.dart';
import 'history_contract.dart';

class HistoryPresenterImpl implements HistoryPresenter {
  final HistoryView _view;

  HistoryPresenterImpl(this._view);

  @override
  void loadHistory() async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final results = await Future.wait([
        RewardsApiService.getHistory(),
        RewardsApiService.getBalance(),
      ]);

      final transactions = results[0] as List<RewardTransaction>;
      final balance = results[1] as RewardBalance;

      _view.onHistoryLoaded(transactions);
      _view.onBalanceLoaded(balance.totalPoints);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void loadReports() async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final reports = await CitizenApiService.getMyReports();
      _view.onReportsLoaded(reports);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void refreshHistory() async {
    try {
      final results = await Future.wait([
        RewardsApiService.getHistory(),
        RewardsApiService.getBalance(),
      ]);

      final transactions = results[0] as List<RewardTransaction>;
      final balance = results[1] as RewardBalance;

      _view.onHistoryLoaded(transactions);
      _view.onBalanceLoaded(balance.totalPoints);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onRefreshComplete();
    }
  }

  @override
  void dispose() {}
}
