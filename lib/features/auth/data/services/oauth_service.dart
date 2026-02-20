import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../../../core/config/app_config.dart';

class OAuthService {
  /// provider: 'google' | 'naver' | 'kakao'
  ///
  /// 백엔드 흐름:
  ///   GET /oauth2/authorization/{provider}
  ///   → Spring Security OAuth2 처리 → 소셜 로그인
  ///   → OAuth2AuthenticationSuccessHandler:
  ///       oauth.redirect.web(=sent://oauth/callback)?accessToken=...&refreshToken=...
  ///   → ASWebAuthenticationSession이 sent:// 스킴 감지 후 Flutter로 반환
  ///
  /// 백엔드 요구사항:
  ///   - application.yml: oauth.redirect.web=sent://oauth/callback
  ///   - RedirectUrlService.getSuccessRedirectUrl(accessToken, refreshToken) 형태로 수정
  static Future<({String accessToken, String refreshToken})> login(
    String provider,
  ) async {
    final authUrl =
        '${AppConfig.apiBaseUrl}/oauth2/authorization/${provider.toLowerCase()}';

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: AppConfig.oauthCallbackScheme,
    );

    final uri = Uri.parse(result);

    // 백엔드가 에러를 보낸 경우
    final error = uri.queryParameters['error'];
    if (error != null) {
      throw Exception('로그인 실패: $error');
    }

    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      throw Exception('인증 토큰을 받지 못했습니다. (accessToken/refreshToken 누락)');
    }

    return (accessToken: accessToken, refreshToken: refreshToken);
  }
}
