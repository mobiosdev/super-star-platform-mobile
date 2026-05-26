import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/local_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/platform_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(localStorageProvider),
    ref.watch(platformApiProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage, this._api);

  final LocalStorage _storage;
  final PlatformApi _api;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    if (ApiConstants.useMockApi) {
      return _mockLogin(email: email, password: password);
    }

    final tokens = await _api.login(email: email, password: password);
    await _storage.saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken);

    final user = tokens.user != null
        ? tokens.user!.toEntity()
        : (await _api.getCurrentUser()).toEntity();

    return _persistUser(user, tokens.accessToken, tokens.refreshToken);
  }

  @override
  Future<AppUser> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    if (ApiConstants.useMockApi) {
      return _mockLogin(email: email, password: password);
    }

    final tokens = await _api.register(
      email: email,
      password: password,
      fullName: name,
      role: 'CUSTOMER',
    );
    await _storage.saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken);

    final user = tokens.user != null
        ? tokens.user!.toEntity()
        : (await _api.getCurrentUser()).toEntity();

    return _persistUser(user, tokens.accessToken, tokens.refreshToken);
  }

  @override
  Future<void> logout() async {
    if (!ApiConstants.useMockApi) {
      final refresh = _storage.getRefreshToken();
      if (refresh != null) {
        try {
          await _api.logout(refreshToken: refresh);
        } on ApiException {
          // Clear local session even if server logout fails.
        }
      }
    }
    await _storage.clearSession();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (!_storage.isLoggedIn) return null;

    if (ApiConstants.useMockApi) {
      return AppUser(
        id: _storage.getUserId() ?? '',
        email: _storage.getEmail() ?? '',
        displayName: (_storage.getEmail() ?? 'User').split('@').first,
        role: _storage.getRole() ?? UserRole.customer,
      );
    }

    try {
      final dto = await _api.getCurrentUser();
      final user = dto.toEntity();
      await _persistUser(
        user,
        _storage.getAccessToken()!,
        _storage.getRefreshToken() ?? '',
      );
      return user;
    } on ApiException {
      await _storage.clearSession();
      return null;
    }
  }

  @override
  Future<AppUser> loginWithRoleDemo(UserRole role) async {
    if (!ApiConstants.useMockApi) {
      throw ApiException(
        message: 'Demo login requires USE_MOCK_API=true. Use real credentials instead.',
      );
    }
    final email = '${role.name}@superstar.app';
    return _mockLogin(email: email, password: 'demo');
  }

  Future<AppUser> _mockLogin({required String email, required String password}) async {
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

  Future<AppUser> _persistUser(AppUser user, String access, String refresh) async {
    String? superstarId = user.superstarId;
    if (user.role == UserRole.superstar && (superstarId == null || superstarId.isEmpty)) {
      superstarId = await _api.resolveSuperstarId(userId: user.id, knownSuperstarId: null);
    }
    await _storage.saveSession(
      access: access,
      refresh: refresh,
      role: user.role,
      userId: user.id,
      email: user.email,
      superstarId: superstarId,
    );
    return AppUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
      avatarUrl: user.avatarUrl,
      superstarId: superstarId,
    );
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
