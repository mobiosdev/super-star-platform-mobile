import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/models/content_dto.dart';
import '../../data/models/superstar_dto.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/superstar_repository_impl.dart';
final _superstarProvider = FutureProvider.autoDispose.family<SuperstarDto, String>((ref, id) {
  return ref.watch(superstarRepositoryProvider).getById(id);
});

final _superstarFeedProvider =
    FutureProvider.autoDispose.family<List<ContentDto>, String>((ref, superstarId) {
  return ref.watch(contentRepositoryProvider).getFeed(superstarId: superstarId, limit: 20);
});

class SuperstarProfileScreen extends ConsumerWidget {
  const SuperstarProfileScreen({super.key, required this.superstarId});

  final String superstarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(_superstarProvider(superstarId));
    final feed = ref.watch(_superstarFeedProvider(superstarId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Creator'),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Error', subtitle: '$e', icon: Icons.error_outline),
        data: (star) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_superstarProvider(superstarId));
            ref.invalidate(_superstarFeedProvider(superstarId));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(star: star)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Posts',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              feed.when(
                loading: () => const SliverFillRemaining(child: LoadingShimmer(itemCount: 2)),
                error: (e, _) => SliverFillRemaining(
                  child: EmptyState(title: 'Feed unavailable', subtitle: '$e', icon: Icons.wifi_off),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const SliverFillRemaining(
                      child: EmptyState(
                        title: 'No posts yet',
                        subtitle: 'This creator has not published content.',
                        icon: Icons.article_outlined,
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final post = items[i].toFeedPost();
                        final isTablet = MediaQuery.sizeOf(context).width >= 600;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16.0 : 0.0,
                            vertical: isTablet ? 8.0 : 4.0,
                          ),
                          child: ContentCard(
                            post: post,
                            onTap: () => context.push('/content/${post.id}'),
                            onProfileTap: () {},
                            onUpgrade: () {},
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.star});
  final SuperstarDto star;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage:
                star.avatarUrl != null ? CachedNetworkImageProvider(star.avatarUrl!) : null,
            child: star.avatarUrl == null ? const Icon(Icons.star, size: 36) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  star.displayName ?? 'Superstar',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (star.bio != null)
                  Text(star.bio!, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                if (star.category != null)
                  Text(star.category!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
