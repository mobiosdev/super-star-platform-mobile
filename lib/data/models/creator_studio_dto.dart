/// Studio screen state: dashboard data plus optional degraded-mode warning.
class CreatorStudioLoadResult {
  const CreatorStudioLoadResult({
    required this.dashboard,
    this.warning,
    this.isPartial = false,
  });

  final CreatorStudioDashboardDto dashboard;
  final String? warning;
  final bool isPartial;
}

class CreatorStudioDashboardDto {
  const CreatorStudioDashboardDto({
    required this.subscribers,
    required this.revenue,
    this.live,
  });

  final DashboardMetricDto subscribers;
  final DashboardRevenueDto revenue;
  final LiveStreamStatusDto? live;

  /// Placeholder metrics when the dashboard API is down.
  factory CreatorStudioDashboardDto.fallbackEmpty({int periodDays = 30}) {
    return CreatorStudioDashboardDto(
      subscribers: const DashboardMetricDto(count: 0, display: '—'),
      revenue: DashboardRevenueDto(
        periodDays: periodDays,
        amountUsd: 0,
        display: '—',
      ),
    );
  }

  /// Best-effort mapping from `GET /analytics/superstars/{id}/overview`.
  factory CreatorStudioDashboardDto.fromAnalyticsFallback(
    Map<String, dynamic> json, {
    int periodDays = 30,
  }) {
    final subsRaw = json['total_subscribers'] ?? json['subscribers'];
    int subs = 0;
    String subsDisplay = '0';
    if (subsRaw is num) {
      subs = subsRaw.toInt();
      subsDisplay = subs.toString();
    } else if (subsRaw is Map) {
      subs = _asInt(subsRaw['count'] ?? subsRaw['total']);
      subsDisplay = (subsRaw['display'] ?? subs).toString();
    }

    num revenueUsd = 0;
    String revenueDisplay = '\$0';
    final revRaw = json['revenue'] ?? json['total_revenue'];
    if (revRaw is num) {
      revenueUsd = revRaw;
      revenueDisplay = '\$${revRaw.toStringAsFixed(2)}';
    } else if (revRaw is Map) {
      revenueUsd = revRaw['amount_usd'] as num? ?? revRaw['amount'] as num? ?? 0;
      revenueDisplay = (revRaw['display'] ?? '\$$revenueUsd').toString();
    }

    return CreatorStudioDashboardDto(
      subscribers: DashboardMetricDto(count: subs, display: subsDisplay),
      revenue: DashboardRevenueDto(
        periodDays: periodDays,
        amountUsd: revenueUsd,
        display: revenueDisplay,
      ),
    );
  }

  factory CreatorStudioDashboardDto.fromJson(Map<String, dynamic> json) {
    return CreatorStudioDashboardDto(
      subscribers: DashboardMetricDto.fromJson(
        Map<String, dynamic>.from(json['subscribers'] as Map? ?? {}),
      ),
      revenue: DashboardRevenueDto.fromJson(
        Map<String, dynamic>.from(json['revenue'] as Map? ?? {}),
      ),
      live: json['live'] != null
          ? LiveStreamStatusDto.fromJson(Map<String, dynamic>.from(json['live'] as Map))
          : null,
    );
  }
}

class DashboardMetricDto {
  const DashboardMetricDto({required this.count, required this.display});

  final int count;
  final String display;

  factory DashboardMetricDto.fromJson(Map<String, dynamic> json) {
    return DashboardMetricDto(
      count: _asInt(json['count']),
      display: (json['display'] ?? '${json['count']}').toString(),
    );
  }
}

class DashboardRevenueDto {
  const DashboardRevenueDto({
    required this.periodDays,
    required this.amountUsd,
    required this.display,
  });

  final int periodDays;
  final num amountUsd;
  final String display;

  factory DashboardRevenueDto.fromJson(Map<String, dynamic> json) {
    return DashboardRevenueDto(
      periodDays: _asInt(json['period_days']),
      amountUsd: json['amount_usd'] as num? ?? 0,
      display: (json['display'] ?? '\$0').toString(),
    );
  }
}

class LiveStreamStatusDto {
  const LiveStreamStatusDto({
    required this.isLive,
    this.streamId,
    this.title,
    this.startedAt,
    this.streamUrl,
  });

  final bool isLive;
  final String? streamId;
  final String? title;
  final DateTime? startedAt;
  final String? streamUrl;

  factory LiveStreamStatusDto.fromJson(Map<String, dynamic> json) {
    return LiveStreamStatusDto(
      isLive: json['is_live'] == true || json['status'] == 'LIVE',
      streamId: json['id']?.toString() ?? json['stream_id']?.toString(),
      title: json['title'] as String?,
      streamUrl: json['stream_url'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
    );
  }
}

class GoLiveResultDto {
  const GoLiveResultDto({
    this.fansNotified,
    this.message,
    this.streamId,
    this.contentId,
  });

  final int? fansNotified;
  final String? message;
  final String? streamId;
  final String? contentId;

  factory GoLiveResultDto.fromJson(Map<String, dynamic> json) {
    return GoLiveResultDto(
      fansNotified: json['fans_notified'] != null ? _asInt(json['fans_notified']) : null,
      message: json['message'] as String?,
      streamId: json['stream_id']?.toString() ?? json['id']?.toString(),
      contentId: json['content_id']?.toString(),
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return 0;
}
