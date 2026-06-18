import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/superstar_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.construction_outlined,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuperstarAppBar(title: title, showBack: showBack),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.primary.withOpacity(0.7)),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
