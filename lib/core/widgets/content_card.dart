import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/subscription_tier.dart';
import '../constants/app_colors.dart';
import '../constants/light_blue_theme.dart';
import 'tier_badge.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.post,
    this.onTap,
    this.onUpgrade,
    this.onProfileTap,
  });

  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onUpgrade;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: LightBlueTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post, onProfileTap: onProfileTap),
          _MediaSection(post: post, onTap: onTap, onUpgrade: onUpgrade),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.caption,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${_formatCount(post.likes)}', style: _statStyle()),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${_formatCount(post.comments)}', style: _statStyle()),
                    const Spacer(),
                    TierBadge(tier: post.requiredTier, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _statStyle() => GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary);

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post, this.onProfileTap});
  final FeedPost post;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onProfileTap,
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(post.superstarAvatarUrl),
      ),
      title: Text(
        post.superstarName,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        DateFormat.MMMd().add_jm().format(post.createdAt),
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary),
      ),
      trailing: Icon(Icons.more_horiz, color: AppColors.textSecondary),
    );
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({required this.post, this.onTap, this.onUpgrade});
  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: post.needsUpgrade ? onUpgrade : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: CachedNetworkImage(
                imageUrl: post.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          if (post.needsUpgrade) ...[
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.72)),
            ),
            _LockedOverlay(tier: post.requiredTier, onUpgrade: onUpgrade),
          ] else if (post.mediaType == 'video')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ),
        ],
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({required this.tier, this.onUpgrade});
  final SubscriptionTier tier;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.secondary),
        const SizedBox(height: 8),
        Text(
          '${tier.label} content',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUpgrade,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LightBlueTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Upgrade to Platinum',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
