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
  static const String _superstarIdKey = 'superstar_id';
  static const String _themeModeKey = 'theme_mode';

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
  String? getSuperstarId() => box.get(_superstarIdKey) as String?;
  String? getThemeMode() => box.get(_themeModeKey) as String?;

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
    String? superstarId,
  }) async {
    await saveTokens(access: access, refresh: refresh);
    await box.put(_roleKey, role.name);
    await box.put(_userIdKey, userId);
    await box.put(_emailKey, email);
    if (superstarId != null) {
      await box.put(_superstarIdKey, superstarId);
    }
  }

  Future<void> saveSuperstarId(String id) async {
    await box.put(_superstarIdKey, id);
  }

  Future<void> saveThemeMode(String mode) async {
    await box.put(_themeModeKey, mode);
  }

  Future<void> clearSession() async {
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
    await box.delete(_roleKey);
    await box.delete(_userIdKey);
    await box.delete(_emailKey);
    await box.delete(_superstarIdKey);
  }

  bool get isLoggedIn => getAccessToken() != null && getRole() != null;
}
