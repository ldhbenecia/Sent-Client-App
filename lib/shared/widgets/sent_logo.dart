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
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
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
    final scale = size.width / 72;

    // Paper plane (send icon)
    final bodyPaint = Paint()
      ..color = AppColors.primary300
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppColors.primary600
      ..style = PaintingStyle.fill;

    // 종이비행기 몸체 - 오른쪽 위를 향해 날아가는 방향
    final angle = -math.pi / 6; // 30도 기울기

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // 날개 왼쪽 (아래)
    final leftWing = Path()
      ..moveTo(0, -14 * scale)       // 코 (앞쪽 끝)
      ..lineTo(-12 * scale, 8 * scale) // 왼쪽 날개 끝
      ..lineTo(0, 4 * scale)          // 몸통 중심 아래
      ..close();
    canvas.drawPath(leftWing, bodyPaint);

    // 날개 오른쪽 (위)
    final rightWing = Path()
      ..moveTo(0, -14 * scale)
      ..lineTo(12 * scale, 6 * scale)
      ..lineTo(0, 4 * scale)
      ..close();
    canvas.drawPath(rightWing, Paint()
      ..color = AppColors.primary400
      ..style = PaintingStyle.fill);

    // 꼬리 접힌 부분 (하단 삼각)
    final tail = Path()
      ..moveTo(-12 * scale, 8 * scale)
      ..lineTo(0, 4 * scale)
      ..lineTo(-4 * scale, 14 * scale)
      ..close();
    canvas.drawPath(tail, shadowPaint);

    // 중앙 접힌 선 강조
    final foldLine = Path()
      ..moveTo(0, -14 * scale)
      ..lineTo(-4 * scale, 14 * scale);
    canvas.drawPath(
      foldLine,
      Paint()
        ..color = AppColors.primary700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 * scale,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
