import 'package:flutter/material.dart';

/// 아래에서 위로 슬라이드 + 페이드인 (모달 스타일 — create/edit)
Widget slideUpFadeTransition(Animation<double> animation, Widget child) =>
    FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
    );

/// 오른쪽에서 왼쪽으로 슬라이드 + 페이드인 (push 스타일 — preferences)
Widget slideRightFadeTransition(Animation<double> animation, Widget child) =>
    FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
    );
