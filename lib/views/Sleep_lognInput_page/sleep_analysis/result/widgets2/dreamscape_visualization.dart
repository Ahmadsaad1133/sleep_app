import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide RadialGradient;

class DreamscapeVisualization extends StatelessWidget {
  final bool showDreamscape;

  const DreamscapeVisualization({super.key, required this.showDreamscape});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: showDreamscape ? 1.0 : 0.0,
          duration: const Duration(seconds: 2),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  Color(0x301A237E),
                  Color(0x000A0E21),
                ],
              ),
            ),
            child: const RiveAnimation.asset(
              'assets/dreamscape.riv',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}