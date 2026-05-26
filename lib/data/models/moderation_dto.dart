import '../../domain/entities/moderation_item.dart';
import '../../domain/entities/subscription_tier.dart';

class ModerationDto {
  const ModerationDto({
    required this.id,
    required this.superstarId,
    this.superstarName,
    this.title,
    this.tierRequired,
    this.thumbnailUrl,
    this.mediaUrl,
    this.submittedAt,
    this.status,
    this.description,
  });

  final String id;
  final String superstarId;
  final String? superstarName;
  final String? title;
  final String? tierRequired;
  final String? thumbnailUrl;
  final String? mediaUrl;
  final DateTime? submittedAt;
  final String? status;
  final String? description;

  factory ModerationDto.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    Map<String, dynamic>? contentMap;
    if (content is Map) {
      contentMap = Map<String, dynamic>.from(content);
    }

    final superstar = json['superstar'] ?? contentMap?['superstar'];
    Map<String, dynamic>? superstarMap;
    if (superstar is Map) {
      superstarMap = Map<String, dynamic>.from(superstar);
    }

    return ModerationDto(
      id: (json['id'] ?? json['content_id'] ?? contentMap?['id'] ?? '').toString(),
      superstarId: (json['superstar_id'] ?? superstarMap?['id'] ?? '').toString(),
      superstarName: superstarMap?['display_name'] as String? ??
          json['superstar_name'] as String?,
      title: contentMap?['title'] as String? ?? json['title'] as String?,
      tierRequired: contentMap?['tier_required'] as String? ?? json['tier_required'] as String?,
      thumbnailUrl: contentMap?['thumbnail_url'] as String? ?? json['thumbnail_url'] as String?,
      mediaUrl: contentMap?['media_url'] as String? ?? json['media_url'] as String?,
      submittedAt: _parseDate(
        json['submitted_at'] ?? json['created_at'] ?? contentMap?['created_at'],
      ),
      status: (json['status'] ?? contentMap?['status'])?.toString(),
      description: contentMap?['body'] as String? ?? json['description'] as String?,
    );
  }

  ModerationItem toEntity() {
    return ModerationItem(
      id: id,
      superstarName: superstarName ?? 'Unknown',
      superstarId: superstarId,
      thumbnailUrl: thumbnailUrl ?? 'https://picsum.photos/seed/$id/200/150',
      title: title ?? 'Content review',
      tier: _tierFromApi(tierRequired),
      submittedAt: submittedAt ?? DateTime.now(),
      status: _statusFromApi(status),
      mediaUrl: mediaUrl,
      description: description,
    );
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

  static ModerationStatus _statusFromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'APPROVED':
        return ModerationStatus.approved;
      case 'REJECTED':
        return ModerationStatus.rejected;
      case 'ESCALATED':
      case 'UNDER_REVIEW':
        return ModerationStatus.escalated;
      default:
        return ModerationStatus.pending;
    }
  }
}
