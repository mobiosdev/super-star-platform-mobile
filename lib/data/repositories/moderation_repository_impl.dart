import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/moderation_item.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/moderation_repository.dart';
import '../api/platform_api.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepositoryImpl(ref.watch(platformApiProvider));
});

class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl(this._api);

  final PlatformApi _api;
  final _controller = StreamController<List<ModerationItem>>.broadcast();

  @override
  Future<List<ModerationItem>> fetchQueue({
    int page = 1,
    int limit = 20,
    String? search,
    SubscriptionTier? tierFilter,
  }) async {
    if (ApiConstants.useMockApi) {
      return _MockModerationStore.instance.fetchQueue(
        page: page,
        limit: limit,
        search: search,
        tierFilter: tierFilter,
      );
    }

    final items = await _api.getModerationQueue(page: page, limit: limit);
    var mapped = items.map((dto) => dto.toEntity()).toList();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      mapped = mapped
          .where(
            (e) =>
                e.superstarName.toLowerCase().contains(q) ||
                e.title.toLowerCase().contains(q),
          )
          .toList();
    }

    if (tierFilter != null) {
      mapped = mapped.where((e) => e.tier == tierFilter).toList();
    }

    mapped.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    _controller.add(mapped);
    return mapped;
  }

  @override
  Future<void> approve(String id) async {
    if (ApiConstants.useMockApi) {
      return _MockModerationStore.instance.approve(id);
    }
    await _api.approveContent(id, note: 'Approved from mobile app');
  }

  @override
  Future<void> reject(String id, {String? reason}) async {
    if (ApiConstants.useMockApi) {
      return _MockModerationStore.instance.reject(id);
    }
    await _api.rejectContent(
      id,
      reasonText: reason ?? 'Rejected from mobile moderation',
    );
  }

  @override
  Future<void> escalate(String id) async {
    if (ApiConstants.useMockApi) {
      return _MockModerationStore.instance.escalate(id);
    }
    await _api.claimModeration(id);
  }

  @override
  Stream<List<ModerationItem>> watchQueueUpdates() => _controller.stream;
}

/// In-memory queue used when `USE_MOCK_API=true`.
class _MockModerationStore {
  _MockModerationStore._();
  static final instance = _MockModerationStore._();

  final List<ModerationItem> _cache = _generateMockQueue(25);
  final _controller = StreamController<List<ModerationItem>>.broadcast();

  static List<ModerationItem> _generateMockQueue(int count) {
    final names = ['Aria Nova', 'Jax Rivers', 'Luna Sky', 'Kai Storm'];
    return List.generate(count, (i) {
      final hoursAgo = [2.0, 5.0, 9.0, 12.0, 3.5][i % 5];
      return ModerationItem(
        id: 'mod_$i',
        superstarName: names[i % names.length],
        superstarId: 'ss_$i',
        thumbnailUrl: 'https://picsum.photos/seed/mod$i/200/150',
        title: 'Content submission #${i + 1}',
        tier: SubscriptionTier.values[i % 3],
        submittedAt: DateTime.now().subtract(Duration(minutes: (hoursAgo * 60).round())),
        status: ModerationStatus.pending,
        description: 'Submitted for review — ${SubscriptionTier.values[i % 3].label} tier content.',
        mediaUrl: 'https://picsum.photos/seed/full$i/800/600',
      );
    });
  }

  Future<List<ModerationItem>> fetchQueue({
    int page = 1,
    int limit = 20,
    String? search,
    SubscriptionTier? tierFilter,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    var items = _cache.where((e) => e.status == ModerationStatus.pending).toList();
    items.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((e) => e.superstarName.toLowerCase().contains(q)).toList();
    }
    if (tierFilter != null) {
      items = items.where((e) => e.tier == tierFilter).toList();
    }
    final start = (page - 1) * limit;
    if (start >= items.length) return [];
    return items.skip(start).take(limit).toList();
  }

  Future<void> approve(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateStatus(id, ModerationStatus.approved);
  }

  Future<void> reject(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateStatus(id, ModerationStatus.rejected);
  }

  Future<void> escalate(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateStatus(id, ModerationStatus.escalated);
  }

  void _updateStatus(String id, ModerationStatus status) {
    final idx = _cache.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final old = _cache[idx];
    _cache[idx] = ModerationItem(
      id: old.id,
      superstarName: old.superstarName,
      superstarId: old.superstarId,
      thumbnailUrl: old.thumbnailUrl,
      title: old.title,
      tier: old.tier,
      submittedAt: old.submittedAt,
      status: status,
      mediaUrl: old.mediaUrl,
      description: old.description,
    );
    _controller.add(_cache.where((e) => e.status == ModerationStatus.pending).toList());
  }
}
