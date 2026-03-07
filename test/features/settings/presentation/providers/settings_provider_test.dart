import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sent_client/core/storage/shared_preferences_provider.dart';
import 'package:sent_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer buildContainer(SharedPreferences prefs) {
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  test('ThemeModeNotifier loads saved theme mode from preferences', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final container = buildContainer(prefs);
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
  });

  test('ThemeModeNotifier.set updates state and persists value', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = buildContainer(prefs);
    addTearDown(container.dispose);

    await container
        .read(themeModeNotifierProvider.notifier)
        .set(ThemeMode.light);

    expect(container.read(themeModeNotifierProvider), ThemeMode.light);
    expect(prefs.getString('themeMode'), 'light');
  });

  test('LocaleNotifier.set(null) clears stored locale', () async {
    SharedPreferences.setMockInitialValues({'locale': 'ko'});
    final prefs = await SharedPreferences.getInstance();
    final container = buildContainer(prefs);
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), const Locale('ko'));

    await container.read(localeNotifierProvider.notifier).set(null);

    expect(container.read(localeNotifierProvider), isNull);
    expect(prefs.getString('locale'), isNull);
  });
}
