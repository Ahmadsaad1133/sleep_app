import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Shared neon design constants
const Color bgStart = Color(0xFF060D1F);
const Color bgEnd = Color(0xFF0E1C3A);
const Color cardStart = Color(0x0FFFFFFF);
const Color cardEnd = Color(0x11FFFFFF);
const Color neonA = Color(0xFF7AE1FF);
const Color neonB = Color(0xFF8F7BFF);
const Color neonC = Color(0xFF2EF8A0);

/// Background used across all sleep analysis tabs.
class NeoBackground extends StatelessWidget {
  final Widget child;
  const NeoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgStart, bgEnd],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _NeuralMesh()),
          Positioned(
            top: -120,
            right: -80,
            child: _glowOrb(220, neonB.withOpacity(0.16)),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _glowOrb(280, neonC.withOpacity(0.12)),
          ),
          child,
        ],
      ),
    );
  }
}

/// Card used for content sections to match the overview tab design.
class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const NeoCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardStart, cardEnd],
        ),
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

Widget _glowOrb(double size, Color c) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: c,
        blurRadius: size * .5,
        spreadRadius: size * .12,
      ),
    ],
  ),
);

/// Animated neural mesh backdrop.
class _NeuralMesh extends StatefulWidget {
  const _NeuralMesh();

  @override
  State<_NeuralMesh> createState() => _NeuralMeshState();
}

class _NeuralMeshState extends State<_NeuralMesh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _NeuralMeshPainter(progress: _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NeuralMeshPainter extends CustomPainter {
  final double progress;
  _NeuralMeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.05);

    for (int i = 0; i < 7; i++) {
      final path = Path();
      final amp = 20 + 12 * sin(progress * 2 * pi + i);
      final phase = progress * 2 * pi + i * 0.7;
      for (double x = -20; x <= size.width + 20; x += 16) {
        final y = size.height * (i + 1) / 8 + sin((x / 90) + phase) * amp;
        if (x == -20) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}