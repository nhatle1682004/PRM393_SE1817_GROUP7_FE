import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/dashboard_stats.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class DashboardService {
  Future<DashboardStats> getAdminDashboard({int? year}) async {
    final response = await ApiService.get(
      ApiConfig.dashboardAdmin,
      queryParameters: year == null ? null : {'year': year},
    );
    return DashboardStats.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
