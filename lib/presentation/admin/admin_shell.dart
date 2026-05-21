import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/role_bottom_nav.dart';
import 'moderation_queue_screen.dart';
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.contains('/admin/reports') ? 1 : 0;
    final showNav = !location.contains('/admin/review');

    return Scaffold(
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
