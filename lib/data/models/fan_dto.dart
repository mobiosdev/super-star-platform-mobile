class FanNotificationDto {
  const FanNotificationDto({
    required this.id,
    this.type,
    this.title,
    this.body,
    this.message,
    this.superstarId,
    this.superstarName,
    this.isRead = false,
    this.createdAt,
    this.streamUrl,
  });

  final String id;
  final String? type;
  final String? title;
  final String? body;
  final String? message;
  final String? superstarId;
  final String? superstarName;
  final bool isRead;
  final DateTime? createdAt;
  final String? streamUrl;

  factory FanNotificationDto.fromJson(Map<String, dynamic> json) {
    final superstar = json['superstar'];
    Map<String, dynamic>? starMap;
    if (superstar is Map) starMap = Map<String, dynamic>.from(superstar);

    return FanNotificationDto(
      id: (json['id'] ?? json['notification_id'] ?? '').toString(),
      type: json['type'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      message: json['message'] as String?,
      superstarId: json['superstar_id']?.toString() ?? starMap?['id']?.toString(),
      superstarName: json['superstar_name'] as String? ??
          starMap?['display_name'] as String?,
      isRead: json['is_read'] == true || json['read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      streamUrl: json['stream_url'] as String?,
    );
  }
}

class FanLiveArtistDto {
  const FanLiveArtistDto({
    required this.superstarId,
    this.displayName,
    this.title,
    this.streamUrl,
    this.avatarUrl,
    this.streamId,
  });

  final String superstarId;
  final String? displayName;
  final String? title;
  final String? streamUrl;
  final String? avatarUrl;
  final String? streamId;

  factory FanLiveArtistDto.fromJson(Map<String, dynamic> json) {
    return FanLiveArtistDto(
      superstarId: (json['superstar_id'] ?? json['id'] ?? '').toString(),
      displayName: json['display_name'] as String? ?? json['name'] as String?,
      title: json['title'] as String? ?? json['live_title'] as String?,
      streamUrl: json['stream_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      streamId: json['stream_id']?.toString(),
    );
  }
}
