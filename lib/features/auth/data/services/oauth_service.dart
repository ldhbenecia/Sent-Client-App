import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../../../core/config/app_config.dart';

class OAuthService {
  /// provider: 'google' | 'naver' | 'kakao'
  ///
  /// 백엔드 흐름:
  ///   GET /oauth2/authorization/{provider}?state={callbackUrl}
  ///   → 소셜 로그인 후 백엔드가 callbackUrl?accessToken=...&refreshToken=... 로 리다이렉트
  static Future<({String accessToken, String refreshToken})> login(
    String provider,
  ) async {
    final authUrl =
        '${AppConfig.apiBaseUrl}/oauth2/authorization/${provider.toLowerCase()}'
        '?state=${Uri.encodeComponent(AppConfig.oauthCallbackUrl)}';

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: AppConfig.oauthCallbackScheme,
    );

    final uri = Uri.parse(result);
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      throw Exception('인증 토큰을 받지 못했습니다. (accessToken/refreshToken 누락)');
    }

    return (accessToken: accessToken, refreshToken: refreshToken);
  }
}
