import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/admin_stats.dart';
import 'package:waste_collection_management_system/data/models/admin_user.dart';
import 'package:waste_collection_management_system/data/models/admin_waste_report.dart';
import 'package:waste_collection_management_system/data/models/admin_feedback.dart';
import 'package:waste_collection_management_system/data/models/admin_collection_request.dart';
import 'package:waste_collection_management_system/data/models/admin_notification.dart';
import 'package:waste_collection_management_system/data/models/admin_reward.dart';

class AdminApiService {
  static Future<AdminStats> getAdminDashboard({int? year}) async {
    try {
      final response = await ApiService.get(
        ApiConfig.dashboardAdmin,
        queryParameters: year != null ? {'year': year} : null,
      );
      
      if (response.data != null) {
        return AdminStats.fromJson(response.data);
      }
      return AdminStats();
    } catch (e) {
      rethrow;
    }
  }

  // ============ USER MANAGEMENT ============
  static Future<List<AdminUser>> getAllUsers() async {
    try {
      final response = await ApiService.get(ApiConfig.users);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminUser.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminUser> getUserById(int userId) async {
    try {
      final response = await ApiService.get(ApiConfig.user(userId));
      return AdminUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminUser> createUser(CreateUserRequest request) async {
    try {
      final response = await ApiService.post(
        ApiConfig.users,
        body: request.toJson(),
      );
      return AdminUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminUser> updateUser(int userId, UpdateUserRequest request) async {
    try {
      final response = await ApiService.put(
        ApiConfig.user(userId),
        body: request.toJson(),
      );
      return AdminUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteUser(int userId) async {
    try {
      await ApiService.delete(ApiConfig.user(userId));
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminUser> deactivateUser(int userId) async {
    try {
      final response = await ApiService.put(ApiConfig.userDeactivate(userId));
      return AdminUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminUser> activateUser(int userId) async {
    try {
      final response = await ApiService.put(ApiConfig.userActivate(userId));
      return AdminUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ WASTE REPORTS ============
  static Future<List<AdminWasteReport>> getAllWasteReports() async {
    try {
      final response = await ApiService.get(ApiConfig.wasteReports);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminWasteReport.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminWasteReport> getWasteReportById(int reportId) async {
    try {
      final response = await ApiService.get(ApiConfig.reportDetails(reportId));
      return AdminWasteReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ COLLECTION REQUESTS ============
  static Future<List<AdminCollectionRequest>> getAllCollectionRequests() async {
    try {
      final response = await ApiService.get(ApiConfig.collectionRequestAll);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminCollectionRequest.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminCollectionRequest> getCollectionRequestById(int requestId) async {
    try {
      final response = await ApiService.get(ApiConfig.collectionRequestDetails(requestId));
      return AdminCollectionRequest.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ FEEDBACKS ============
  static Future<List<AdminFeedback>> getAllFeedbacks() async {
    try {
      final response = await ApiService.get(ApiConfig.feedbacks);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminFeedback.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminFeedback> getFeedbackById(int feedbackId) async {
    try {
      final response = await ApiService.get(ApiConfig.feedbackDetails(feedbackId));
      return AdminFeedback.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminFeedback> resolveFeedback(int feedbackId, ResolveFeedbackRequest request) async {
    try {
      final response = await ApiService.put(
        ApiConfig.feedbackResolve(feedbackId),
        body: request.toJson(),
      );
      return AdminFeedback.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminFeedback> rejectFeedback(int feedbackId) async {
    try {
      final response = await ApiService.put(ApiConfig.feedbackReject(feedbackId));
      return AdminFeedback.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ============ NOTIFICATIONS ============
  static Future<List<AdminNotification>> getAllNotifications() async {
    try {
      final response = await ApiService.get(ApiConfig.notifications);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminNotification.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markNotificationRead(int notificationId) async {
    try {
      await ApiService.put(ApiConfig.markNotificationRead(notificationId));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markAllNotificationsRead() async {
    try {
      await ApiService.put(ApiConfig.notificationsReadAll);
    } catch (e) {
      rethrow;
    }
  }

  // ============ REWARDS ============
  static Future<List<AdminReward>> getRewardCatalog() async {
    try {
      final response = await ApiService.get(ApiConfig.rewardsCatalog);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminReward.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<AdminRewardTransaction>> getAllRewardTransactions() async {
    try {
      final response = await ApiService.get(ApiConfig.rewardsHistory);
      final List<dynamic> data = response.data ?? [];
      return data.map((e) => AdminRewardTransaction.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
