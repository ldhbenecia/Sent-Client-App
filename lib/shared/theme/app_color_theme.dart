import 'package:flutter/material.dart';

@immutable
class AppColorTheme extends ThemeExtension<AppColorTheme> {
  const AppColorTheme({
    required this.background,
    required this.foreground,
    required this.card,
    required this.secondary,
    required this.border,
    required this.input,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textDisabled,
    required this.textPlaceholder,
    required this.destructiveRed,
    required this.glassBackground,
    required this.glassBorder,
    required this.glassDark,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color secondary;
  final Color border;
  final Color input;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textDisabled;
  final Color textPlaceholder;
  final Color destructiveRed;
  final Color glassBackground;
  final Color glassBorder;
  final Color glassDark;

  // ── 다크 테마 (기존 AppColors 값 그대로) ───────────────────────────
  static const dark = AppColorTheme(
    background: Color(0xFF000000),
    foreground: Color(0xFFFFFFFF),
    card: Color(0xFF0F0F0F),
    secondary: Color(0xFF1A1A1A),
    border: Color(0xFF262626),
    input: Color(0xFF262626),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFE5E5E5),
    textTertiary: Color(0xFFD4D4D4),
    textMuted: Color(0xFF999999),
    textDisabled: Color(0xFF525252),
    textPlaceholder: Color(0xFF404040),
    destructiveRed: Color(0xFFFF453A),
    glassBackground: Color(0x1AFFFFFF),
    glassBorder: Color(0x26FFFFFF),
    glassDark: Color(0xCC0F0F0F),
  );

  // ── 라이트 테마 ─────────────────────────────────────────────────────
  static const light = AppColorTheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF000000),
    card: Color(0xFFF5F5F7),
    secondary: Color(0xFFEBEBED),
    border: Color(0xFFDDDDDD),
    input: Color(0xFFEBEBED),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF1A1A1A),
    textTertiary: Color(0xFF3A3A3A),
    textMuted: Color(0xFF6B6B6B),
    textDisabled: Color(0xFFAAAAAA),
    textPlaceholder: Color(0xFFCCCCCC),
    destructiveRed: Color(0xFFFF3B30),
    glassBackground: Color(0x14000000),
    glassBorder: Color(0x1F000000),
    glassDark: Color(0xCCF5F5F7),
  );

  @override
  AppColorTheme copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? secondary,
    Color? border,
    Color? input,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? textDisabled,
    Color? textPlaceholder,
    Color? destructiveRed,
    Color? glassBackground,
    Color? glassBorder,
    Color? glassDark,
  }) =>
      AppColorTheme(
        background: background ?? this.background,
        foreground: foreground ?? this.foreground,
        card: card ?? this.card,
        secondary: secondary ?? this.secondary,
        border: border ?? this.border,
        input: input ?? this.input,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textMuted: textMuted ?? this.textMuted,
        textDisabled: textDisabled ?? this.textDisabled,
        textPlaceholder: textPlaceholder ?? this.textPlaceholder,
        destructiveRed: destructiveRed ?? this.destructiveRed,
        glassBackground: glassBackground ?? this.glassBackground,
        glassBorder: glassBorder ?? this.glassBorder,
        glassDark: glassDark ?? this.glassDark,
      );

  @override
  AppColorTheme lerp(AppColorTheme? other, double t) {
    if (other == null) return this;
    return AppColorTheme(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      destructiveRed: Color.lerp(destructiveRed, other.destructiveRed, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassDark: Color.lerp(glassDark, other.glassDark, t)!,
    );
  }
}

// BuildContext 편의 확장
extension AppColorContext on BuildContext {
  AppColorTheme get colors =>
      Theme.of(this).extension<AppColorTheme>() ?? AppColorTheme.dark;
}
