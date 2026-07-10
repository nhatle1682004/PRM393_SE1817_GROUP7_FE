import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class CollectorApiService {
  // Lấy danh sách việc được giao cho tôi
  static Future<List<EnterpriseAssignment>> getMyAssignments() async {
    try {
      final response = await ApiService.get(ApiConfig.myAssignments);
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
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
  static Future<void> confirmArrival(
    int assignmentId, {
    required XFile beforeImage,
    String? note,
  }) async {
    try {
      await ApiService.putMultipartForm(
        ApiConfig.confirmArrival(assignmentId),
        fields: {
          if (note != null && note.trim().isNotEmpty) 'Note': note.trim(),
        },
        files: {'BeforeImage': beforeImage},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Hoàn thành thu gom (Completed)
  static Future<void> completeCollection(
    int assignmentId, {
    required XFile afterImage,
    required Map<int, double> actualWeights,
    String? note,
  }) async {
    try {
      final fields = <String, dynamic>{
        if (note != null && note.trim().isNotEmpty) 'Note': note.trim(),
      };

      final weightEntries = actualWeights.entries.toList();
      for (var index = 0; index < weightEntries.length; index++) {
        fields['ActualWeights[$index].WasteTypeId'] = weightEntries[index].key;
        fields['ActualWeights[$index].Weight'] = weightEntries[index].value;
      }

      await ApiService.putMultipartForm(
        ApiConfig.completeCollection(assignmentId),
        fields: fields,
        files: {'AfterImage': afterImage},
      );
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
