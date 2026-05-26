import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.superstarId,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final String? superstarId;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final superstar = json['superstar'];
    String? ssId = json['superstar_id'] as String?;
    if (ssId == null && superstar is Map) {
      ssId = superstar['id']?.toString();
    }
    return UserDto(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['display_name'] ?? json['name'] ?? '').toString(),
      role: (json['role'] ?? 'CUSTOMER').toString().toUpperCase(),
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      superstarId: ssId,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      displayName: fullName.isNotEmpty ? fullName : email.split('@').first,
      role: _parseRole(role),
      avatarUrl: avatarUrl,
      superstarId: superstarId,
    );
  }

  static UserRole _parseRole(String apiRole) {
    switch (apiRole.toUpperCase()) {
      case 'SUPERADMIN':
      case 'SUPER_ADMIN':
        return UserRole.superadmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'SUPERSTAR':
      case 'CREATOR':
        return UserRole.superstar;
      default:
        return UserRole.customer;
    }
  }
}

class AuthTokensDto {
  const AuthTokensDto({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserDto? user;

  factory AuthTokensDto.fromJson(Map<String, dynamic> json) {
    return AuthTokensDto(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      user: json['user'] is Map ? UserDto.fromJson(Map<String, dynamic>.from(json['user'] as Map)) : null,
    );
  }
}
