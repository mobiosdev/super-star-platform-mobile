import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/repositories/message_repository_impl.dart';

final _inboxProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(messageRepositoryProvider).getInbox();
});

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_inboxProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Messages'),
      body: async.when(
        loading: () => const LoadingShimmer(itemCount: 5),
        error: (e, _) => EmptyState(
          title: 'Inbox unavailable',
          subtitle: '$e',
          icon: Icons.error_outline,
          action: () => ref.invalidate(_inboxProvider),
          actionLabel: 'Retry',
        ),
        data: (messages) {
          if (messages.isEmpty) {
            return const EmptyState(
              title: 'No messages',
              subtitle: 'Your inbox is empty.',
              icon: Icons.mail_outline,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = messages[i];
              return ListTile(
                title: Text(
                  m.senderName ?? m.recipientName ?? 'Message',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(m.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: m.isRead
                    ? null
                    : const Icon(Icons.circle, size: 10, color: AppColors.primary),
              );
            },
          );
        },
      ),
    );
  }
}
