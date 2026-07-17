import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/presentation/history/history_contract.dart';
import 'package:image_picker/image_picker.dart';

class CitizenApiService {
  CitizenApiService._();

  static Future<List<WasteReportItem>> getMyReports() async {
    try {
      // Backend có: GET /api/waste-reports - lấy danh sách báo cáo
      final response = await ApiService.get(ApiConfig.wasteReports);
      final data = response.data;

      if (data is List) {
        return data.map((e) => WasteReportItem.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<WasteReportItem> getReportById(int reportId) async {
    try {
      final response = await ApiService.get(ApiConfig.reportDetails(reportId));
      return WasteReportItem.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cancelReport(int reportId) async {
    try {
      await ApiService.put(ApiConfig.cancelWasteReport(reportId));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createFeedback({
    required int reportId,
    required String content,
    XFile? image,
  }) async {
    try {
      await ApiService.postMultipartForm(
        ApiConfig.feedbacks,
        fields: {
          'ReportId': reportId,
          'Content': content,
        },
        files: image == null ? const {} : {'Image': image},
      );
    } catch (e) {
      rethrow;
    }
  }
}
