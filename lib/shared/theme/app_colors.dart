import 'package:flutter/material.dart';

class AppColors {
  // ── Core Semantic ──────────────────────────────────────────
  static const background   = Color(0xFF000000);
  static const foreground   = Color(0xFFFFFFFF);

  static const card         = Color(0xFF0F0F0F);
  static const cardFg       = Color(0xFFFFFFFF);

  static const secondary    = Color(0xFF1A1A1A);
  static const secondaryFg  = Color(0xFFFFFFFF);

  static const muted        = Color(0xFF1A1A1A);
  static const mutedFg      = Color(0xFF999999);

  static const accent       = Color(0xFF1A1A1A);
  static const accentFg     = Color(0xFFFFFFFF);

  static const popover      = Color(0xFF0F0F0F);
  static const popoverFg    = Color(0xFFF8CA56); // gold accent

  static const destructive  = Color(0xFF737373);
  static const destructiveFg = Color(0xFFFFFFFF);
  static const destructiveRed = Color(0xFFFF453A); // 삭제 버튼 실제 red

  static const border       = Color(0xFF262626);
  static const input        = Color(0xFF262626);
  static const ring         = Color(0xFFCCCCCC);

  // ── Primary Scale ──────────────────────────────────────────
  static const primary      = Color(0xFFFFFFFF);
  static const primaryFg    = Color(0xFF000000);

  static const primary50    = Color(0xFFFAFAFA);
  static const primary100   = Color(0xFFF5F5F5);
  static const primary200   = Color(0xFFE5E5E5);
  static const primary300   = Color(0xFFD4D4D4);
  static const primary400   = Color(0xFFA3A3A3);
  static const primary500   = Color(0xFF737373);
  static const primary600   = Color(0xFF525252);
  static const primary700   = Color(0xFF404040);
  static const primary800   = Color(0xFF262626);
  static const primary900   = Color(0xFF171717);
  static const primary950   = Color(0xFF000000);

  // ── Text ───────────────────────────────────────────────────
  static const textPrimary     = Color(0xFFFFFFFF);
  static const textSecondary   = Color(0xFFE5E5E5); // primary200
  static const textTertiary    = Color(0xFFD4D4D4); // primary300
  static const textMuted       = Color(0xFF999999); // muted-fg
  static const textDisabled    = Color(0xFF525252); // primary600
  static const textPlaceholder = Color(0xFF404040); // primary700

  // ── Glass ──────────────────────────────────────────────────
  static const glassBackground = Color(0x1AFFFFFF); // white 10%
  static const glassBorder     = Color(0x26FFFFFF); // white 15%
  static const glassDark       = Color(0xCC0F0F0F); // card 80%

  // ── Category Preset Colors ─────────────────────────────────
  static const categoryRed    = Color(0xFFFF6467);
  static const categoryOrange = Color(0xFFFF9F0A);
  static const categoryYellow = Color(0xFFFFD60A);
  static const categoryGreen  = Color(0xFF32D74B);
  static const categoryBlue   = Color(0xFF0A84FF);
  static const categoryPurple = Color(0xFFBF5AF2);
  static const categoryPink   = Color(0xFFFF375F);
  static const categoryCyan   = Color(0xFF64D2FF);

  static const List<Color> categoryPresets = [
    categoryRed,
    categoryOrange,
    categoryYellow,
    categoryGreen,
    categoryBlue,
    categoryPurple,
    categoryPink,
    categoryCyan,
  ];
}
