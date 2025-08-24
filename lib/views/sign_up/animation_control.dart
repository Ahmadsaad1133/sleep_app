import 'dart:math';
import 'package:flutter/material.dart';

/// Widget that paints multiple layered blue waves moving horizontally
class AnimatedWave extends StatefulWidget {
  /// Height of the wave area
  final double height;
  /// Duration of one full cycle
  final Duration duration;
  /// Number of wave layers
  final int layers;
  /// List of colors for each layer (from back to front)
  final List<Color>? colors;

  const AnimatedWave({
    Key? key,
    this.height = 100.0,
    this.duration = const Duration(seconds: 2),
    this.layers = 3,
    this.colors,
  }) : super(key: key);

  @override
  _AnimatedWaveState createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default blue gradient layers if not provided
    final baseColors = widget.colors ?? [
      Colors.lightBlueAccent.withOpacity(0.4),
      Colors.lightBlueAccent.withOpacity(0.6),
      Colors.lightBlueAccent.withOpacity(0.8),
    ];

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              phase: _animation.value,
              layers: widget.layers,
              colors: baseColors,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final int layers;
  final List<Color> colors;

  _WavePainter({
    required this.phase,
    required this.layers,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < layers; i++) {
      final path = Path();
      final double amplitude = size.height / (layers * 1.5) * (i + 1);
      final double speed = 1 + i * 0.3;
      final double verticalOffset = size.height / 2;
      final color = colors[i % colors.length];

      path.moveTo(0, verticalOffset);
      for (double x = 0; x <= size.width; x++) {
        final y = amplitude *
            sin((x / size.width * 2 * pi * speed) + phase) +
            verticalOffset;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      paint.color = color;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

