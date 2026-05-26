import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_cta_button.dart';
import '../../core/widgets/logout_button.dart';
import '../../core/widgets/role_bottom_nav.dart';
import '../../core/widgets/superstar_app_bar.dart';
class CreatorShell extends StatelessWidget {
  const CreatorShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.contains('/creator/library')) index = 1;
    if (location.contains('/creator/analytics')) index = 2;
    if (location.contains('/creator/plans')) index = 3;
    if (location.contains('/creator/profile')) index = 4;

    final showNav = !location.contains('/creator/upload') && !location.contains('/creator/live');

    return Scaffold(
      body: child,
      bottomNavigationBar: showNav
          ? RoleBottomNav(
              currentIndex: index,
              onTap: (i) {
                const routes = [
                  '/creator',
                  '/creator/library',
                  '/creator/analytics',
                  '/creator/plans',
                  '/creator/profile',
                ];
                context.go(routes[i]);
              },
              items: const [
                BottomNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Studio'),
                BottomNavItem(icon: Icons.video_library_outlined, selectedIcon: Icons.video_library, label: 'Library'),
                BottomNavItem(icon: Icons.insights_outlined, selectedIcon: Icons.insights, label: 'Analytics'),
                BottomNavItem(icon: Icons.payments_outlined, selectedIcon: Icons.payments, label: 'Plans'),
                BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Account'),
              ],
            )
          : null,
    );
  }
}

class CreatorStudioScreen extends StatelessWidget {
  const CreatorStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SuperstarAppBar(
        title: 'Creator Studio',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Account',
            icon: const Icon(Icons.person_outline, color: AppColors.secondary),
            onPressed: () => context.go('/creator/profile'),
          ),
          const LogoutIconButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MetricCard(title: 'Subscribers', value: '12.4K', icon: Icons.people_outline),
          _MetricCard(title: 'Revenue (30d)', value: '\$8,420', icon: Icons.attach_money),
          const SizedBox(height: 16),
          GradientCtaButton(
            label: 'Upload Content',
            icon: Icons.cloud_upload_outlined,
            onPressed: () => context.push('/creator/upload'),
          ),
          const SizedBox(height: 12),
          PulsingLiveButton(onPressed: () => context.push('/creator/live')),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF38BDF8)),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}
