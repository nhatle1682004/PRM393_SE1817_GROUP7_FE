import 'auth_user.dart';
import 'json_helpers.dart';

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
      userId: JsonHelpers.intValue(json, ['userId', 'UserId', 'id', 'Id']),
      fullName: JsonHelpers.stringValue(json, [
        'fullName',
        'FullName',
        'name',
        'Name',
      ]),
      email: JsonHelpers.stringValue(json, ['email', 'Email']),
      roleId: JsonHelpers.intValue(json, ['roleId', 'RoleId']),
      phone: JsonHelpers.pick(json, ['phone', 'Phone'])?.toString(),
      avatarUrl: JsonHelpers.pick(json, [
        'avatarUrl',
        'AvatarUrl',
        'avatar',
        'Avatar',
      ])?.toString(),
      createdAt: JsonHelpers.dateValue(json, ['createdAt', 'CreatedAt']),
      // New fields
      firstName: JsonHelpers.pick(json, ['firstName', 'FirstName'])?.toString(),
      lastName: JsonHelpers.pick(json, ['lastName', 'LastName'])?.toString(),
      bio: JsonHelpers.pick(json, [
        'bio',
        'Bio',
        'bioGraphy',
        'BioGraphy',
        'introduction',
        'Introduction',
      ])?.toString(),
      country: JsonHelpers.pick(json, ['country', 'Country'])?.toString(),
      city: JsonHelpers.pick(json, [
        'city',
        'City',
        'province',
        'Province',
        'district',
        'District',
      ])?.toString(),
      address: JsonHelpers.pick(json, [
        'address',
        'Address',
        'specificAddress',
        'SpecificAddress',
      ])?.toString(),
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
        return 'Enterprise';
      case 3:
        return 'Collector';
      case 4:
        return 'Admin';
      default:
        return AuthUser.roleNameFromId(roleId);
    }
  }

  String get initials {
    if (fullName.isEmpty) return 'U';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts[parts.length - 1][0]}'
          .toUpperCase();
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
