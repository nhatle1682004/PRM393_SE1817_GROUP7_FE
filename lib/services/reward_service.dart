import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/reward.dart';
import 'package:waste_collection_management_system/data/models/reward_transaction.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class RewardService {
  Future<int> getBalance() async {
    final response = await ApiService.get(ApiConfig.rewardsBalance);
    final data = response.data;
    if (data is Map)
      return int.tryParse(
            (data['totalPoints'] ?? data['TotalPoints'] ?? 0).toString(),
          ) ??
          0;
    return int.tryParse(data?.toString() ?? '') ?? 0;
  }

  Future<List<RewardTransaction>> getHistory() async {
    final response = await ApiService.get(ApiConfig.rewardsHistory);
    return _list(response.data).map(RewardTransaction.fromJson).toList();
  }

  Future<List<Reward>> getCatalog() async {
    final response = await ApiService.get(ApiConfig.rewardsCatalog);
    return _list(response.data).map(Reward.fromJson).toList();
  }

  Future<void> redeemReward(int rewardId) async {
    await ApiService.post(
      ApiConfig.rewardsRedeem,
      body: {'rewardId': rewardId},
    );
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    if (data is List)
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    return const [];
  }
}
