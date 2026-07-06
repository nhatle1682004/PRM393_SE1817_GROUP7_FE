import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/data/models/user_profile_data.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class UserService {
  Future<List<AuthUser>> getUsers() async {
    final response = await ApiService.get(ApiConfig.users);
    return _list(response.data).map(AuthUser.fromJson).toList();
  }

  Future<AuthUser> getUserById(int id) async {
    final response = await ApiService.get(ApiConfig.user(id));
    return AuthUser.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<AuthUser>> getCollectors() async {
    final response = await ApiService.get(ApiConfig.listCollectors);
    return _list(response.data).map(AuthUser.fromJson).toList();
  }

  Future<UserProfileData> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);
    return UserProfileData.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<UserProfileData> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await ApiService.put(ApiConfig.profile, body: profileData);
    return UserProfileData.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AuthUser> updateMyAvailability(bool isAvailable) async {
    final response = await ApiService.put(
      ApiConfig.userAvailability,
      body: {'isAvailable': isAvailable},
    );
    return AuthUser.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deactivateUser(int id) async =>
      ApiService.put(ApiConfig.userDeactivate(id));
  Future<void> activateUser(int id) async =>
      ApiService.put(ApiConfig.userActivate(id));

  List<Map<String, dynamic>> _list(dynamic data) {
    if (data is List)
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    return const [];
  }
}
