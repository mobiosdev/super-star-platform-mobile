import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/light_blue_theme.dart';
import '../../core/widgets/logout_button.dart';
import '../../core/widgets/superstar_app_bar.dart';

/// Superadmin → Stars tab: manage creators + sign out.
class SuperadminSuperstarsScreen extends StatelessWidget {
  const SuperadminSuperstarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SuperstarAppBar(
        title: 'Superstar Management',
        showBack: false,
        actions: const [LogoutIconButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: LightBlueTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.star_outline, size: 48, color: AppColors.primary.withOpacity(0.8)),
                const SizedBox(height: 12),
                Text(
                  'Platform Superstars',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verify, manage, and monitor creator accounts. Full management UI coming soon.',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const LogoutOutlinedButton(),
        ],
      ),
    );
  }
}
