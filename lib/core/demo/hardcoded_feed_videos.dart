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
    this.mediaType = 'video',
    this.superstarId = 'demo-artist',
    this.superstarAvatarUrl = 'assets/images/feed/bns_banner.jpg',
    this.likes = 0,
    this.comments = 0,
    this.minutesAgo = 0,
  });

  final String id;
  final String superstarId;
  final String superstarName;
  final String superstarAvatarUrl;
  final String caption;
  final String videoUrl;
  final String thumbnailUrl;
  final String mediaType;
  final int likes;
  final int comments;
  final int minutesAgo;

  FeedPost toFeedPost() {
    return FeedPost(
      id: id,
      superstarId: superstarId,
      superstarName: superstarName,
      superstarAvatarUrl: superstarAvatarUrl,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      mediaUrl: mediaType == 'video' ? videoUrl : null,
      mediaType: mediaType,
      requiredTier: SubscriptionTier.silver,
      userTier: SubscriptionTier.platinum,
      likes: likes,
      comments: comments,
      createdAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
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
      contentType: mediaType == 'video' ? 'VIDEO_HD' : 'PHOTO',
      tierRequired: 'SILVER',
      thumbnailUrl: thumbnailUrl,
      mediaUrl: mediaType == 'video' ? videoUrl : null,
      likes: likes,
      comments: comments,
      createdAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
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
      minutesAgo: 0,
    ),
    HardcodedFeedVideo(
      id: '${idPrefix}sample-1',
      superstarName: 'Aria Nova',
      caption: 'Behind the scenes from today\'s shoot ✨',
      videoUrl: '',
      thumbnailUrl: 'assets/images/feed/bns_post1.jpg',
      mediaType: 'image',
      likes: 842,
      comments: 56,
      minutesAgo: 10,
    ),
    HardcodedFeedVideo(
      id: '${idPrefix}sample-2',
      superstarName: 'Jax Rivers',
      caption: 'Exclusive drop for my Gold members 🎵',
      videoUrl: '',
      thumbnailUrl: 'assets/images/feed/bns_post2.jpg',
      mediaType: 'image',
      likes: 1204,
      comments: 89,
      minutesAgo: 20,
    ),
    HardcodedFeedVideo(
      id: '${idPrefix}sample-3',
      superstarName: 'Luna Sky',
      caption: 'Platinum-only studio session preview',
      videoUrl: '',
      thumbnailUrl: 'assets/images/feed/bns_post3.jpg',
      mediaType: 'image',
      likes: 954,
      comments: 42,
      minutesAgo: 30,
    ),
  ];
}
