import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_role.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage.instance;
});

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  static const String _boxName = 'superstar_prefs';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';

  Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Box<dynamic> get box {
    if (_box == null) throw StateError('LocalStorage not initialized');
    return _box!;
  }

  String? getAccessToken() => box.get(_accessTokenKey) as String?;
  String? getRefreshToken() => box.get(_refreshTokenKey) as String?;
  UserRole? getRole() {
    final value = box.get(_roleKey) as String?;
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.customer,
    );
  }

  String? getUserId() => box.get(_userIdKey) as String?;
  String? getEmail() => box.get(_emailKey) as String?;

  Future<void> saveTokens({required String access, required String refresh}) async {
    await box.put(_accessTokenKey, access);
    await box.put(_refreshTokenKey, refresh);
  }

  Future<void> saveSession({
    required String access,
    required String refresh,
    required UserRole role,
    required String userId,
    required String email,
  }) async {
    await saveTokens(access: access, refresh: refresh);
    await box.put(_roleKey, role.name);
    await box.put(_userIdKey, userId);
    await box.put(_emailKey, email);
  }

  Future<void> clearSession() async {
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
    await box.delete(_roleKey);
    await box.delete(_userIdKey);
    await box.delete(_emailKey);
  }

  bool get isLoggedIn => getAccessToken() != null && getRole() != null;
}
