import 'json_helpers.dart';

class AuthUser {
  final int userId;
  final String fullName;
  final String email;
  final int roleId;
  final String roleName;
  final String status;
  final DateTime? createdAt;
  final bool isAvailable;

  const AuthUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleId,
    this.roleName = '',
    this.status = '',
    this.createdAt,
    this.isAvailable = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final roleId = JsonHelpers.intValue(json, ['roleId', 'RoleId']);
    return AuthUser(
      userId: JsonHelpers.intValue(json, ['userId', 'UserId', 'id', 'Id']),
      fullName: JsonHelpers.stringValue(json, [
        'fullName',
        'FullName',
        'name',
        'Name',
      ]),
      email: JsonHelpers.stringValue(json, ['email', 'Email']),
      roleId: roleId,
      roleName: JsonHelpers.stringValue(json, [
        'roleName',
        'RoleName',
      ], fallback: roleNameFromId(roleId)),
      status: JsonHelpers.stringValue(json, ['status', 'Status']),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
      isAvailable: JsonHelpers.boolValue(json, ['isAvailable', 'IsAvailable']),
    );
  }

  static String roleNameFromId(int roleId) {
    switch (roleId) {
      case 1:
        return 'Citizen';
      case 2:
        return 'Enterprise';
      case 3:
        return 'Collector';
      case 4:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  Map<String, String> toStorageMap() {
    return {
      'userId': userId.toString(),
      'fullName': fullName,
      'email': email,
      'roleId': roleId.toString(),
      'roleName': roleName.isNotEmpty ? roleName : roleNameFromId(roleId),
      'status': status,
    };
  }
}
