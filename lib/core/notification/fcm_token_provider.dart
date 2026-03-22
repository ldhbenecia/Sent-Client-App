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

/// 로그인 후 호출 — FCM 토큰을 서버에 등록하고, 갱신 리스너도 설정
@riverpod
Future<void> registerFcmToken(Ref ref) async {
  final repo = ref.watch(fcmTokenRepositoryProvider);
  final service = NotificationService.instance;

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
