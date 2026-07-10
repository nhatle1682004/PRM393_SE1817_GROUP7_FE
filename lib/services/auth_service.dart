import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';
import 'package:waste_collection_management_system/data/constants/app_roles.dart';

class AuthService {
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConfig.login,
      body: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;

    final token = data['token']?.toString();
    if (token == null) {
      throw Exception('Phản hồi đăng nhập không hợp lệ từ máy chủ.');
    }

    await _storage.saveToken(token);

    // Fetch full profile to get roleId (login response doesn't include roleId)
    final profileResponse = await ApiService.get(ApiConfig.profile);
    final profileData = profileResponse.data as Map<String, dynamic>;
    await _storage.saveUserProfile(UserProfile.fromJson(profileData));

    return data;
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
      UserProfile(
        userId: 0,
        fullName: fullName,
        email: email,
        roleId: AppRoles.citizen, // Default role for new registration
        roleName: AppRoles.getRoleName(AppRoles.citizen),
      ),
    );
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

  Future<int> verifyOtp(String email, String otp) async {
    final response = await ApiService.post(
      ApiConfig.verifyOtp,
      body: {'email': email, 'otp': otp},
    );

    final data = response.data as Map<String, dynamic>;
    final userId = data['userId'];
    if (userId == null) {
      throw Exception('Phản hồi xác thực không hợp lệ từ máy chủ.');
    }

    final profile = await _storage.getUserProfile();
    if (profile != null) {
      await _storage.saveUserProfile(
        UserProfile(
          userId: userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
          fullName: profile.fullName,
          email: profile.email,
          roleId: profile.roleId,
          roleName: profile.roleName,
        ),
      );
    }

    return userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
  }

  Future<void> logout() async {
    await _storage.clear();
  }

  static Future<UserProfile?> getProfile() async {
    return await StorageService().getUserProfile();
  }

  // TODO: cập nhật khi BE có endpoint resend OTP riêng
  Future<void> resendOtp() async {
    final profile = await _storage.getUserProfile();
    if (profile == null) {
      throw Exception(
        'Không tìm thấy thông tin đăng ký. Vui lòng đăng ký lại.',
      );
    }

    await ApiService.post(ApiConfig.resendOtp, body: {'email': profile.email});
  }
}
