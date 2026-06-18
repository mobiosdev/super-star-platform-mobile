import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/models/content_dto.dart';
import '../../data/repositories/subscription_repository_impl.dart';

final _subsProvider = FutureProvider.autoDispose<List<SubscriptionDto>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).getMySubscriptions();
});

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_subsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'My Subscriptions', showBack: false),
      body: async.when(
        loading: () => const LoadingShimmer(itemCount: 3),
        error: (e, _) => EmptyState(
          title: 'Could not load subscriptions',
          subtitle: '$e',
          icon: Icons.error_outline,
          action: () => ref.invalidate(_subsProvider),
          actionLabel: 'Retry',
        ),
        data: (subs) {
          if (subs.isEmpty) {
            return const EmptyState(
              title: 'No active subscriptions',
              subtitle: 'Explore Superstars and subscribe to see their exclusive content.',
              icon: Icons.card_membership_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: subs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final sub = subs[i];
              return Card(
                child: ListTile(
                  title: Text(
                    'Superstar ${sub.superstarId}',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${sub.tier ?? '—'} · ${sub.status ?? 'ACTIVE'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                    onPressed: () async {
                      await ref
                          .read(subscriptionRepositoryProvider)
                          .cancel(sub.id, reason: 'Cancelled from app');
                      ref.invalidate(_subsProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
