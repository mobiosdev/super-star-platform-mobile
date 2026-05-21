import '../entities/moderation_item.dart';
import '../entities/subscription_tier.dart';

abstract class ModerationRepository {
  Future<List<ModerationItem>> fetchQueue({
    int page = 1,
    int limit = 20,
    String? search,
    SubscriptionTier? tierFilter,
  });
  Future<void> approve(String id);
  Future<void> reject(String id, {String? reason});
  Future<void> escalate(String id);
  Stream<List<ModerationItem>> watchQueueUpdates();
}
