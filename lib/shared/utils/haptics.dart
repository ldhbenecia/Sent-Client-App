import 'package:flutter/services.dart';

/// 햅틱 피드백 유틸리티
///
/// iOS: Core Haptics 기반 (UIImpactFeedbackGenerator)
/// Android: Vibration API 기반
class Haptics {
  /// 가벼운 피드백 — 선택, 스위치 토글, 메뉴 열기
  static void light() => HapticFeedback.lightImpact();

  /// 중간 피드백 — 버튼 누름, 화면 이동, FAB
  static void medium() => HapticFeedback.mediumImpact();

  /// 묵직한 피드백 — 삭제 등 비가역적 동작
  static void heavy() => HapticFeedback.heavyImpact();

  /// 선택 피드백 — 세그먼트 전환, 날짜 스크롤
  static void select() => HapticFeedback.selectionClick();
}
