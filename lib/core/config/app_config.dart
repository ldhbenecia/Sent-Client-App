class AppConfig {
  /// flutter run --dart-define=API_BASE_URL=https://api.sent.com 으로 오버라이드 가능
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const oauthCallbackScheme = 'sent';
  static const oauthCallbackUrl = 'sent://oauth/callback';
}
