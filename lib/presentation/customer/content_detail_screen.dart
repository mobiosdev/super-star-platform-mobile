import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/demo/hardcoded_feed_videos.dart';
import '../../core/widgets/app_video_player.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/feed_thumbnail.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../core/widgets/tier_badge.dart';
import '../../data/api/platform_api.dart';
import '../../data/models/content_dto.dart';
import '../../data/models/superstar_dto.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../domain/entities/subscription_tier.dart';

final _contentProvider = FutureProvider.autoDispose.family<ContentDto, String>((ref, id) {
  return ref.watch(contentRepositoryProvider).getById(id);
});

final _commentsProvider = FutureProvider.autoDispose.family<List<CommentDto>, String>((ref, id) {
  return ref.watch(platformApiProvider).getComments(id);
});

class ContentDetailScreen extends ConsumerStatefulWidget {
  const ContentDetailScreen({super.key, required this.contentId});

  final String contentId;

  @override
  ConsumerState<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _like() async {
    if (HardcodedFeedVideos.isHardcodedId(widget.contentId)) return;
    await ref.read(platformApiProvider).toggleLike(widget.contentId);
    ref.invalidate(_contentProvider(widget.contentId));
  }

  Future<void> _postComment() async {
    if (HardcodedFeedVideos.isHardcodedId(widget.contentId)) return;
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    await ref.read(platformApiProvider).addComment(widget.contentId, body: text);
    _commentController.clear();
    ref.invalidate(_commentsProvider(widget.contentId));
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(_contentProvider(widget.contentId));
    final isDemo = HardcodedFeedVideos.isHardcodedId(widget.contentId);
    final comments = isDemo
        ? const AsyncValue<List<CommentDto>>.data([])
        : ref.watch(_commentsProvider(widget.contentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Post'),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Error', subtitle: '$e', icon: Icons.error_outline),
        data: (item) {
          final tier = _tierFromApi(item.tierRequired);
          final videoUrl = _videoSource(item);
          final imageUrl = item.thumbnailUrl;
          final isVideo = videoUrl != null;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (isVideo)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppVideoPlayer(source: videoUrl, autoPlay: true),
                      )
                    else if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: FeedThumbnail(url: imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? 'Untitled',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TierBadge(tier: tier),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.body ?? '', style: GoogleFonts.poppins()),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _like,
                          icon: const Icon(Icons.favorite_border, color: AppColors.error),
                        ),
                        Text('${item.likes} likes'),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline, size: 20),
                        Text(' ${item.comments} comments'),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Comments', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    comments.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Text('Comments unavailable: $e'),
                      data: (list) {
                        if (list.isEmpty) {
                          return Text(
                            'No comments yet',
                            style: GoogleFonts.poppins(color: AppColors.textSecondary),
                          );
                        }
                        return Column(
                          children: list
                              .map(
                                (c) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(c.authorName ?? 'Fan'),
                                  subtitle: Text(c.body),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isDemo
                      ? Text(
                          'Demo video — likes and comments are not synced to the server.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment…',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _postComment,
                              icon: const Icon(Icons.send, color: AppColors.primary),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SubscriptionTier _tierFromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'GOLD':
        return SubscriptionTier.gold;
      case 'PLATINUM':
        return SubscriptionTier.platinum;
      default:
        return SubscriptionTier.silver;
    }
  }

  String? _videoSource(ContentDto item) {
    final type = item.contentType?.toUpperCase() ?? '';
    if (!type.contains('VIDEO')) return null;
    return item.mediaUrl ?? item.thumbnailUrl;
  }
}
