import 'package:waste_collection_management_system/data/models/citizen_reward.dart';
import 'package:waste_collection_management_system/services/rewards_api_service.dart';
import 'rewards_contract.dart';

class RewardsPresenterImpl implements RewardsPresenter {
  final RewardsView _view;
  bool _isRedeeming = false;

  RewardsPresenterImpl(this._view);

  @override
  void loadRewards() async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final results = await Future.wait([
        RewardsApiService.getCatalog(),
        RewardsApiService.getBalance(),
      ]);

      final rewards = results[0] as List<RewardVoucher>;
      final balance = results[1] as RewardBalance;

      _view.onRewardsLoaded(rewards);
      _view.onBalanceLoaded(balance.totalPoints);
    } catch (e) {
      _view.onError('Không thể tải danh sách phần thưởng. Vui lòng thử lại.');
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void refreshRewards() async {
    try {
      final results = await Future.wait([
        RewardsApiService.getCatalog(),
        RewardsApiService.getBalance(),
      ]);

      final rewards = results[0] as List<RewardVoucher>;
      final balance = results[1] as RewardBalance;

      _view.onRewardsLoaded(rewards);
      _view.onBalanceLoaded(balance.totalPoints);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onRefreshComplete();
    }
  }

  @override
  void redeemReward(RewardVoucher reward) async {
    if (_isRedeeming) return;
    
    _isRedeeming = true;
    _view.onRedeemInProgress(true);
    _view.onRedeemError('');

    try {
      final response = await RewardsApiService.redeem(reward);
      
      if (response.success) {
        _view.onRedeemSuccess(
          response.message ?? 'Đổi quà thành công!',
          response.remainingPoints ?? 0,
        );
        // Reload balance after successful redemption
        final balance = await RewardsApiService.getBalance();
        _view.onBalanceLoaded(balance.totalPoints);
      } else {
        _view.onRedeemError(response.message ?? 'Đổi quà thất bại');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      _view.onRedeemError(errorMsg);
    } finally {
      _isRedeeming = false;
      _view.onRedeemInProgress(false);
    }
  }

  @override
  void dispose() {}
}
