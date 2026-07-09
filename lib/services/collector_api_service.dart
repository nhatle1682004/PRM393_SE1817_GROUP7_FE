import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class CollectorApiService {
  // Lấy danh sách việc được giao cho tôi
  static Future<List<EnterpriseAssignment>> getMyAssignments() async {
    try {
      final response = await ApiService.get(ApiConfig.myAssignments);
      final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((e) => EnterpriseAssignment.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Bắt đầu thu gom (OnTheWay)
  static Future<void> startCollection(int assignmentId) async {
    try {
      await ApiService.put(ApiConfig.startCollection(assignmentId));
    } catch (e) {
      rethrow;
    }
  }

  // Xác nhận đã đến nơi (Arrived)
  static Future<void> confirmArrival(int assignmentId) async {
    try {
      await ApiService.put(ApiConfig.confirmArrival(assignmentId));
    } catch (e) {
      rethrow;
    }
  }

  // Hoàn thành thu gom (Completed)
  static Future<void> completeCollection(int assignmentId) async {
    try {
      await ApiService.put(ApiConfig.completeCollection(assignmentId));
    } catch (e) {
      rethrow;
    }
  }

  // Từ chối phân công (Decline)
  static Future<void> declineAssignment(int assignmentId, String reason) async {
    try {
      await ApiService.put(
        ApiConfig.declineAssignment(assignmentId),
        body: {'reason': reason},
      );
    } catch (e) {
      rethrow;
    }
  }
}
