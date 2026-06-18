import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/gradient_cta_button.dart';
import '../../core/widgets/logout_button.dart';
import '../../core/widgets/role_bottom_nav.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/api/platform_api.dart';
import '../../data/models/creator_studio_dto.dart';
import '../../data/repositories/creator_studio_repository_impl.dart';
import '../../data/repositories/superstar_repository_impl.dart';
import '../../presentation/providers/auth_provider.dart';

final _creatorStudioProvider = FutureProvider.autoDispose<CreatorStudioLoadResult>((ref) async {
  final repo = ref.read(creatorStudioRepositoryProvider);
  try {
    final dashboard = await repo.getDashboard(periodDays: 30);
    return CreatorStudioLoadResult(dashboard: dashboard);
  } on ApiException catch (e) {
    CreatorStudioDashboardDto? fallback;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      try {
        final superstarId = await ref.read(superstarRepositoryProvider).resolveMySuperstarId(
              userId: user.id,
              superstarId: user.superstarId,
            );
        if (superstarId != null) {
          final analytics = await ref.read(platformApiProvider).getSuperstarAnalytics(superstarId);
          fallback = CreatorStudioDashboardDto.fromAnalyticsFallback(analytics, periodDays: 30);
        }
      } catch (_) {}
    }

    final warning = e.statusCode == 500
        ? 'The server failed to load your studio dashboard (HTTP 500). '
            'Upload and Go Live still work; the backend needs to fix GET /creator-studio/dashboard.'
        : e.message;

    return CreatorStudioLoadResult(
      dashboard: fallback ?? CreatorStudioDashboardDto.fallbackEmpty(periodDays: 30),
      warning: fallback != null
          ? '$warning Showing analytics summary instead.'
          : warning,
      isPartial: true,
    );
  }
});

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
      extendBody: true,
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

class CreatorStudioScreen extends ConsumerWidget {
  const CreatorStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studio = ref.watch(_creatorStudioProvider);

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
      body: studio.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => _StudioBody(
          data: CreatorStudioDashboardDto.fallbackEmpty(),
          warning: e is ApiException ? e.message : '$e',
          onRefresh: () => ref.invalidate(_creatorStudioProvider),
        ),
        data: (result) => _StudioBody(
          data: result.dashboard,
          warning: result.warning,
          onRefresh: () => ref.invalidate(_creatorStudioProvider),
        ),
      ),
    );
  }
}

class _StudioBody extends StatelessWidget {
  const _StudioBody({
    required this.data,
    required this.onRefresh,
    this.warning,
  });

  final CreatorStudioDashboardDto data;
  final String? warning;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (warning != null) ...[
            _StudioWarningBanner(message: warning!),
            const SizedBox(height: 12),
          ],
          if (data.live != null && data.live!.isLive) ...[
            _LiveNowBanner(
              title: data.live!.title ?? 'You are live',
              onTap: () => context.push('/creator/live'),
            ),
            const SizedBox(height: 12),
          ],
          _MetricCard(
            title: 'Subscribers',
            value: data.subscribers.display,
            icon: Icons.people_outline,
          ),
          _MetricCard(
            title: 'Revenue (${data.revenue.periodDays}d)',
            value: data.revenue.display,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),
          GradientCtaButton(
            label: 'Upload Content',
            icon: Icons.cloud_upload_outlined,
            onPressed: () => context.push('/creator/upload'),
          ),
          const SizedBox(height: 12),
          PulsingLiveButton(
            onPressed: () => context.push('/creator/live'),
          ),
        ],
      ),
    );
  }
}

class _StudioWarningBanner extends StatelessWidget {
  const _StudioWarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.warning, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveNowBanner extends StatelessWidget {
  const _LiveNowBanner({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'Manage',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
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
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
