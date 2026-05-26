import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../api/platform_api.dart';
import '../models/content_dto.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(ref.watch(platformApiProvider));
});

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._api);
  final PlatformApi _api;

  @override
  Future<List<SubscriptionDto>> getMySubscriptions() => _api.getMySubscriptions();

  @override
  Future<Map<String, dynamic>> checkout({
    required String planId,
    required String billingCycle,
    required String successUrl,
    required String cancelUrl,
  }) =>
      _api.createCheckoutSession(
        planId: planId,
        billingCycle: billingCycle,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

  @override
  Future<void> cancel(String subscriptionId, {String? reason}) =>
      _api.cancelSubscription(subscriptionId, reason: reason);
}
