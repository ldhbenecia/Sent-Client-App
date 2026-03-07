import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/storage/shared_preferences_provider.dart';

part 'settings_provider.g.dart';

// ── 테마 모드 ──────────────────────────────────────────────────────
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key);
    if (saved == null) return ThemeMode.system;
    return ThemeMode.values.byName(saved);
  }

  Future<void> set(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = mode;
    await prefs.setString(_key, mode.name);
  }
}

// ── 언어 설정 ──────────────────────────────────────────────────────
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'locale';

  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_key);
    if (code == null) return null;
    return Locale(code);
  }

  Future<void> set(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = locale;
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
