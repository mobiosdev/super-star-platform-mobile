import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_role.dart';
import '../../presentation/providers/auth_provider.dart';

String? authRedirect(BuildContext context, GoRouterState state, Ref ref) {
  final auth = ref.read(authStateProvider);
  final isLoggingIn = state.matchedLocation == '/login';
  final user = auth.valueOrNull;

  if (auth.isLoading) {
    return state.matchedLocation == '/loading' ? null : '/loading';
  }

  if (user == null) {
    return isLoggingIn ? null : '/login';
  }

  final onAuthGate = isLoggingIn || state.matchedLocation == '/loading';
  if (onAuthGate) {
    return user.role.homeRoute;
  }

  final role = user.role;
  final path = state.matchedLocation;

  if (path.startsWith('/customer') && role != UserRole.customer) {
    return role.homeRoute;
  }
  if (path.startsWith('/creator') && role != UserRole.superstar) {
    return role.homeRoute;
  }
  if (path.startsWith('/admin') && role != UserRole.admin) {
    return role.homeRoute;
  }
  if (path.startsWith('/superadmin') && role != UserRole.superadmin) {
    return role.homeRoute;
  }

  return null;
}
