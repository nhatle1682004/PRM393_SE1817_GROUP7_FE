class AdminUser {
  final int userId;
  final String email;
  final String fullName;
  final int roleId;
  final String roleName;
  final bool isActive;
  final DateTime? createdAt;
  final int? totalPoints;
  final bool? isAvailable;

  AdminUser({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.roleId,
    required this.roleName,
    this.isActive = true,
    this.createdAt,
    this.totalPoints,
    this.isAvailable,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: json['userId'] ?? json['user_id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      roleId: json['roleId'] ?? json['role_id'] ?? 0,
      roleName: json['roleName'] ?? json['role_name'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      totalPoints: json['totalPoints'] ?? json['total_points'],
      isAvailable: json['isAvailable'] ?? json['is_available'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'fullName': fullName,
        'roleId': roleId,
        'roleName': roleName,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'totalPoints': totalPoints,
        'isAvailable': isAvailable,
      };
}

class CreateUserRequest {
  final String email;
  final String fullName;
  final String password;
  final int roleId;

  CreateUserRequest({
    required this.email,
    required this.fullName,
    required this.password,
    required this.roleId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'password': password,
        'roleId': roleId,
      };
}

class UpdateUserRequest {
  final String? email;
  final String? fullName;
  final int? roleId;

  UpdateUserRequest({this.email, this.fullName, this.roleId});

  Map<String, dynamic> toJson() => {
        if (email != null) 'email': email,
        if (fullName != null) 'fullName': fullName,
        if (roleId != null) 'roleId': roleId,
      };
}
