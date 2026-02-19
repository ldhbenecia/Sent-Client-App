import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SentLogo extends StatelessWidget {
  const SentLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: CustomPaint(
        painter: _SentIconPainter(),
      ),
    );
  }
}

class _SentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 배경 미묘한 그라디언트
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          const Color(0xFF242424),
          AppColors.card,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.24),
    );
    canvas.drawRRect(rrect, bgPaint);

    final s = size.width / 100; // 100 기준 스케일

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 5.5); // 약 32도

    // ── Trail dots ──────────────────────────────────────────
    final trailPaint = Paint()..style = PaintingStyle.fill;

    final trailPositions = [
      (x: -28.0 * s, y: 24.0 * s, r: 2.2 * s, a: 0.15),
      (x: -20.0 * s, y: 32.0 * s, r: 3.0 * s, a: 0.20),
      (x: -10.0 * s, y: 36.0 * s, r: 4.0 * s, a: 0.25),
    ];
    for (final t in trailPositions) {
      trailPaint.color = Color.fromRGBO(255, 255, 255, t.a);
      canvas.drawCircle(Offset(t.x, t.y), t.r, trailPaint);
    }

    // ── 종이비행기 몸체 ─────────────────────────────────────
    // 코 (앞)
    final nose    = Offset(0, -32 * s);
    // 왼쪽 날개 끝
    final leftTip = Offset(-26 * s, 20 * s);
    // 오른쪽 날개 끝
    final rightTip = Offset(26 * s, 14 * s);
    // 몸통 중심
    final center  = Offset(0, 9 * s);
    // 꼬리
    final tail    = Offset(-8 * s, 32 * s);

    // 왼쪽 날개 (밝은 면)
    final leftWing = Path()
      ..moveTo(nose.dx, nose.dy)
      ..lineTo(leftTip.dx, leftTip.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      leftWing,
      Paint()
        ..color = AppColors.primary200
        ..style = PaintingStyle.fill,
    );

    // 오른쪽 날개 (중간 명도)
    final rightWing = Path()
      ..moveTo(nose.dx, nose.dy)
      ..lineTo(rightTip.dx, rightTip.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      rightWing,
      Paint()
        ..color = AppColors.primary400
        ..style = PaintingStyle.fill,
    );

    // 꼬리 삼각 (그림자)
    final tailPath = Path()
      ..moveTo(leftTip.dx, leftTip.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(tail.dx, tail.dy)
      ..close();
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = AppColors.primary700
        ..style = PaintingStyle.fill,
    );

    // 중앙 접힘선
    canvas.drawLine(
      nose,
      tail,
      Paint()
        ..color = AppColors.primary800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * s
        ..strokeCap = StrokeCap.round,
    );

    // 날개 외곽선 (미세 테두리)
    final outlinePath = Path()
      ..moveTo(nose.dx, nose.dy)
      ..lineTo(leftTip.dx, leftTip.dy)
      ..lineTo(tail.dx, tail.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(rightTip.dx, rightTip.dy)
      ..close();
    canvas.drawPath(
      outlinePath,
      Paint()
        ..color = AppColors.primary600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 * s
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
