import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class LightBlueTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.background,
      dividerColor: AppColors.border,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: _textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.roboto(color: AppColors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: GoogleFonts.roboto(fontSize: 13, color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      // cardTheme: CardThemeData(
      //   color: AppColors.background,
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //     side: const BorderSide(color: AppColors.border, width: 1),
      //   ),
      // ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.roboto(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.roboto(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
      titleLarge: GoogleFonts.roboto(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: GoogleFonts.roboto(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: GoogleFonts.roboto(color: AppColors.textPrimary, fontSize: 15),
      bodyMedium: GoogleFonts.roboto(color: AppColors.textPrimary, fontSize: 14),
      bodySmall: GoogleFonts.roboto(color: AppColors.textSecondary, fontSize: 12),
      labelLarge: GoogleFonts.roboto(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
    );
  }

  static BoxDecoration cardDecoration({bool withShadow = true}) {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get headerGradient => const LinearGradient(
        colors: [AppColors.primaryLight, AppColors.primary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
