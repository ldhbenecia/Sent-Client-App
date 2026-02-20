class AppConfig {
  /// .env 파일에 API_BASE_URL 설정 후 ./run.sh 로 실행
  /// 직접 지정: flutter run --dart-define=API_BASE_URL=https://api.sent.com
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const oauthCallbackScheme = 'sent';
  static const oauthCallbackUrl = 'sent://oauth/callback';
}
