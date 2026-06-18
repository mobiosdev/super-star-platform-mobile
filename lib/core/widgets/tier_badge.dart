import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/subscription_tier.dart';
import '../constants/app_colors.dart';
import '../constants/light_blue_theme.dart';

class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier, this.compact = false});

  final SubscriptionTier tier;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
      decoration: _decoration(),
      child: Text(
        tier.label,
        style: GoogleFonts.roboto(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: _textColor(),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    switch (tier) {
      case SubscriptionTier.silver:
        return BoxDecoration(
          color: AppColors.silver.withOpacity(0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.silver),
        );
      case SubscriptionTier.gold:
        return BoxDecoration(
          color: AppColors.gold.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold),
        );
      case SubscriptionTier.platinum:
        return BoxDecoration(
          gradient: LightBlueTheme.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  Color _textColor() {
    return tier == SubscriptionTier.platinum ? Colors.white : AppColors.textPrimary;
  }
}
