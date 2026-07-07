import 'package:waste_collection_management_system/data/models/citizen_reward.dart';

abstract class RewardsView {
  void onLoadingStateChanged(bool isLoading);
  void onRewardsLoaded(List<RewardVoucher> rewards);
  void onBalanceLoaded(int balance);
  void onRedeemSuccess(String message, int remainingPoints);
  void onRedeemError(String message);
  void onRedeemInProgress(bool isRedeeming);
  void onError(String? message);
  void onRefreshComplete();
}

abstract class RewardsPresenter {
  void loadRewards();
  void refreshRewards();
  void redeemReward(RewardVoucher reward);
  void dispose();
}
