import 'package:equatable/equatable.dart';
import 'subscription_tier.dart';

class FeedPost extends Equatable {
  const FeedPost({
    required this.id,
    required this.superstarId,
    required this.superstarName,
    required this.superstarAvatarUrl,
    required this.caption,
    required this.thumbnailUrl,
    required this.mediaType,
    required this.requiredTier,
    required this.userTier,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.isLocked = false,
  });

  final String id;
  final String superstarId;
  final String superstarName;
  final String superstarAvatarUrl;
  final String caption;
  final String thumbnailUrl;
  final String mediaType;
  final SubscriptionTier requiredTier;
  final SubscriptionTier userTier;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool isLocked;

  bool get needsUpgrade => isLocked || userTier.level < requiredTier.level;

  @override
  List<Object?> get props => [id, superstarId, createdAt];
}
