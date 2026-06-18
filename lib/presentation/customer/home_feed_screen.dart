import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_content_types.dart';
import '../providers/auth_provider.dart';
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.secondary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
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
      drawer: const _FansMenuDrawer(),
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
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ..._buildFeedHeaderSlivers(),
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Your feed is empty',
                subtitle:
                    'No posts yet. Subscribe to a Superstar in Explore, or ask an admin to add verified creators to the platform.',
                icon: Icons.rss_feed_rounded,
                action: () => context.push('/customer/explore'),
                actionLabel: 'Explore',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ..._buildFeedHeaderSlivers(),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isTablet(context) ? 32.0 : 0.0,
              vertical: 12,
            ),
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

  List<Widget> _buildFeedHeaderSlivers() {
    return const [
      SliverToBoxAdapter(child: _FeedBannerCarousel()),
      SliverToBoxAdapter(child: _FeedLiveButton()),
      SliverToBoxAdapter(child: FanLiveNowSection()),
    ];
  }
}


class _FeedLiveButton extends StatefulWidget {
  const _FeedLiveButton();

  @override
  State<_FeedLiveButton> createState() => _FeedLiveButtonState();
}

class _FeedLiveButtonState extends State<_FeedLiveButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final glow = _animationController.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08 + glow * 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.error.withOpacity(0.28 + glow * 0.32),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.12 + glow * 0.16),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/live-stream'),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.7 + glow * 0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(glow * 0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'WATCH LIVE',
                        style: GoogleFonts.poppins(
                          color: AppColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedBannerCarousel extends StatefulWidget {
  const _FeedBannerCarousel();

  @override
  State<_FeedBannerCarousel> createState() => _FeedBannerCarouselState();
}

class _FeedBannerCarouselState extends State<_FeedBannerCarousel> {
  static const _banners = [
    'assets/images/feed/bns_banner.jpg',
    'assets/images/feed/bns_banner1.jpg',
    'assets/images/feed/bns_banner2.jpg',
  ];

  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _banners.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _banners[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_banners.length, (index) {
                      final selected = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(selected ? 0.95 : 0.55),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FansMenuDrawer extends ConsumerWidget {
  const _FansMenuDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;

    final contentTypes = [
      {'type': ApiContentTypes.post, 'label': 'Post', 'icon': Icons.article_outlined, 'color': Colors.blue},
      {'type': ApiContentTypes.photo, 'label': 'Photo', 'icon': Icons.image_outlined, 'color': Colors.green},
      {'type': ApiContentTypes.videoSd, 'label': 'Video (SD)', 'icon': Icons.video_file_outlined, 'color': Colors.red},
      {'type': ApiContentTypes.videoHd, 'label': 'Video (HD)', 'icon': Icons.hd_outlined, 'color': Colors.purple},
      {'type': ApiContentTypes.story, 'label': 'Story', 'icon': Icons.history_toggle_off_outlined, 'color': Colors.orange},
      {'type': ApiContentTypes.audio, 'label': 'Audio', 'icon': Icons.audiotrack_outlined, 'color': Colors.teal},
      {'type': ApiContentTypes.download, 'label': 'Download', 'icon': Icons.download_for_offline_outlined, 'color': Colors.indigo},
      {'type': ApiContentTypes.liveAnnouncement, 'label': 'Live ann', 'icon': Icons.live_tv_outlined, 'color': Colors.pink},
      {'type': ApiContentTypes.poll, 'label': 'Poll', 'icon': Icons.poll_outlined, 'color': Colors.cyan},
      {'type': ApiContentTypes.merchLink, 'label': 'Merch link', 'icon': Icons.storefront_outlined, 'color': Colors.amber},
      {'type': ApiContentTypes.fanClubPost, 'label': 'Fan club post', 'icon': Icons.diversity_3_outlined, 'color': Colors.deepOrange},
    ];

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profile Section (Facebook style)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user?.avatarUrl != null
                          ? CachedNetworkImageProvider(user!.avatarUrl!)
                          : const CachedNetworkImageProvider('https://i.pravatar.cc/150?u=current-user') as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user?.displayName ?? 'Nuwin Vinwath',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.sync, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Section Divider / Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'Content Types',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Content Types Grid (Squares)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: contentTypes.length,
                itemBuilder: (context, index) {
                  final ct = contentTypes[index];
                  final color = ct['color'] as Color;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected content type: ${ct['label']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            ct['icon'] as IconData,
                            color: color,
                            size: 28,
                          ),
                          Text(
                            ct['label'] as String,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
