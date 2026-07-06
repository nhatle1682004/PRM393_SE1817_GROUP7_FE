import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';

class AuthService {
  final StorageService _storage = StorageService();

  Future<AuthUser> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConfig.login,
      body: {'email': email, 'password': password},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final token = (data['token'] ?? data['Token'])?.toString();
    final userData = data['user'] ?? data['User'];

    if (token == null || token.isEmpty || userData is! Map) {
      throw const ApiException('Phản hồi đăng nhập không hợp lệ từ máy chủ.');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userData));
    await _storage.saveToken(token);
    await _storage.saveUserProfile(user);
    return user;
  }

  Future<void> register(
    String fullName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    await ApiService.post(
      ApiConfig.register,
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    await _storage.saveUserProfile(
      AuthUser(userId: 0, fullName: fullName, email: email, roleId: 1),
    );
  }

  Future<int> verifyOtp(String email, String otp) async {
    final response = await ApiService.post(
      ApiConfig.verifyOtp,
      body: {'email': email, 'otp': otp},
    );
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final userId =
        int.tryParse((data['userId'] ?? data['UserId'] ?? 0).toString()) ?? 0;
    final profile = await _storage.getUserProfile();
    if (profile != null) {
      await _storage.saveUserProfile(
        AuthUser(
          userId: userId,
          fullName: profile.fullName,
          email: profile.email,
          roleId: profile.roleId,
          roleName: profile.roleName,
        ),
      );
    }
    return userId;
  }

  Future<void> forgotPassword(String email) async {
    await ApiService.post(ApiConfig.forgotPassword, body: {'email': email});
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    await ApiService.post(
      ApiConfig.resetPassword,
      body: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    await ApiService.put(
      ApiConfig.changePassword,
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> resendOtp() async {
    throw const ApiException(
      'Chức năng gửi lại OTP chưa khả dụng trên backend hiện tại.',
    );
  }

  Future<void> logout() => _storage.clear();
  Future<AuthUser?> getCurrentUser() => _storage.getUserProfile();
  Future<bool> isAuthenticated() async =>
      (await _storage.getToken())?.isNotEmpty == true;
}
