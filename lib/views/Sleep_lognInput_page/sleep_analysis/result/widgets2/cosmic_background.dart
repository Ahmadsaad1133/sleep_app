import 'package:flutter/material.dart';

class CosmicBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Colors.deepPurple.shade900.withOpacity(0.8),
              Colors.indigo.shade900.withOpacity(0.8),
              const Color(0xFF0A0E21),
            ],
            stops: const [0.1, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}