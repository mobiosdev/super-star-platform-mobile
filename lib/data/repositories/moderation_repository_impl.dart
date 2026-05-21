import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/moderation_item.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepositoryImpl();
});

class ModerationRepositoryImpl implements ModerationRepository {
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

  @override
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

  @override
  Future<void> approve(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateStatus(id, ModerationStatus.approved);
  }

  @override
  Future<void> reject(String id, {String? reason}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateStatus(id, ModerationStatus.rejected);
  }

  @override
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

  @override
  Stream<List<ModerationItem>> watchQueueUpdates() => _controller.stream;
}
