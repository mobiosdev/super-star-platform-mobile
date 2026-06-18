import '../../domain/entities/feed_post.dart';
import '../../domain/entities/subscription_tier.dart';

class ContentDto {
  const ContentDto({
    required this.id,
    required this.superstarId,
    this.superstarName,
    this.superstarAvatarUrl,
    this.title,
    this.body,
    this.contentType,
    this.tierRequired,
    this.thumbnailUrl,
    this.mediaUrl,
    this.likes = 0,
    this.comments = 0,
    this.createdAt,
    this.isLocked = false,
    this.userTier,
    this.status,
  });

  final String id;
  final String superstarId;
  final String? superstarName;
  final String? superstarAvatarUrl;
  final String? title;
  final String? body;
  final String? contentType;
  final String? tierRequired;
  final String? thumbnailUrl;
  final String? mediaUrl;
  final int likes;
  final int comments;
  final DateTime? createdAt;
  final bool isLocked;
  final String? userTier;
  final String? status;

  factory ContentDto.fromJson(Map<String, dynamic> json) {
    final superstar = json['superstar'];
    Map<String, dynamic>? superstarMap;
    if (superstar is Map) {
      superstarMap = Map<String, dynamic>.from(superstar);
    }

    final media = json['media'];
    String? thumb;
    String? mediaUrl;
    if (media is List && media.isNotEmpty) {
      final first = media.first;
      if (first is Map) {
        thumb = first['thumbnail_url'] as String? ?? first['url'] as String?;
        mediaUrl = first['url'] as String?;
      }
    }

    thumb ??= json['thumbnail_url'] as String? ?? json['cover_url'] as String?;
    mediaUrl ??= json['media_url'] as String?;

    return ContentDto(
      id: (json['id'] ?? json['content_id'] ?? '').toString(),
      superstarId: (json['superstar_id'] ?? superstarMap?['id'] ?? '').toString(),
      superstarName: superstarMap?['display_name'] as String? ??
          superstarMap?['name'] as String? ??
          json['superstar_name'] as String?,
      superstarAvatarUrl: superstarMap?['avatar_url'] as String? ??
          superstarMap?['avatarUrl'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      contentType: json['content_type'] as String? ?? json['type'] as String?,
      tierRequired: json['tier_required'] as String?,
      thumbnailUrl: thumb,
      mediaUrl: mediaUrl,
      likes: _asInt(json['likes_count'] ?? json['likes']),
      comments: _asInt(json['comments_count'] ?? json['comments']),
      createdAt: _parseDate(json['created_at'] ?? json['published_at']),
      isLocked: json['is_locked'] == true || json['locked'] == true,
      userTier: json['user_tier'] as String?,
      status: json['status'] as String?,
    );
  }

  FeedPost toFeedPost({SubscriptionTier? defaultUserTier}) {
    final required = _tierFromApi(tierRequired);
    final user = userTier != null
        ? _tierFromApi(userTier)
        : (defaultUserTier ?? SubscriptionTier.silver);
    final locked = isLocked || user.level < required.level;

    return FeedPost(
      id: id,
      superstarId: superstarId,
      superstarName: superstarName ?? 'Superstar',
      superstarAvatarUrl: superstarAvatarUrl ?? 'https://i.pravatar.cc/150?u=$superstarId',
      caption: body ?? title ?? '',
      thumbnailUrl: thumbnailUrl ?? mediaUrl ?? 'https://picsum.photos/seed/$id/400/300',
      mediaUrl: mediaUrl,
      mediaType: _mediaTypeLabel(contentType),
      requiredTier: required,
      userTier: user,
      likes: likes,
      comments: comments,
      createdAt: createdAt ?? DateTime.now(),
      isLocked: locked,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static SubscriptionTier _tierFromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'GOLD':
        return SubscriptionTier.gold;
      case 'PLATINUM':
        return SubscriptionTier.platinum;
      default:
        return SubscriptionTier.silver;
    }
  }

  static String _mediaTypeLabel(String? type) {
    final upper = type?.toUpperCase() ?? '';
    if (upper.contains('VIDEO')) return 'video';
    if (upper.contains('AUDIO')) return 'audio';
    if (upper == 'PHOTO' || upper == 'POST' || upper == 'STORY') return 'image';
    return 'image';
  }
}

class SubscriptionDto {
  const SubscriptionDto({
    required this.id,
    required this.superstarId,
    this.tier,
    this.status,
  });

  final String id;
  final String superstarId;
  final String? tier;
  final String? status;

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) {
    final superstarId = json['superstar_id'] ??
        (json['superstar'] is Map ? (json['superstar'] as Map)['id'] : null);
    return SubscriptionDto(
      id: (json['id'] ?? json['subscription_id'] ?? '').toString(),
      superstarId: superstarId.toString(),
      tier: json['tier'] as String? ?? json['plan_tier'] as String?,
      status: json['status'] as String?,
    );
  }
}
