// lib/widgets/particle_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'particle.dart';
import 'particle_painter.dart';

class ParticleBackground extends StatefulWidget {
  final int numberOfParticles;
  const ParticleBackground({
    Key? key,
    this.numberOfParticles = 100,
  }) : super(key: key);
  @override
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}
class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late List<Particle> _particles;
  late Size _lastSize;
  late Duration _lastTime;

  @override
  void initState() {
    super.initState();
    _particles = [];
    _ticker = createTicker(_onTick);
    _ticker.start();
    _lastTime = Duration.zero;
    _lastSize = Size.zero;
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    final random = Random();
    _particles = List.generate(widget.numberOfParticles, (_) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final velocity = Offset(
        (random.nextDouble() * 2 - 1) * 20,
        -random.nextDouble() * 20,
      );
      final particle = Particle(
        position: Offset(dx, dy),
        velocity: velocity,
        size: 2 + random.nextDouble() * 4,
        color: Colors.purple,
        life: 0.5 + random.nextDouble() * 0.5,
      );
      return particle;
    });
    for (var p in _particles) {
      p.respawn(size);
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final dt = (elapsed - _lastTime).inMilliseconds / 1000.0;
    _lastTime = elapsed;

    if (_lastSize == Size.zero) return;

    for (var p in _particles) {
      p.update(dt, _lastSize);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      if (_lastSize != size) {
        _lastSize = size;
        _initializeParticles(size);
      }
      return CustomPaint(
        size: size,
        painter: ParticlePainter(_particles),
      );
    });
  }
}

