import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/role_bottom_nav.dart';
import 'home_feed_screen.dart';
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, required this.child});

  final Widget child;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/customer/explore')) return 1;
    if (location.startsWith('/customer/subscriptions')) return 2;
    if (location.startsWith('/customer/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final showNav = !location.contains('/player') &&
        !location.contains('/messages') &&
        !location.contains('/notifications');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.child,
      bottomNavigationBar: showNav
          ? RoleBottomNav(
              currentIndex: index,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go('/customer');
                  case 1:
                    context.go('/customer/explore');
                  case 2:
                    context.go('/customer/subscriptions');
                  case 3:
                    context.go('/customer/profile');
                }
              },
              items: const [
                BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Feed'),
                BottomNavItem(icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Explore'),
                BottomNavItem(
                  icon: Icons.card_membership_outlined,
                  selectedIcon: Icons.card_membership,
                  label: 'Subs',
                ),
                BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
              ],
            )
          : null,
    );
  }
}

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});
  @override
  Widget build(BuildContext context) => const HomeFeedScreen();
}
