import 'dart:developer';

import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/disturbance_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/enviroment_section.dart';


import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/input_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/log_input_stepper.dart';import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/mood_stress_section.dart';import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/quality_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_efficiency_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_stages_section.dart';import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_time_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/step_wrapper.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sleep_analysis/loading/ai_loading_analysis_page.dart';
import '../sleep_analysis/models/sleeplog_model_page.dart';
import '../sleep_log_service/local_storage.dart';

class SleepLogInputPage extends StatelessWidget {
  const SleepLogInputPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepLog.reset(),
      child: const _SleepLogInputView(),
    );
  }
}

/// Data holder for each step
class _SleepLogInputView extends StatefulWidget {
  const _SleepLogInputView();

  @override
  State<_SleepLogInputView> createState() => _SleepLogInputViewState();
}

class _SleepLogInputViewState extends State<_SleepLogInputView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saved = await SleepLogLocalStorage.loadPartial();
      if (saved != null) {
        context.read<SleepLog>().copyFrom(saved);
      }
    });
  }
  Future<void> _finish() async {
    await SleepLogLocalStorage.clearPartial();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AILoadingAnalysisPage(
          sleepLog: context.read<SleepLog>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      LogInputStep(title: 'Sleep Timeline', icon: Icons.timeline, builder: (_) => const SleepTimeSection()),
      LogInputStep(title: 'Sleep Quality', icon: Icons.star_border, builder: (_) => const QualitySection()),
      LogInputStep(title: 'Mood & Stress', icon: Icons.psychology, builder: (_) => const MoodStressSection()),
      LogInputStep(title: 'Sleep Stages', icon: Icons.waves, builder: (_) => const SleepStagesSection()),
      LogInputStep(title: 'Efficiency', icon: Icons.account_tree, builder: (_) => const SleepEfficiencySection()),
      LogInputStep(title: 'Pre-Bed Habits', icon: Icons.nightlight_round, builder: (_) => const InputSection()),
      LogInputStep(
        title: 'Environment',
        icon: Icons.rocket_launch,
        builder: (_) => Column(
          children: const [
            EnvironmentSection(),
            SizedBox(height: 24),
            DisturbanceSection(),
          ],
        ),
      ),
      LogInputStep(title: 'Dream Journal', icon: Icons.drive_file_rename_outline, builder: (_) => const TextInputSection()),
    ];

    return Scaffold(
      body: SafeArea(
        child: LogInputStepper(
          steps: steps,
          onFinish: _finish,
        )
      ),
    );
  }

}