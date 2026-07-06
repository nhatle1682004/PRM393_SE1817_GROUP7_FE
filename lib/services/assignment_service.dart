import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/assignment.dart';
import 'package:waste_collection_management_system/data/models/collection_request.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class AssignmentService {
  Future<List<CollectionRequest>> getCollectionRequests() async {
    final response = await ApiService.get(ApiConfig.collectionRequests);
    return _list(response.data).map(CollectionRequest.fromJson).toList();
  }

  Future<List<CollectionRequest>> getAllCollectionRequests() async {
    final response = await ApiService.get(ApiConfig.collectionRequestAll);
    return _list(response.data).map(CollectionRequest.fromJson).toList();
  }

  Future<CollectionRequest> getCollectionRequestById(int id) async {
    final response = await ApiService.get(
      ApiConfig.collectionRequestDetails(id),
    );
    return CollectionRequest.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<Assignment>> getAssignmentHistory(int requestId) async {
    final response = await ApiService.get(
      ApiConfig.collectionAssignmentHistory(requestId),
    );
    return _list(response.data).map(Assignment.fromJson).toList();
  }

  Future<void> assignCollector({
    required int requestId,
    required int collectorId,
  }) async {
    await ApiService.post(
      ApiConfig.assignments,
      body: {'requestId': requestId, 'collectorId': collectorId},
    );
  }

  Future<Assignment> getAssignmentById(int id) async {
    final response = await ApiService.get(ApiConfig.assignmentDetails(id));
    return Assignment.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> cancelAssignment(int id) async =>
      ApiService.put(ApiConfig.cancelAssignment(id));

  Future<List<Assignment>> getMyAssignments() async {
    final response = await ApiService.get(ApiConfig.myAssignments);
    return _list(response.data).map(Assignment.fromJson).toList();
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    if (data is List)
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    return const [];
  }
}
