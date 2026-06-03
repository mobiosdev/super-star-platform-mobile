import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/light_blue_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../core/widgets/upgrade_prompt_modal.dart';
import '../providers/feed_provider.dart';
import 'fan_live_section.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SuperstarAppBar(
        title: 'SuperStar',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/customer/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/customer/messages'),
          ),
        ],
      ),
      body: _buildBody(context, feedState),
    );
  }

  Widget _buildBody(BuildContext context, FeedState feedState) {
    if (feedState.isLoading && feedState.posts.isEmpty) {
      return const LoadingShimmer(itemCount: 4);
    }

    if (feedState.error != null && feedState.posts.isEmpty) {
      return EmptyState(
        title: 'Could not load feed',
        subtitle: feedState.error,
        icon: Icons.wifi_off_rounded,
        action: () => ref.read(feedProvider.notifier).loadInitial(),
        actionLabel: 'Retry',
      );
    }

    if (feedState.posts.isEmpty) {
      return EmptyState(
        title: 'Your feed is empty',
        subtitle:
            'No posts yet. Subscribe to a Superstar in Explore, or ask an admin to add verified creators to the platform.',
        icon: Icons.rss_feed_rounded,
        action: () => context.push('/customer/explore'),
        actionLabel: 'Explore',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: FanLiveNowSection()),
          SliverToBoxAdapter(child: _FeedHeader()),
          SliverPadding(
            padding: Responsive.pagePadding(context),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= feedState.posts.length) {
                    return feedState.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        : const SizedBox(height: 32);
                  }
                  final post = feedState.posts[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.contentMaxWidth(context),
                      ),
                      child: ContentCard(
                        post: post,
                        onUpgrade: () => UpgradePromptModal.show(context),
                        onTap: () => context.push('/content/${post.id}'),
                        onProfileTap: () => context.push('/superstar/${post.superstarId}'),
                      ),
                    ),
                  );
                },
                childCount: feedState.posts.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LightBlueTheme.headerGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your subscriptions',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latest posts from creators you follow',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}
