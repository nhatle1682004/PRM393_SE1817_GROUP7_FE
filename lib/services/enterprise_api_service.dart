import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

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

      final collectors = results[0].data as List<dynamic>? ?? [];
      final collectionRequests = results[1].data as List<dynamic>? ?? [];
      final assignments = results[2].data as List<dynamic>? ?? [];
      final reports = results[3].data as List<dynamic>? ?? [];

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
    // Mock data tạm thời để test UI
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      EnterpriseCollector(
        collectorId: 1,
        fullName: 'Trần Văn Minh',
        email: 'minh.tv@company.com',
        phone: '0901234567',
        isAvailable: true,
        completedCount: 45,
        totalAssignments: 52,
        warningCount: 1,
      ),
      EnterpriseCollector(
        collectorId: 2,
        fullName: 'Nguyễn Thị Hương',
        email: 'huong.nt@company.com',
        phone: '0902345678',
        isAvailable: true,
        completedCount: 38,
        totalAssignments: 40,
        warningCount: 0,
      ),
      EnterpriseCollector(
        collectorId: 3,
        fullName: 'Lê Đức Anh',
        email: 'anh.ld@company.com',
        phone: '0903456789',
        isAvailable: false,
        completedCount: 28,
        totalAssignments: 35,
        warningCount: 2,
      ),
      EnterpriseCollector(
        collectorId: 4,
        fullName: 'Phạm Thị Mai',
        email: 'mai.pt@company.com',
        phone: '0904567890',
        isAvailable: true,
        completedCount: 52,
        totalAssignments: 55,
        warningCount: 0,
      ),
    ];
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
    // Mock data tạm thời để test UI
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      EnterpriseCollectionRequest(
        requestId: 1,
        reportId: 101,
        enterpriseId: 1,
        enterpriseName: 'Công ty A',
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        wasteTypeName: 'Household',
        reportDescription: 'Rác tích tụ tại khu vực Q.1',
        reportStatus: 'Pending',
      ),
      EnterpriseCollectionRequest(
        requestId: 2,
        reportId: 102,
        enterpriseId: 1,
        enterpriseName: 'Công ty B',
        status: 'InProgress',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        wasteTypeName: 'Recyclable',
        reportDescription: 'Rác tái chế tại khu vực Q.3',
        reportStatus: 'InProgress',
        assignedCollectorId: 2,
        assignedCollectorName: 'Nguyễn Thị Hương',
      ),
      EnterpriseCollectionRequest(
        requestId: 3,
        reportId: 103,
        enterpriseId: 1,
        enterpriseName: 'Công ty C',
        status: 'Completed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        wasteTypeName: 'Hazardous',
        reportDescription: 'Rác nguy hại tại khu vực Q.Bình Thạnh',
        reportStatus: 'Completed',
        assignedCollectorId: 1,
        assignedCollectorName: 'Trần Văn Minh',
      ),
      EnterpriseCollectionRequest(
        requestId: 4,
        reportId: 104,
        enterpriseId: 1,
        enterpriseName: 'Công ty D',
        status: 'Cancelled',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        wasteTypeName: 'Household',
        reportDescription: 'Yêu cầu bị hủy do trùng lịch',
        reportStatus: 'Cancelled',
      ),
    ];
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
    // Mock data tạm thời để test UI
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      EnterpriseAssignment(
        assignmentId: 1,
        requestId: 101,
        assignedCollector: 1,
        assignedBy: 1,
        reportId: 1,
        citizenId: 1,
        collectorName: 'Trần Văn Minh',
        status: 'Pending',
        assignedAt: DateTime.now().subtract(const Duration(hours: 1)),
        reportDescription: 'Rác tích tụ tại khu vực Q.1',
        wasteTypeName: 'Household',
        citizenName: 'Nguyễn Văn A',
      ),
      EnterpriseAssignment(
        assignmentId: 2,
        requestId: 102,
        assignedCollector: 2,
        assignedBy: 1,
        reportId: 2,
        citizenId: 2,
        collectorName: 'Nguyễn Thị Hương',
        status: 'InProgress',
        assignedAt: DateTime.now().subtract(const Duration(hours: 3)),
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        reportDescription: 'Rác tái chế tại khu vực Q.3',
        wasteTypeName: 'Recyclable',
        citizenName: 'Trần Thị B',
      ),
      EnterpriseAssignment(
        assignmentId: 3,
        requestId: 103,
        assignedCollector: 1,
        assignedBy: 1,
        reportId: 3,
        citizenId: 3,
        collectorName: 'Trần Văn Minh',
        status: 'Completed',
        assignedAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: DateTime.now().subtract(const Duration(hours: 20)),
        reportDescription: 'Rác nguy hại tại Q.Bình Thạnh',
        wasteTypeName: 'Hazardous',
        citizenName: 'Lê Văn C',
      ),
      EnterpriseAssignment(
        assignmentId: 4,
        requestId: 104,
        assignedCollector: 3,
        assignedBy: 1,
        reportId: 4,
        citizenId: 4,
        collectorName: 'Lê Đức Anh',
        status: 'Cancelled',
        assignedAt: DateTime.now().subtract(const Duration(days: 2)),
        reportDescription: 'Yêu cầu bị hủy',
        wasteTypeName: 'Household',
        citizenName: 'Phạm Thị D',
      ),
    ];
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
  // Enterprise lấy tất cả waste-reports (chỉ những report thuộc district của enterprise)
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
  // Enterprise không có endpoint riêng cho feedbacks
  // Chỉ có thể lấy feedbacks theo reportId: /api/feedbacks/report/{reportId}
  static Future<List<EnterpriseFeedback>> getFeedbacks() async {
    // Trả về empty list vì BE không có endpoint này cho Enterprise
    // FE cần gọi getFeedbacksByReport(reportId) thay thế
    // Mock data tạm thời để test UI
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      EnterpriseFeedback(
        feedbackId: 1,
        userName: 'Nguyễn Văn A',
        content: 'Xe thu gom đến trễ 30 phút so với lịch hẹn. Cần cải thiện thời gian.',
        reportId: 101,
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      EnterpriseFeedback(
        feedbackId: 2,
        userName: 'Trần Thị B',
        content: 'Nhân viên thu gom rất nhiệt tình và thân thiện.',
        reportId: 102,
        status: 'Resolved',
        resolution: 'Cảm ơn phản hồi tích cực. Đã ghi nhận khen ngợi nhân viên.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      EnterpriseFeedback(
        feedbackId: 3,
        userName: 'Lê Văn C',
        content: 'Khu vực quanh chung cư A vẫn còn rác堆积 nhiều ngày chưa được thu gom.',
        reportId: 103,
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EnterpriseFeedback(
        feedbackId: 4,
        userName: 'Phạm Thị D',
        content: 'Xe thu gom gây ồn ào vào buổi sáng sớm.',
        reportId: 104,
        status: 'Rejected',
        resolution: 'Đã kiểm tra, xe hoạt động đúng giờ quy định.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Lấy feedbacks theo reportId
  static Future<List<EnterpriseFeedback>> getFeedbacksByReport(int reportId) async {
    try {
      final response = await ApiService.get('/feedbacks/report/$reportId');
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
