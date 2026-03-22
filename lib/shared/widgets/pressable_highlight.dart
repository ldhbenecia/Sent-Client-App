import 'package:flutter/material.dart';

/// 탭/꾹 누르기 시 둥근 배경 하이라이트를 보여주는 래퍼.
///
/// - 빠른 탭: 최소 120 ms 동안 하이라이트 유지
/// - 꾹 누르기: 누르는 동안 유지, 놓으면 페이드아웃
class PressableHighlight extends StatefulWidget {
  const PressableHighlight({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12,
    this.highlightAlpha = 0.06,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double highlightAlpha;
  final EdgeInsets margin;
  final EdgeInsets padding;

  @override
  State<PressableHighlight> createState() => _PressableHighlightState();
}

class _PressableHighlightState extends State<PressableHighlight> {
  bool _pressed = false;
  bool _holding = false;

  void _onDown() {
    setState(() {
      _pressed = true;
      _holding = true;
    });
  }

  void _onUp() {
    _holding = false;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted && !_holding) setState(() => _pressed = false);
    });
  }

  void _onCancel() {
    _holding = false;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? (_) => _onDown() : null,
      onTapUp: widget.onTap != null ? (_) => _onUp() : null,
      onTapCancel: widget.onTap != null ? _onCancel : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Duration(milliseconds: _pressed ? 30 : 200),
        curve: Curves.easeOut,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _pressed
              ? textPrimary.withValues(alpha: widget.highlightAlpha)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }
}
