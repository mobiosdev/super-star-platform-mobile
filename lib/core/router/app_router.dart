import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/admin/admin_shell.dart';
import '../../presentation/admin/content_review_screen.dart';
import '../../presentation/auth/auth_loading_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/creator/creator_profile_screen.dart';
import '../../presentation/creator/creator_shell.dart';
import '../../presentation/superadmin/superadmin_superstars_screen.dart';
import '../../presentation/customer/content_detail_screen.dart';
import '../../presentation/customer/customer_shell.dart';
import '../../presentation/customer/explore_screen.dart';
import '../../presentation/customer/messages_screen.dart';
import '../../presentation/customer/subscriptions_screen.dart';
import '../../presentation/customer/superstar_profile_screen.dart';
import '../../presentation/creator/creator_analytics_screen.dart';
import '../../presentation/creator/creator_library_screen.dart';
import '../../presentation/creator/creator_go_live_screen.dart';
import '../../presentation/creator/creator_upload_screen.dart';
import '../../presentation/customer/notifications_screen.dart';
import '../../presentation/shared/account_profile_screen.dart';
import '../../presentation/shared/placeholder_screen.dart';
import '../../presentation/superadmin/superadmin_shell.dart';
import '../../presentation/customer/fullscreen_live_player_screen.dart';
import 'route_guards.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) => authRedirect(context, state, ref),
    routes: [
      GoRoute(path: '/loading', builder: (_, __) => const AuthLoadingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/content/:id',
        builder: (_, state) => ContentDetailScreen(contentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/superstar/:id',
        builder: (_, state) => SuperstarProfileScreen(superstarId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/live-stream',
        builder: (_, __) => const FullscreenLivePlayerScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/customer', builder: (_, __) => const CustomerHomePage()),
          GoRoute(path: '/customer/explore', builder: (_, __) => const ExploreScreen()),
          GoRoute(path: '/customer/subscriptions', builder: (_, __) => const SubscriptionsScreen()),
          GoRoute(
            path: '/customer/profile',
            builder: (_, __) => const AccountProfileScreen(showBack: false),
          ),
          GoRoute(
            path: '/customer/messages',
            builder: (_, __) => const MessagesScreen(),
          ),
          GoRoute(
            path: '/customer/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => CreatorShell(child: child),
        routes: [
          GoRoute(path: '/creator', builder: (_, __) => const CreatorStudioScreen()),
          GoRoute(path: '/creator/library', builder: (_, __) => const CreatorLibraryScreen()),
          GoRoute(path: '/creator/analytics', builder: (_, __) => const CreatorAnalyticsScreen()),
          GoRoute(
            path: '/creator/plans',
            builder: (_, __) => const PlaceholderScreen(
              title: 'Subscription Plans',
              showBack: false,
              icon: Icons.price_change_outlined,
            ),
          ),
          GoRoute(
            path: '/creator/profile',
            builder: (_, __) => const CreatorProfileScreen(),
          ),
          GoRoute(path: '/creator/upload', builder: (_, __) => const CreatorUploadScreen()),
          GoRoute(path: '/creator/live', builder: (_, __) => const CreatorGoLiveScreen()),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (_, __) => const AdminHomePage()),
          GoRoute(
            path: '/admin/reports',
            builder: (_, __) => const PlaceholderScreen(
              title: 'Moderation Reports',
              showBack: false,
            ),
          ),
          GoRoute(
            path: '/admin/review/:id',
            builder: (_, state) => ContentReviewScreen(itemId: state.pathParameters['id']!),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => SuperadminShell(child: child),
        routes: [
          GoRoute(path: '/superadmin', builder: (_, __) => const SuperadminDashboardScreen()),
          GoRoute(
            path: '/superadmin/superstars',
            builder: (_, __) => const SuperadminSuperstarsScreen(),
          ),
          GoRoute(
            path: '/superadmin/analytics',
            builder: (_, __) => const PlaceholderScreen(
              title: 'Global Analytics',
              showBack: false,
            ),
          ),
          GoRoute(
            path: '/superadmin/settings',
            builder: (_, __) => const PlaceholderScreen(
              title: 'Platform Settings',
              showBack: false,
            ),
          ),
          GoRoute(
            path: '/superadmin/appeals',
            builder: (_, __) => const PlaceholderScreen(title: 'Appeal Queue'),
          ),
        ],
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
