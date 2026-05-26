import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/light_blue_theme.dart';

/// Shown while restoring session from stored tokens.
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LightBlueTheme.headerGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Loading…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
