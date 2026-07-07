import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

// Helper function để parse list response từ Backend (hỗ trợ cả direct array và pagination wrapper)
List<dynamic> _parseListData(dynamic responseData) {
  if (responseData is List) {
    return responseData;
  } else if (responseData is Map<String, dynamic>) {
    return responseData['data'] as List<dynamic>? ?? [];
  }
  return [];
}

class EnterpriseApiService {
  // ============ DASHBOARD ============
  // NOTE: Enterprise Dashboard không có endpoint riêng, cần gọi nhiều API
  // FE sẽ gọi: collectors, collection-requests, assignments, waste-reports
  static Future<EnterpriseStats> getEnterpriseDashboard() async {
    try {
      // Gọi song song các API để lấy dữ liệu dashboard
      final results = await Future.wait([
        ApiService.get(ApiConfig.enterpriseCollectors),
        ApiService.get(ApiConfig.enterpriseCollectionRequests),
        ApiService.get(ApiConfig.enterpriseAssignments),
        ApiService.get(ApiConfig.enterpriseReports),
      ]);

      final collectors = _parseListData(results[0].data);
      final collectionRequests = _parseListData(results[1].data);
      final assignments = _parseListData(results[2].data);
      final reports = _parseListData(results[3].data);

      int pendingCollections = 0;
      int completedCollections = 0;
      int inProgressCollections = 0;
      int cancelledCollections = 0;

      for (var a in assignments) {
        final status = (a['status'] ?? '').toString().toLowerCase();
        if (status.contains('completed') || status.contains('hoàn thành')) {
          completedCollections++;
        } else if (status.contains('cancelled') || status.contains('hủy')) {
          cancelledCollections++;
        } else if (status.contains('on') || status.contains('progress') || status.contains('đang')) {
          inProgressCollections++;
        } else {
          pendingCollections++;
        }
      }

      int pendingReports = 0;
      for (var r in reports) {
        final status = (r['status'] ?? '').toString().toLowerCase();
        if (status.contains('pending') || status.contains('chờ')) {
          pendingReports++;
        }
      }

      return EnterpriseStats(
        totalCollectors: collectors.length,
        totalCollections: collectionRequests.length,
        pendingCollections: pendingCollections,
        completedCollections: completedCollections,
        inProgressCollections: inProgressCollections,
        cancelledCollections: cancelledCollections,
        totalReports: reports.length,
        pendingReports: pendingReports,
        staffCount: collectors.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ COLLECTORS ============
  static Future<List<EnterpriseCollector>> getCollectors() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseCollectors);
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseCollector.fromJson(e)).toList();
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
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseCollectionRequest.fromJson(e)).toList();
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
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseAssignment.fromJson(e)).toList();
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
        ApiConfig.enterpriseAssignmentDetail(assignmentId),
      );
      return CancelAssignmentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Gán lại collector cho phân công
  static Future<CollectorAssignmentResponse> reassignCollector(
    int assignmentId,
    int newCollectorId,
  ) async {
    try {
      final response = await ApiService.put(
        ApiConfig.enterpriseAssignmentDetail(assignmentId),
        body: {'collectorId': newCollectorId},
      );
      return CollectorAssignmentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ REPORTS ============
  // Enterprise lấy waste-reports theo district của mình
  static Future<List<EnterpriseReport>> getReportsByDistrict(int districtId) async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseReportsByDistrict(districtId));
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseReport.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy tất cả reports (chỉ dùng cho Dashboard)
  static Future<List<EnterpriseReport>> getReports() async {
    try {
      final response = await ApiService.get(ApiConfig.enterpriseReports);
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseReport.fromJson(e)).toList();
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

  static Future<EnterpriseReport> assignReport(int reportId, int collectorId) async {
    try {
      final response = await ApiService.put(
        ApiConfig.enterpriseAssignReport(reportId),
        body: {'collectorId': collectorId},
      );
      return EnterpriseReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ FEEDBACKS ============
  // Enterprise lấy feedbacks của các báo cáo thuộc quận mình quản lý
  // API BE: GET /api/feedbacks (filter theo district của Enterprise)
  static Future<List<EnterpriseFeedback>> getFeedbacks() async {
    try {
      final response = await ApiService.get(ApiConfig.feedbacks);
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseFeedback.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy feedbacks theo reportId
  static Future<List<EnterpriseFeedback>> getFeedbacksByReport(int reportId) async {
    try {
      final response = await ApiService.get('/feedbacks/report/$reportId');
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseFeedback.fromJson(e)).toList();
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
      final dataList = _parseListData(response.data);
      return dataList.map((e) => EnterpriseNotification.fromJson(e)).toList();
    } catch (e) {
      // Nếu lỗi API, có thể dùng mock data để UI vẫn hiển thị được (tùy nhu cầu)
      // Nhưng ở đây ta nên rethrow để FE xử lý lỗi
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
