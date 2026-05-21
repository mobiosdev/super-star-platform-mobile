import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl();
});

class FeedRepositoryImpl implements FeedRepository {
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
