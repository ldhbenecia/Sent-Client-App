import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서는 시스템이 자동으로 알림 표시
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// 알림 탭 시 실행할 콜백 (GoRouter navigate 등)
  void Function(String type, String? id)? onNotificationTap;

  Future<void> init() async {
    // 1. 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. 포그라운드에서도 알림 배너 표시 (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. 로컬 알림 초기화 (포그라운드 표시용)
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(iOS: iosSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 5. 포그라운드 메시지 → 로컬 알림으로 표시
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // 6. 백그라운드에서 알림 탭 → 화면 이동
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    // 7. 앱 종료 상태에서 알림으로 열린 경우
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleMessageOpen(initialMessage);
  }

  /// iOS 알림 권한 요청 (로그인 후 호출)
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// FCM 토큰 반환 (서버 등록용)
  Future<String?> getToken() => _messaging.getToken();

  /// 토큰 갱신 스트림
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// FCM 토픽 구독
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  /// FCM 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';
      final id = data['id'] as String?;
      onNotificationTap?.call(type, id);
    } catch (_) {}
  }

  void _handleMessageOpen(RemoteMessage message) {
    final type = message.data['type'] as String? ?? '';
    final id = message.data['id'] as String?;
    onNotificationTap?.call(type, id);
  }
}
