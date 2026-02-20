import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static const _fontFamily = 'Pretendard';

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryFg,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryFg,
      error: AppColors.destructiveRed,
      outline: AppColors.border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryFg,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.ring, width: 1),
      ),
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPlaceholder,
        fontSize: 15,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 0.5,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textMuted,
      size: 22,
    ),
    textTheme: const TextTheme(
      // Display
      displayLarge: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      // Heading
      headlineLarge: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineMedium: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      // Title
      titleLarge: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontFamily: _fontFamily, color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
      // Body
      bodyLarge: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: _fontFamily, color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w400),
      // Label
      labelLarge: TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: _fontFamily, color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w400),
    ),
  );
}
