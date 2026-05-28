import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/light_blue_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../core/widgets/tier_badge.dart';
import '../../domain/entities/moderation_item.dart';
import '../providers/moderation_provider.dart';

class ContentReviewScreen extends ConsumerWidget {
  const ContentReviewScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('🔍 ContentReviewScreen opening for itemId: $itemId', name: 'ContentReview');
    
    final state = ref.watch(moderationProvider);
    log('📊 ModerationState has ${state.items.length} items', name: 'ContentReview');
    
    ModerationItem? item;
    for (final i in state.items) {
      log('  - Item: id=${i.id}, title=${i.title}, desc=${i.description}', name: 'ContentReview');
      if (i.id == itemId) {
        item = i;
        break;
      }
    }

    if (item == null) {
      log('❌ Item not found for id: $itemId', name: 'ContentReview');
      return Scaffold(
        appBar: const SuperstarAppBar(title: 'Review'),
        body: const Center(child: Text('Item not found')),
      );
    }

    log('✅ Item found: id=${item.id}, title=${item.title}, superstar=${item.superstarName}, desc=${item.description}', name: 'ContentReview');

    final mediaUrl = item.mediaUrl ?? item.thumbnailUrl;

    return Scaffold(
      appBar: const SuperstarAppBar(title: 'Content Review'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Preview
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 280,
                  color: AppColors.surface,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 280,
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: Responsive.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Content Title
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Superstar Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submitted by',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.superstarName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TierBadge(tier: item.tier),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Metadata
                  Row(
                    children: [
                      _MetadataItem(
                        icon: Icons.schedule,
                        label: 'Submitted',
                        value: DateFormat.yMMMMd().add_jm().format(item.submittedAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description/Details
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    Text(
                      'Content Details',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        item.description!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Action Buttons
                  Row(
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.flag_outlined, color: AppColors.primary),
                      label: const Text('Flag for Escalation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
