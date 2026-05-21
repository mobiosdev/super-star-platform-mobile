import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/light_blue_theme.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../core/widgets/tier_badge.dart';
import '../../domain/entities/moderation_item.dart';
import '../providers/moderation_provider.dart';

class ContentReviewScreen extends ConsumerWidget {
  const ContentReviewScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moderationProvider);
    ModerationItem? item;
    for (final i in state.items) {
      if (i.id == itemId) {
        item = i;
        break;
      }
    }

    if (item == null) {
      return Scaffold(
        appBar: const SuperstarAppBar(title: 'Review'),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      appBar: const SuperstarAppBar(title: 'Content Review'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              imageUrl: item.mediaUrl ?? item.thumbnailUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: LightBlueTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.superstarName,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TierBadge(tier: item.tier),
                    const SizedBox(height: 12),
                    Text(
                      item.description ?? '',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(moderationProvider.notifier).approve(item!.id);
                        if (context.mounted) context.pop();
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(moderationProvider.notifier).reject(item!.id);
                        if (context.mounted) context.pop();
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(moderationProvider.notifier).escalate(item!.id);
                  if (context.mounted) context.pop();
                },
                icon: const Icon(Icons.flag_outlined, color: AppColors.warning),
                label: const Text('Escalate to Superadmin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
