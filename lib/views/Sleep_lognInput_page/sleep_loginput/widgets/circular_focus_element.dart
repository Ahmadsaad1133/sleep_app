// circular_focus_element.dart
import 'package:flutter/material.dart';

class CircularFocusElement extends StatelessWidget {
  const CircularFocusElement({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF5A6BC0).withOpacity(0.3),
            const Color(0xFF37B9C6).withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFF5A6BC0).withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.nightlight_round,
          size: 60,
          color: Color(0xFF37B9C6),
        ),
      ),
    );
  }
}