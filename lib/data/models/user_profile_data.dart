class UserProfileData {
  final int userId;
  final String fullName;
  final String email;
  final int roleId;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;

  // New fields for profile page
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? country;
  final String? city;
  final String? address;

  const UserProfileData({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleId,
    this.phone,
    this.avatarUrl,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.bio,
    this.country,
    this.city,
    this.address,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roleId: json['roleId'] is int ? json['roleId'] as int : int.tryParse(json['roleId']?.toString() ?? '') ?? 0,
      phone: json['phone']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      // New fields
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      bio: json['bio']?.toString() ?? json['bioGraphy']?.toString() ?? json['introduction']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString() ?? json['province']?.toString() ?? json['district']?.toString(),
      address: json['address']?.toString() ?? json['specificAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'roleId': roleId,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'country': country,
      'city': city,
      'address': address,
    };
  }

  UserProfileData copyWith({
    int? userId,
    String? fullName,
    String? email,
    int? roleId,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    String? firstName,
    String? lastName,
    String? bio,
    String? country,
    String? city,
    String? address,
  }) {
    return UserProfileData(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
    );
  }

  String get roleName {
    switch (roleId) {
      case 1:
        return 'Citizen';
      case 2:
        return 'Collector';
      case 3:
        return 'Enterprise';
      case 4:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  bool get isCitizen => roleId == 1;
  bool get isCollector => roleId == 2;
  bool get isEnterprise => roleId == 3;
  bool get isAdmin => roleId == 4;

  String get initials {
    if (fullName.isEmpty) return 'U';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
  }

  // Full name from first and last name
  String get computedFullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return fullName;
  }
}
