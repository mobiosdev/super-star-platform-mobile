class SuperstarDto {
  const SuperstarDto({
    required this.id,
    this.displayName,
    this.bio,
    this.category,
    this.avatarUrl,
    this.coverUrl,
    this.verified = false,
    this.userId,
  });

  final String id;
  final String? displayName;
  final String? bio;
  final String? category;
  final String? avatarUrl;
  final String? coverUrl;
  final bool verified;
  final String? userId;

  factory SuperstarDto.fromJson(Map<String, dynamic> json) {
    return SuperstarDto(
      id: (json['id'] ?? '').toString(),
      displayName: json['display_name'] as String? ?? json['name'] as String?,
      bio: json['bio'] as String?,
      category: json['category'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      verified: json['verified'] == true,
      userId: json['user_id']?.toString(),
    );
  }
}

class PlanDto {
  const PlanDto({
    required this.id,
    required this.name,
    this.tier,
    this.priceMonthly,
    this.priceYearly,
    this.currency,
  });

  final String id;
  final String name;
  final String? tier;
  final num? priceMonthly;
  final num? priceYearly;
  final String? currency;

  factory PlanDto.fromJson(Map<String, dynamic> json) {
    return PlanDto(
      id: (json['id'] ?? json['plan_id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? 'Plan').toString(),
      tier: json['tier'] as String? ?? json['tier_required'] as String?,
      priceMonthly: json['price_monthly'] as num? ?? json['monthly_price'] as num?,
      priceYearly: json['price_yearly'] as num? ?? json['yearly_price'] as num?,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

class CommentDto {
  const CommentDto({
    required this.id,
    required this.body,
    this.authorName,
    this.createdAt,
    this.parentId,
  });

  final String id;
  final String body;
  final String? authorName;
  final DateTime? createdAt;
  final String? parentId;

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? json['user'];
    String? name;
    if (author is Map) {
      name = author['full_name'] as String? ?? author['display_name'] as String?;
    }
    return CommentDto(
      id: (json['id'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      authorName: name ?? json['author_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      parentId: json['parent_id']?.toString(),
    );
  }
}

class MessageDto {
  const MessageDto({
    required this.id,
    required this.body,
    this.senderName,
    this.recipientName,
    this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String body;
  final String? senderName;
  final String? recipientName;
  final DateTime? createdAt;
  final bool isRead;

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: (json['id'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      senderName: json['sender_name'] as String?,
      recipientName: json['recipient_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isRead: json['is_read'] == true || json['read'] == true,
    );
  }
}
