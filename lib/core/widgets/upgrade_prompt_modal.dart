import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/light_blue_theme.dart';
import 'gradient_cta_button.dart';

class UpgradePromptModal extends StatelessWidget {
  const UpgradePromptModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UpgradePromptModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LightBlueTheme.headerGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(
              'Upgrade your membership',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _TierRow(tier: 'Silver', price: '\$4.99/mo', perks: 'Basic posts'),
                _TierRow(tier: 'Gold', price: '\$9.99/mo', perks: 'Videos + exclusives', highlighted: true),
                _TierRow(tier: 'Platinum', price: '\$19.99/mo', perks: 'All content + DMs', isPlatinum: true),
                const SizedBox(height: 20),
                GradientCtaButton(
                  label: 'Upgrade to Platinum',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.price,
    required this.perks,
    this.highlighted = false,
    this.isPlatinum = false,
  });

  final String tier;
  final String price;
  final String perks;
  final bool highlighted;
  final bool isPlatinum;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlatinum ? AppColors.primary : AppColors.border,
          width: isPlatinum ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                Text(perks, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.secondary)),
        ],
      ),
    );
  }
}
