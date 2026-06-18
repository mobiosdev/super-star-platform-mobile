import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class BnsMusicTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF0F0B0B) : AppColors.background;
    final surface = isDark ? const Color(0xFF1C1212) : AppColors.surface;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFFC9B8B8) : AppColors.textSecondary;
    final border = isDark ? const Color(0xFF3D2525) : AppColors.border;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: surface,
      background: background,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      textTheme: _textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: textSecondary),
        hintStyle: GoogleFonts.roboto(color: textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.primary.withOpacity(0.16),
        labelStyle: GoogleFonts.roboto(fontSize: 13, color: textPrimary),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _textTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      displayLarge: GoogleFonts.roboto(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.roboto(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
      titleLarge: GoogleFonts.roboto(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
      titleMedium: GoogleFonts.roboto(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: GoogleFonts.roboto(color: textPrimary, fontSize: 15),
      bodyMedium: GoogleFonts.roboto(color: textPrimary, fontSize: 14),
      bodySmall: GoogleFonts.roboto(color: textSecondary, fontSize: 12),
      labelLarge: GoogleFonts.roboto(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }

  static BoxDecoration cardDecoration(BuildContext context, {bool withShadow = true}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: theme.dividerColor),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(theme.brightness == Brightness.dark ? 0.24 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
