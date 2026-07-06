import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/waste_report.dart';
import 'package:waste_collection_management_system/data/models/waste_type.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class WasteReportService {
  Future<List<WasteReport>> getReports() async {
    final response = await ApiService.get(ApiConfig.wasteReports);
    return _list(response.data).map(WasteReport.fromJson).toList();
  }

  Future<WasteReport> getReportById(int id) async {
    final response = await ApiService.get(ApiConfig.reportDetails(id));
    return WasteReport.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> createReport({
    File? imageFile,
    XFile? webImageFile,
    required double latitude,
    required double longitude,
    required String description,
    required List<int> wasteTypeIds,
  }) async {
    await ApiService.uploadMultipart(
      ApiConfig.wasteReports,
      imageFile: imageFile,
      webImageFile: webImageFile,
      latitude: latitude,
      longitude: longitude,
      description: description,
      wasteTypeIds: wasteTypeIds,
    );
  }

  Future<void> updateReport(int id, Map<String, dynamic> body) async =>
      ApiService.put(ApiConfig.reportDetails(id), body: body);
  Future<void> cancelReport(int id) async =>
      ApiService.put(ApiConfig.cancelWasteReport(id));
  Future<void> acceptReport(int id) async =>
      ApiService.put(ApiConfig.acceptWasteReport(id));
  Future<void> rejectReport(int id) async =>
      ApiService.put(ApiConfig.rejectWasteReport(id));

  Future<List<WasteType>> getWasteTypes() async {
    final response = await ApiService.get(ApiConfig.wasteTypes);
    return _list(
      response.data,
    ).map(WasteType.fromJson).where((type) => type.isActive).toList();
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    if (data is List)
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    return const [];
  }
}
