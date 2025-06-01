// lib/widgets/particle.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '/constants/colors.dart'; //

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double life;
  Random _rand = Random();

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.life = 1.0,
  });

  void respawn(Size canvasSize) {
    final dx = _rand.nextDouble() * canvasSize.width;
    final dy = _rand.nextDouble() * canvasSize.height;
    position = Offset(dx, dy);
    final vx = (_rand.nextDouble() * 2 - 1) * 20;
    final vy = -(_rand.nextDouble() * 20);
    velocity = Offset(vx, vy);
    size = 4 + _rand.nextDouble() * 6;
    color = AppColors.primaryPurple;
    life = 0.5 + _rand.nextDouble() * 0.5;
  }

  void update(double dt, Size canvasSize) {
    position += velocity * dt;
    life -= dt * 0.2;

    if (life <= 0 ||
        position.dx < 0 ||
        position.dx > canvasSize.width ||
        position.dy < 0 ||
        position.dy > canvasSize.height) {
      respawn(canvasSize);
    }
  }
}
