import '../../data/models/content_dto.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/subscription_tier.dart';

/// Hardcoded fan-feed videos — edit this file to add your own clips.
///
/// **Bundled videos (offline):**
/// 1. Copy `.mp4` files into `assets/videos/`
/// 2. Optional thumbnails into `assets/images/feed/`
/// 3. Register paths in `pubspec.yaml` under `flutter.assets`
/// 4. Use paths like `assets/videos/my_clip.mp4`
///
/// **Remote videos:** set [videoUrl] / [thumbnailUrl] to `https://...` URLs.
class HardcodedFeedVideo {
  const HardcodedFeedVideo({
    required this.id,
    required this.superstarName,
    required this.caption,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.superstarId = 'demo-artist',
    this.superstarAvatarUrl = 'https://i.pravatar.cc/150?u=demo-artist',
    this.likes = 0,
    this.comments = 0,
  });

  final String id;
  final String superstarId;
  final String superstarName;
  final String superstarAvatarUrl;
  final String caption;
  final String videoUrl;
  final String thumbnailUrl;
  final int likes;
  final int comments;

  FeedPost toFeedPost() {
    return FeedPost(
      id: id,
      superstarId: superstarId,
      superstarName: superstarName,
      superstarAvatarUrl: superstarAvatarUrl,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      mediaUrl: videoUrl,
      mediaType: 'video',
      requiredTier: SubscriptionTier.silver,
      userTier: SubscriptionTier.platinum,
      likes: likes,
      comments: comments,
      createdAt: DateTime.now(),
      isLocked: false,
    );
  }

  ContentDto toContentDto() {
    return ContentDto(
      id: id,
      superstarId: superstarId,
      superstarName: superstarName,
      superstarAvatarUrl: superstarAvatarUrl,
      title: caption,
      body: caption,
      contentType: 'VIDEO_HD',
      tierRequired: 'SILVER',
      thumbnailUrl: thumbnailUrl,
      mediaUrl: videoUrl,
      likes: likes,
      comments: comments,
      createdAt: DateTime.now(),
      isLocked: false,
    );
  }
}

/// Fan feed demo videos — add, remove, or reorder entries here.
class HardcodedFeedVideos {
  HardcodedFeedVideos._();

  static const String idPrefix = 'hardcoded-';

  static bool isHardcodedId(String id) => id.startsWith(idPrefix);

  static ContentDto? contentById(String id) {
    for (final item in items) {
      if (item.id == id) return item.toContentDto();
    }
    return null;
  }

  static List<FeedPost> asFeedPosts() => items.map((v) => v.toFeedPost()).toList();

  /// Replace sample URLs with your own files or links.
  static const List<HardcodedFeedVideo> items = [
    // Example — swap for your bundled file:
    HardcodedFeedVideo(
      id: '${idPrefix}1',
      superstarName: 'For the Fans',
      caption: 'To all the fans',
      videoUrl: 'assets/videos/my_clip.mp4',
      thumbnailUrl: 'assets/images/feed/my_clip.png',
      likes: 128,
      comments: 12,
    ),
    HardcodedFeedVideo(
      id: '${idPrefix}sample-1',
      superstarName: 'Aria Nova',
      caption: 'Studio session preview — fan exclusive',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/feed-video-1/800/500',
      likes: 842,
      comments: 56,
    ),
    HardcodedFeedVideo(
      id: '${idPrefix}sample-2',
      superstarName: 'Jax Rivers',
      caption: 'Live rehearsal highlights',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/feed-video-2/800/500',
      likes: 1204,
      comments: 89,
    ),
  ];
}
