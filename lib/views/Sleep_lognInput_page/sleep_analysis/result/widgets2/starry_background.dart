import 'dart:math';
import 'package:flutter/material.dart';

class StarryBackground extends StatefulWidget {
  const StarryBackground({super.key});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Offset> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateStars();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _generateStars() {
    _stars.clear();
    for (int i = 0; i < 50; i++) {
      _stars.add(Offset(
        _random.nextDouble() * 500,
        _random.nextDouble() * 300,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarrySkyPainter(
            stars: _stars,
            animationValue: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _StarrySkyPainter extends CustomPainter {
  final List<Offset> stars;
  final double animationValue;

  _StarrySkyPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8 * animationValue);

    for (final star in stars) {
      canvas.drawCircle(star, 1.2 * animationValue, paint);

      if (star.dx % 5 < 1) {
        canvas.drawCircle(
            star,
            2.0 * animationValue,
            paint..color = Colors.amber.withOpacity(0.7 * animationValue));
      }
    }

    final milkyWay = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade900.withOpacity(0.1),
          Colors.purple.shade900.withOpacity(0.2),
          Colors.blue.shade900.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTRB(0, size.height / 3, size.width, size.height * 2 / 3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawRect(
        Rect.fromLTRB(0, size.height / 3, size.width, size.height * 2 / 3),
        milkyWay);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}