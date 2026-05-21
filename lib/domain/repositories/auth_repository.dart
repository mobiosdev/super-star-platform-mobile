import '../entities/user.dart';
import '../entities/user_role.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> signup({required String email, required String password, required String name});
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<AppUser> loginWithRoleDemo(UserRole role);
}
