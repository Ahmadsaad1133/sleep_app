// lib/views/Sleep_lognInput_page/sleep_analysis/loading/ai_loading_overlay.dart
// Thin helper overlay (OPTIONAL). You can ignore this if you prefer
// to only use MiniPCPanel with externalProgress.
// Intentionally minimal to avoid clashing with your data/API code.

import 'package:flutter/material.dart';

class AILoadingOverlay extends StatelessWidget {
  final bool show;
  final String? label;

  const AILoadingOverlay({super.key, required this.show, this.label});

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                label ?? 'Analyzing…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
