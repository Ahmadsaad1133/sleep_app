import 'dart:math';
import 'package:flutter/material.dart';
import 'particle.dart';

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final alpha = (p.life.clamp(0.0, 1.0) * 255).toInt();
      paint.color = p.color.withAlpha(alpha);
      final starPath = _createStarPath(center: p.position, radius: p.size, points: 5);
      canvas.drawPath(starPath, paint);
      final facePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.size * 0.08
        ..color = Colors.black.withAlpha(alpha)
        ..strokeCap = StrokeCap.round;
      final eyeWidth = p.size * 0.2;
      final eyeHeight = p.size * 0.07;
      final leftEyeRect = Rect.fromCenter(
        center: Offset(p.position.dx - p.size * 0.3, p.position.dy - p.size * 0.2),
        width: eyeWidth,
        height: eyeHeight,
      );
      final rightEyeRect = Rect.fromCenter(
        center: Offset(p.position.dx + p.size * 0.3, p.position.dy - p.size * 0.2),
        width: eyeWidth,
        height: eyeHeight,
      );
      canvas.drawArc(leftEyeRect, pi, pi, false, facePaint);
      canvas.drawArc(rightEyeRect, pi, pi, false, facePaint);
      final smileRect = Rect.fromCenter(
        center: Offset(p.position.dx, p.position.dy + p.size * 0.25),
        width: p.size * 0.6,
        height: p.size * 0.35,
      );
      canvas.drawArc(smileRect, 0, pi, false, facePaint);
    }
  }

  Path _createStarPath({
    required Offset center,
    required double radius,
    required int points,
  }) {
    final path = Path();
    final angleStep = (2 * pi) / (points * 2);
    final innerRadius = radius * 0.5;

    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : innerRadius;
      final theta = -pi / 2 + i * angleStep;

      final x = center.dx + r * cos(theta);
      final y = center.dy + r * sin(theta);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
