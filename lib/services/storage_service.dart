import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';

typedef UserProfile = AuthUser;

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userProfilePrefix = 'user_';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserProfile(AuthUser profile) async {
    final data = profile.toStorageMap();
    for (final entry in data.entries) {
      await _storage.write(
        key: '$_userProfilePrefix${entry.key}',
        value: entry.value,
      );
    }
  }

  Future<AuthUser?> getUserProfile() async {
    final userId = await _storage.read(key: '${_userProfilePrefix}userId');
    if (userId == null) return null;

    final fullName =
        await _storage.read(key: '${_userProfilePrefix}fullName') ?? '';
    final email = await _storage.read(key: '${_userProfilePrefix}email') ?? '';
    final roleId =
        await _storage.read(key: '${_userProfilePrefix}roleId') ?? '0';
    final roleName =
        await _storage.read(key: '${_userProfilePrefix}roleName') ?? '';
    final status =
        await _storage.read(key: '${_userProfilePrefix}status') ?? '';

    return AuthUser(
      userId: int.tryParse(userId) ?? 0,
      fullName: fullName,
      email: email,
      roleId: int.tryParse(roleId) ?? 0,
      roleName: roleName,
      status: status,
    );
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<void> deleteUserProfile() async {
    await _storage.delete(key: '${_userProfilePrefix}userId');
    await _storage.delete(key: '${_userProfilePrefix}fullName');
    await _storage.delete(key: '${_userProfilePrefix}email');
    await _storage.delete(key: '${_userProfilePrefix}roleId');
    await _storage.delete(key: '${_userProfilePrefix}roleName');
    await _storage.delete(key: '${_userProfilePrefix}status');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
