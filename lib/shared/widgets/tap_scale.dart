import 'package:flutter/material.dart';

/// 탭하면 살짝 줄어들었다 튕겨 돌아오는 래퍼 위젯
///
/// GestureDetector + AnimationController 조합으로
/// 네이티브 앱의 버튼 누름 감도를 구현합니다.
class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.pressedDuration = const Duration(milliseconds: 80),
    this.releaseDuration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  /// 눌렸을 때 축소 속도
  final Duration pressedDuration;

  /// 놓았을 때 복귀 속도
  final Duration releaseDuration;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.pressedDuration,
      reverseDuration: widget.releaseDuration,
    );
    _anim = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _anim, child: widget.child),
    );
  }
}
