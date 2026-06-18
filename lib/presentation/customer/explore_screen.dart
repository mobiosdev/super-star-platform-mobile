import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/models/superstar_dto.dart';
import '../../data/repositories/superstar_repository_impl.dart';

final _exploreProvider = FutureProvider.autoDispose<List<SuperstarDto>>((ref) async {
  return ref.watch(superstarRepositoryProvider).list(limit: 30);
});

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_exploreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Explore Superstars', showBack: false),
      body: async.when(
        loading: () => const LoadingShimmer(itemCount: 5),
        error: (e, _) => EmptyState(
          title: 'Could not load creators',
          subtitle: e.toString(),
          icon: Icons.error_outline,
          action: () => ref.invalidate(_exploreProvider),
          actionLabel: 'Retry',
        ),
        data: (stars) {
          if (stars.isEmpty) {
            return const EmptyState(
              title: 'No Superstars yet',
              subtitle: 'Register a Superstar account via Postman or the API to see creators here.',
              icon: Icons.star_outline,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_exploreProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final star = stars[i];
                return _SuperstarTile(
                  star: star,
                  onTap: () => context.push('/superstar/${star.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SuperstarTile extends StatelessWidget {
  const _SuperstarTile({required this.star, required this.onTap});
  final SuperstarDto star;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: star.avatarUrl != null
              ? CachedNetworkImageProvider(star.avatarUrl!)
              : null,
          child: star.avatarUrl == null ? const Icon(Icons.star) : null,
        ),
        title: Text(
          star.displayName ?? 'Superstar',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [star.category, if (star.verified) 'Verified'].whereType<String>().join(' · '),
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
