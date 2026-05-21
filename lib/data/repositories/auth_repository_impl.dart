import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(localStorageProvider));
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage);
  final LocalStorage _storage;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final role = _roleFromEmail(email);
    final user = AppUser(
      id: 'user_${role.name}',
      email: email,
      displayName: email.split('@').first,
      role: role,
    );
    await _storage.saveSession(
      access: 'demo_access_${role.name}',
      refresh: 'demo_refresh_${role.name}',
      role: role,
      userId: user.id,
      email: email,
    );
    return user;
  }

  @override
  Future<AppUser> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    return login(email: email, password: password);
  }

  @override
  Future<void> logout() => _storage.clearSession();

  @override
  Future<AppUser?> getCurrentUser() async {
    if (!_storage.isLoggedIn) return null;
    return AppUser(
      id: _storage.getUserId() ?? '',
      email: _storage.getEmail() ?? '',
      displayName: (_storage.getEmail() ?? 'User').split('@').first,
      role: _storage.getRole() ?? UserRole.customer,
    );
  }

  @override
  Future<AppUser> loginWithRoleDemo(UserRole role) async {
    final email = '${role.name}@superstar.app';
    return login(email: email, password: 'demo');
  }

  UserRole _roleFromEmail(String email) {
    final lower = email.toLowerCase();
    if (lower.contains('superadmin')) return UserRole.superadmin;
    if (lower.contains('admin')) return UserRole.admin;
    if (lower.contains('superstar') || lower.contains('creator')) {
      return UserRole.superstar;
    }
    return UserRole.customer;
  }
}
