import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/feedback.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class FeedbackService {
  Future<List<FeedbackItem>> getFeedbacks() async {
    final response = await ApiService.get(ApiConfig.feedbacks);
    return _list(response.data).map(FeedbackItem.fromJson).toList();
  }

  Future<void> createFeedback({
    required int reportId,
    required String content,
    File? image,
    XFile? webImage,
  }) async {
    await ApiService.multipart(
      ApiConfig.feedbacks,
      fields: {'ReportId': reportId, 'Content': content},
      files: {'Image': image},
      webFiles: {'Image': webImage},
    );
  }

  Future<List<FeedbackItem>> getByReport(int reportId) async {
    final response = await ApiService.get(
      ApiConfig.feedbacksByReport(reportId),
    );
    return _list(response.data).map(FeedbackItem.fromJson).toList();
  }

  Future<FeedbackItem> getById(int id) async {
    final response = await ApiService.get(ApiConfig.feedbackDetails(id));
    return FeedbackItem.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> resolve(
    int id, {
    String action = 'reassign',
    String? note,
  }) async {
    await ApiService.put(
      ApiConfig.feedbackResolve(id),
      body: {'action': action, 'adminNote': note ?? ''},
    );
  }

  Future<void> reject(int id, {String? reason}) async {
    await ApiService.put(ApiConfig.feedbackReject(id));
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    if (data is List)
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    return const [];
  }
}
