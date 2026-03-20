import 'dart:math';
import 'package:flutter/material.dart';

/// Glass bottom nav bar (_LiquidGlassBottomNav)의 실제 시각 영역 높이를 반환한다.
///
/// 구성: `SizedBox(height: 82)` + `SafeArea(minimum: bottom: 12)`.
/// `extendBody: true` 구조에서 empty/loading/error state를 시각적으로
/// 정중앙에 배치하려면 이 값만큼 bottom padding을 추가한다.
///
/// 사용 예:
/// ```dart
/// SliverFillRemaining(
///   hasScrollBody: false,
///   child: Padding(
///     padding: EdgeInsets.only(bottom: navBarReservedHeight(context)),
///     child: Center(child: emptyContent),
///   ),
/// )
/// ```
double navBarReservedHeight(BuildContext context) {
  final sysPad = MediaQuery.viewPaddingOf(context).bottom;
  return 82.0 + max(sysPad, 12.0);
}
