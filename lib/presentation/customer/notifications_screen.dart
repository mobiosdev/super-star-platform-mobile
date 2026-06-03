import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/models/fan_dto.dart';
import '../../data/repositories/fan_repository_impl.dart';

final _notificationsProvider = FutureProvider.autoDispose<List<FanNotificationDto>>((ref) {
  return ref.read(fanRepositoryProvider).getNotifications(limit: 50);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Notifications'),
      body: async.when(
        loading: () => const LoadingShimmer(itemCount: 6),
        error: (e, _) => EmptyState(
          title: 'Could not load notifications',
          subtitle: e is ApiException ? e.message : '$e',
          icon: Icons.error_outline,
          action: () => ref.invalidate(_notificationsProvider),
          actionLabel: 'Retry',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'No notifications',
              subtitle: 'Live alerts from artists you follow will appear here.',
              icon: Icons.notifications_none,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _NotificationTile(
                notification: items[i],
                onTap: () => _onTap(context, ref, items[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref, FanNotificationDto n) async {
    if (!n.isRead) {
      try {
        await ref.read(fanRepositoryProvider).markNotificationRead(n.id);
        ref.invalidate(_notificationsProvider);
      } catch (_) {}
    }
    if (n.superstarId != null && n.superstarId!.isNotEmpty && context.mounted) {
      context.push('/superstar/${n.superstarId}');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final FanNotificationDto notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLive = notification.type?.toUpperCase().contains('LIVE') == true;
    final subtitle = notification.message ??
        notification.body ??
        notification.title ??
        '';

    return Material(
      color: notification.isRead ? AppColors.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLive
                      ? AppColors.error.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLive ? Icons.sensors_rounded : Icons.notifications_outlined,
                  color: isLive ? AppColors.error : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.superstarName ?? 'Artist',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.MMMd().add_jm().format(notification.createdAt!.toLocal()),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
