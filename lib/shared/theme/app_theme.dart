import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_color_theme.dart';

class AppTheme {
  static const _fontFamily = 'Pretendard';

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colors: AppColorTheme.dark,
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
    statusBarStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    colors: AppColorTheme.light,
    colorScheme: ColorScheme.light(
      surface: AppColorTheme.light.card,
      onSurface: AppColorTheme.light.foreground,
      primary: AppColorTheme.light.foreground,
      onPrimary: AppColorTheme.light.background,
      secondary: AppColorTheme.light.secondary,
      onSecondary: AppColorTheme.light.foreground,
      error: AppColorTheme.light.destructiveRed,
      outline: AppColorTheme.light.border,
    ),
    statusBarStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColorTheme colors,
    required ColorScheme colorScheme,
    required SystemUiOverlayStyle statusBarStyle,
  }) =>
      ThemeData(
        useMaterial3: true,
        brightness: brightness,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: colors.background,
        colorScheme: colorScheme,
        extensions: [colors],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: statusBarStyle,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            color: colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.foreground,
            foregroundColor: colors.background,
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
            foregroundColor: colors.textMuted,
            textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.secondary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.textMuted, width: 1),
          ),
          hintStyle: TextStyle(
            fontFamily: _fontFamily,
            color: colors.textPlaceholder,
            fontSize: 15,
          ),
        ),
        cardTheme: CardThemeData(
          color: colors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border, width: 0.5),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: colors.border,
          thickness: 0.5,
        ),
        iconTheme: IconThemeData(
          color: colors.textMuted,
          size: 22,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          displayMedium: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          displaySmall: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          headlineLarge: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          headlineMedium: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
          headlineSmall: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
          titleLarge: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2),
          titleMedium: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: _fontFamily, color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: _fontFamily, color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: _fontFamily, color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontFamily: _fontFamily, color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontFamily: _fontFamily, color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w400),
        ),
      );
}
