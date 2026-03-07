import 'package:flutter_test/flutter_test.dart';
import 'package:sent_client/core/auth/auth_state.dart';

void main() {
  test('AuthStateNotifier.logout triggers cleanup callback and notifies', () {
    final notifier = AuthStateNotifier();
    var cleanupCalled = false;
    var notifiedCount = 0;

    notifier.addListener(() => notifiedCount++);
    notifier.setCleanupCallback(() => cleanupCalled = true);
    notifier.logout();

    expect(cleanupCalled, isTrue);
    expect(notifiedCount, 1);
  });
}
