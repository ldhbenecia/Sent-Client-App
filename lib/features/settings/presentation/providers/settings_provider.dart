import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

// ── 테마 모드 ──────────────────────────────────────────────────────
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      try {
        state = ThemeMode.values.byName(saved);
      } catch (_) {}
    }
  }
}

// ── 언어 설정 ──────────────────────────────────────────────────────
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'locale';

  @override
  Locale? build() {
    _load();
    return null; // null = 시스템 기본값
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      state = Locale(code);
    }
  }
}
