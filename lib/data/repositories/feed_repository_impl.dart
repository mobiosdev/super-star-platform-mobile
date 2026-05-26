import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/feed_repository.dart';
import '../api/platform_api.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(platformApiProvider));
});

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._api);

  final PlatformApi _api;

  static const _names = ['Aria Nova', 'Jax Rivers', 'Luna Sky', 'Kai Storm', 'Mira Bloom'];
  static const _captions = [
    'Behind the scenes from today\'s shoot ✨',
    'Exclusive drop for my Gold members 🎵',
    'Platinum-only studio session preview',
    'New merch collab announcement!',
    'Q&A highlights — thanks for all the love',
  ];

  @override
  Future<List<FeedPost>> fetchFeed({required int page, int limit = 10}) async {
    if (ApiConstants.useMockApi) {
      return _mockFeed(page: page, limit: limit);
    }

    final superstarIds = await _resolveSuperstarIds();
    if (superstarIds.isEmpty) return [];

    final futures = superstarIds.map(
      (id) => _api.getFeed(superstarId: id, page: page, limit: limit),
    );
    final results = await Future.wait(futures);

    final posts = <FeedPost>[];
    for (final items in results) {
      posts.addAll(items.map((dto) => dto.toFeedPost()));
    }

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (posts.length <= limit) return posts;
    return posts.take(limit).toList();
  }

  Future<List<String>> _resolveSuperstarIds() async {
    try {
      final subs = await _api.getMySubscriptions();
      final active = subs
          .where((s) => s.status == null || s.status!.toUpperCase() == 'ACTIVE')
          .map((s) => s.superstarId)
          .toSet()
          .toList();
      if (active.isNotEmpty) return active;
    } catch (_) {}

    try {
      final stars = await _api.listSuperstars(page: 1, limit: 10);
      return stars.map((s) => s.id).where((id) => id.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<FeedPost>> _mockFeed({required int page, int limit = 10}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final start = (page - 1) * limit;
    if (start >= 30) return [];
    return List.generate(limit, (i) {
      final index = start + i;
      if (index >= 30) return null;
      final required = SubscriptionTier.values[index % 3];
      const userTier = SubscriptionTier.gold;
      final locked = userTier.level < required.level;
      return FeedPost(
        id: 'post_$index',
        superstarId: 'ss_${index % 5}',
        superstarName: _names[index % _names.length],
        superstarAvatarUrl: 'https://i.pravatar.cc/150?u=$index',
        caption: _captions[index % _captions.length],
        thumbnailUrl: 'https://picsum.photos/seed/$index/400/300',
        mediaType: index.isEven ? 'video' : 'image',
        requiredTier: required,
        userTier: userTier,
        likes: 1200 + index * 47,
        comments: 80 + index * 3,
        createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
        isLocked: locked,
      );
    }).whereType<FeedPost>().toList();
  }
}
