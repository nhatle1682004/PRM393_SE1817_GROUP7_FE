import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class EnterpriseApiService {
  // ============ DASHBOARD ============
  static Future<EnterpriseStats> getEnterpriseDashboard() async {
    try {
      final response = await ApiService.get(ApiConfig.dashboardEnterprise);
      if (response.data != null) {
        return EnterpriseStats.fromJson(response.data);
      }
      return EnterpriseStats();
    } catch (e) {
      rethrow;
    }
  }

  // ============ COLLECTORS ============
  static Future<List<EnterpriseCollector>> getCollectors() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseCollectors);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => EnterpriseCollector.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<EnterpriseCollector> getCollectorById(int collectorId) async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseCollector(collectorId));
      return EnterpriseCollector.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<EnterpriseCollector> updateCollectorAvailability(
    int collectorId,
    bool isAvailable,
  ) async {
    try {
      final response = await ApiService.put(
        ApiConfig.enterpriseCollectorAvailability(collectorId),
        body: {'isAvailable': isAvailable},
      );
      return EnterpriseCollector.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ COLLECTION REQUESTS ============
  static Future<List<EnterpriseCollectionRequest>> getCollectionRequests() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseCollectionRequests);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => EnterpriseCollectionRequest.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<CollectionRequestDetail> getCollectionRequestById(int requestId) async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseCollectionRequest(requestId));
      return CollectionRequestDetail.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ ASSIGNMENTS ============
  static Future<List<EnterpriseAssignment>> getAssignments() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseAssignments);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => EnterpriseAssignment.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<CollectorAssignmentResponse> assignCollector(
    AssignCollectorRequest request,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConfig.enterpriseAssignCollector,
        body: request.toJson(),
      );
      return CollectorAssignmentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<CancelAssignmentResponse> cancelAssignment(int assignmentId) async {
    try {
      final response = await ApiService.put(
        ApiConfig.enterpriseCancelAssignment(assignmentId),
      );
      return CancelAssignmentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ REPORTS ============
  static Future<List<EnterpriseReport>> getReports() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseReports);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => EnterpriseReport.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<EnterpriseReport> acceptReport(int reportId) async {
    try {
      final response = await ApiService.put(ApiConfig.enterpriseAcceptReport(reportId));
      return EnterpriseReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<EnterpriseReport> rejectReport(int reportId) async {
    try {
      final response = await ApiService.put(ApiConfig.enterpriseRejectReport(reportId));
      return EnterpriseReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ FEEDBACKS ============
  static Future<List<EnterpriseFeedback>> getFeedbacks() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseFeedbacks);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => EnterpriseFeedback.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<EnterpriseFeedback> resolveFeedback(
    int feedbackId,
    ResolveFeedbackRequest request,
  ) async {
    try {
      final response = await ApiService.put(
        ApiConfig.enterpriseFeedbackResolve(feedbackId),
        body: request.toJson(),
      );
      return EnterpriseFeedback.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<EnterpriseFeedback> rejectFeedback(int feedbackId) async {
    try {
      final response = await ApiService.put(
        ApiConfig.enterpriseFeedbackReject(feedbackId),
      );
      return EnterpriseFeedback.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ NOTIFICATIONS ============
  static Future<List<EnterpriseNotification>> getNotifications() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseNotifications);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => EnterpriseNotification.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markNotificationRead(int notificationId) async {
    try {
      await ApiService.put(ApiConfig.enterpriseMarkNotificationRead(notificationId));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markAllNotificationsRead() async {
    try {
      await ApiService.put(ApiConfig.enterpriseMarkAllNotificationsRead);
    } catch (e) {
      rethrow;
    }
  }
}
