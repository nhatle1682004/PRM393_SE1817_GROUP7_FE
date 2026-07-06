import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class CollectionService {
  Future<void> startCollection(int assignmentId) async =>
      ApiService.put(ApiConfig.startCollection(assignmentId));

  Future<void> declineAssignment(int assignmentId, String reason) async {
    await ApiService.put(
      ApiConfig.declineAssignment(assignmentId),
      body: {'reason': reason},
    );
  }

  Future<void> arrived({
    required int assignmentId,
    File? beforeImage,
    XFile? webBeforeImage,
    String? note,
  }) async {
    await ApiService.multipart(
      ApiConfig.confirmArrival(assignmentId),
      method: 'PUT',
      fields: {'Note': note ?? ''},
      files: {'BeforeImage': beforeImage},
      webFiles: {'BeforeImage': webBeforeImage},
    );
  }

  Future<void> complete({
    required int assignmentId,
    File? afterImage,
    XFile? webAfterImage,
    required int wasteTypeId,
    required double weight,
    String? note,
  }) async {
    await ApiService.multipart(
      ApiConfig.completeCollection(assignmentId),
      method: 'PUT',
      fields: {
        'Note': note ?? '',
        'ActualWeights[0].WasteTypeId': wasteTypeId,
        'ActualWeights[0].Weight': weight,
      },
      files: {'AfterImage': afterImage},
      webFiles: {'AfterImage': webAfterImage},
    );
  }

  Future<void> reportIssue({
    required int assignmentId,
    required String issueType,
    required String issueDescription,
    File? issueImage,
    XFile? webIssueImage,
  }) async {
    await ApiService.multipart(
      ApiConfig.reportCollectionIssue(assignmentId),
      method: 'PUT',
      fields: {'IssueType': issueType, 'Description': issueDescription},
      files: {'ProofImage': issueImage},
      webFiles: {'ProofImage': webIssueImage},
    );
  }
}
