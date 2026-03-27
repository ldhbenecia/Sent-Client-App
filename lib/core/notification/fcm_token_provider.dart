import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/api_client.dart';
import 'fcm_token_repository.dart';
import 'notification_service.dart';

part 'fcm_token_provider.g.dart';

@riverpod
FcmTokenRepository fcmTokenRepository(Ref ref) {
  return FcmTokenRepository(ref.watch(dioProvider));
}

/// 로그인 후 호출 — 알림 권한 요청 → FCM 토큰 서버 등록 → 갱신 리스너 설정
@Riverpod(keepAlive: true)
Future<void> registerFcmToken(Ref ref) async {
  final repo = ref.read(fcmTokenRepositoryProvider);
  final service = NotificationService.instance;

  // 권한 요청 (로그인 후 첫 호출 시 iOS 다이얼로그 표시)
  final granted = await service.requestPermission();
  if (!granted) return;

  final token = await service.getToken();
  if (token != null) {
    try {
      await repo.registerToken(token);
    } catch (_) {}
  }

  // 토큰 갱신 시 자동 재등록
  service.onTokenRefresh.listen((newToken) async {
    try {
      await repo.registerToken(newToken);
    } catch (_) {}
  });
}
