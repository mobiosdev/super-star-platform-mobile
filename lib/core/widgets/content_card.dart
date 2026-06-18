import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/subscription_tier.dart';
import '../constants/app_colors.dart';
import '../constants/light_blue_theme.dart';
import 'feed_thumbnail.dart';
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
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final cardRadius = isTablet ? 16.0 : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        border: isTablet
            ? Border.all(
                color: theme.dividerColor,
                width: 1.5,
              )
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1.0,
                ),
              ),
        boxShadow: isTablet
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(post: post, onProfileTap: onProfileTap),
              _MediaSection(post: post, onTap: onTap, onUpgrade: onUpgrade),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.caption,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                        height: 1.32,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatPill(
                          icon: Icons.favorite_border,
                          count: _formatCount(post.likes),
                        ),
                        const SizedBox(width: 8),
                        _StatPill(
                          icon: Icons.chat_bubble_outline,
                          count: _formatCount(post.comments),
                        ),
                        const Spacer(),
                        TierBadge(tier: post.requiredTier, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.count});
  final IconData icon;
  final String count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            count,
            style: GoogleFonts.roboto(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post, this.onProfileTap});
  final FeedPost post;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onProfileTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LightBlueTheme.primaryGradient,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(1.5),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: _avatarProvider(post.superstarAvatarUrl),
          ),
        ),
      ),
      title: Text(
        post.superstarName,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        DateFormat.MMMd().add_jm().format(post.createdAt),
        style: GoogleFonts.roboto(fontSize: 10.5, color: theme.textTheme.bodySmall?.color),
      ),
      trailing: Icon(Icons.more_horiz, color: AppColors.textSecondary),
    );
  }

  ImageProvider _avatarProvider(String url) {
    if (url.startsWith('assets/')) return AssetImage(url);
    return CachedNetworkImageProvider(url);
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({required this.post, this.onTap, this.onUpgrade});
  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final mediaPadding = isTablet ? const EdgeInsets.symmetric(horizontal: 14) : EdgeInsets.zero;
    final mediaRadius = isTablet ? BorderRadius.circular(16) : BorderRadius.zero;

    return GestureDetector(
      onTap: post.needsUpgrade ? onUpgrade : onTap,
      child: Padding(
        padding: mediaPadding,
        child: ClipRRect(
          borderRadius: mediaRadius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: FeedThumbnail(url: post.thumbnailUrl, fit: BoxFit.cover),
              ),
              if (post.needsUpgrade) ...[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: mediaRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ),
                  ),
                ),
                _LockedOverlay(tier: post.requiredTier, onUpgrade: onUpgrade),
              ] else ...[
                if (post.mediaType == 'video')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: AppColors.secondary, size: 36),
                  ),
              ],
            ],
          ),
        ),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: const Icon(Icons.lock_outline_rounded, size: 28, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          '${tier.label} Content',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 15,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUpgrade,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LightBlueTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                'Unlock with ${tier.label}',
                style: GoogleFonts.roboto(
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
