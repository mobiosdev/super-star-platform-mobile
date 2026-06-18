import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/role_bottom_nav.dart';
import '../shared/placeholder_screen.dart';
import '../providers/auth_provider.dart';

class SuperadminShell extends ConsumerWidget {
  const SuperadminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.contains('/superadmin/superstars')) index = 1;
    if (location.contains('/superadmin/analytics')) index = 2;
    if (location.contains('/superadmin/settings')) index = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
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
      extendBody: true,
      bottomNavigationBar: RoleBottomNav(
        currentIndex: index,
        onTap: (i) {
          const routes = [
            '/superadmin',
            '/superadmin/superstars',
            '/superadmin/analytics',
            '/superadmin/settings',
          ];
          context.go(routes[i]);
        },
        items: const [
          BottomNavItem(icon: Icons.admin_panel_settings_outlined, selectedIcon: Icons.admin_panel_settings, label: 'Admins'),
          BottomNavItem(icon: Icons.star_outline, selectedIcon: Icons.star, label: 'Stars'),
          BottomNavItem(icon: Icons.show_chart_outlined, selectedIcon: Icons.show_chart, label: 'Analytics'),
          BottomNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
        ],
      ),
    );
  }
}

class SuperadminDashboardScreen extends StatelessWidget {
  const SuperadminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Platform Dashboard',
      subtitle: 'Admin management, appeals, and global controls',
      icon: Icons.hub_outlined,
      showBack: false,
    );
  }
}
