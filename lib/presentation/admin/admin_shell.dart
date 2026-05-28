import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/role_bottom_nav.dart';
import 'moderation_queue_screen.dart';
import '../providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.contains('/admin/reports') ? 1 : 0;
    final showNav = !location.contains('/admin/review');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: showNav
          ? RoleBottomNav(
              currentIndex: index,
              onTap: (i) => context.go(i == 0 ? '/admin' : '/admin/reports'),
              items: const [
                BottomNavItem(
                  icon: Icons.fact_check_outlined,
                  selectedIcon: Icons.fact_check,
                  label: 'Queue',
                ),
                BottomNavItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: 'Reports',
                ),
              ],
            )
          : null,
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) => const ModerationQueueScreen();
}
