import 'package:equatable/equatable.dart';
import 'subscription_tier.dart';

enum ModerationStatus { pending, approved, rejected, escalated }

class ModerationItem extends Equatable {
  const ModerationItem({
    required this.id,
    required this.superstarName,
    required this.superstarId,
    required this.thumbnailUrl,
    required this.title,
    required this.tier,
    required this.submittedAt,
    required this.status,
    this.mediaUrl,
    this.description,
  });

  final String id;
  final String superstarName;
  final String superstarId;
  final String thumbnailUrl;
  final String title;
  final SubscriptionTier tier;
  final DateTime submittedAt;
  final ModerationStatus status;
  final String? mediaUrl;
  final String? description;

  Duration get queueDuration => DateTime.now().difference(submittedAt);

  @override
  List<Object?> get props => [id, status, submittedAt];
}
