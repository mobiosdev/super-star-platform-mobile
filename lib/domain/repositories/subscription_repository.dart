import '../../data/models/content_dto.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionDto>> getMySubscriptions();
  Future<Map<String, dynamic>> checkout({
    required String planId,
    required String billingCycle,
    required String successUrl,
    required String cancelUrl,
  });
  Future<void> cancel(String subscriptionId, {String? reason});
}
