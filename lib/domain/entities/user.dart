import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.superstarId,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? avatarUrl;
  final String? superstarId;

  @override
  List<Object?> get props => [id, email, role, superstarId];
}
