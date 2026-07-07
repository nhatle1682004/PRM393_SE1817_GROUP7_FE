import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/data/models/citizen_reward.dart';

class RewardsApiService {
  RewardsApiService._();

  static Future<List<RewardVoucher>> getCatalog() async {
    try {
      final response = await ApiService.get(ApiConfig.rewardsCatalog);
      final data = response.data;

      if (data is List) {
        return data.map((e) => RewardVoucher.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<RewardBalance> getBalance() async {
    try {
      final response = await ApiService.get(ApiConfig.rewardsBalance);
      return RewardBalance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return RewardBalance(totalPoints: 0);
    }
  }

  static Future<List<RewardTransaction>> getHistory() async {
    try {
      final response = await ApiService.get(ApiConfig.rewardsHistory);
      final data = response.data;

      if (data is List) {
        return data.map((e) => RewardTransaction.fromJson(e as Map<String, dynamic>)).toList();
      }

      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => RewardTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<RedeemRewardResponse> redeem(RewardVoucher voucher) async {
    try {
      final response = await ApiService.post(
        ApiConfig.rewardsRedeem,
        body: {
          'rewardId': voucher.rewardId,
          'quantity': 1,
        },
      );

      return RedeemRewardResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
