import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfile {
  final int userId;
  final String fullName;
  final String email;
  final int roleId;
  final String roleName;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleId,
    required this.roleName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roleId = json['roleId'] is int ? json['roleId'] as int : int.tryParse(json['roleId']?.toString() ?? '') ?? 0;
    return UserProfile(
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roleId: roleId,
      roleName: json['roleName']?.toString() ?? _getRoleName(roleId),
    );
  }

  static String _getRoleName(int roleId) {
    switch (roleId) {
      case 1: return 'Citizen';
      case 2: return 'Collector';
      case 3: return 'Enterprise';
      case 4: return 'Admin';
      default: return 'Unknown';
    }
  }

  Map<String, String> toStorageMap() {
    return {
      'userId': userId.toString(),
      'fullName': fullName,
      'email': email,
      'roleId': roleId.toString(),
      'roleName': roleName,
    };
  }
}

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _userProfilePrefix = 'user_';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final data = profile.toStorageMap();
    for (final entry in data.entries) {
      await _storage.write(key: '$_userProfilePrefix${entry.key}', value: entry.value);
    }
  }

  Future<UserProfile?> getUserProfile() async {
    final userId = await _storage.read(key: '${_userProfilePrefix}userId');
    if (userId == null) return null;

    final fullName = await _storage.read(key: '${_userProfilePrefix}fullName') ?? '';
    final email = await _storage.read(key: '${_userProfilePrefix}email') ?? '';
    final roleId = await _storage.read(key: '${_userProfilePrefix}roleId') ?? '0';
    final roleName = await _storage.read(key: '${_userProfilePrefix}roleName') ?? UserProfile._getRoleName(int.tryParse(roleId) ?? 0);

    return UserProfile(
      userId: int.tryParse(userId) ?? 0,
      fullName: fullName,
      email: email,
      roleId: int.tryParse(roleId) ?? 0,
      roleName: roleName,
    );
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> deleteUserProfile() async {
    await _storage.delete(key: '${_userProfilePrefix}userId');
    await _storage.delete(key: '${_userProfilePrefix}fullName');
    await _storage.delete(key: '${_userProfilePrefix}email');
    await _storage.delete(key: '${_userProfilePrefix}roleId');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
