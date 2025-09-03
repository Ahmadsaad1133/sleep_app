import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../sleep_analysis/models/sleeplog_model_page.dart';

class SuggestedTags extends StatelessWidget {
  const SuggestedTags({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepLog>(
      builder: (context, log, _) {
        return Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Stressful day'),
              selected: log.stressLevel >= 8,
              onSelected: (_) => log.setStressLevel(8),
            ),
            FilterChip(
              label: const Text('Intense workout'),
              selected: log.exerciseMinutes >= 60,
              onSelected: (_) => log.setExercise('60'),
            ),
            FilterChip(
              label: const Text('Long screen time'),
              selected: log.screenTimeBeforeBed >= 120,
              onSelected: (_) => log.setScreenTime('120'),
            ),
            FilterChip(
              label: const Text('Melatonin'),
              selected: log.medications.toLowerCase().contains('melatonin'),
              onSelected: (_) => log.setMedications('Melatonin'),
            ),
          ],
        );
      },
    );
  }
}