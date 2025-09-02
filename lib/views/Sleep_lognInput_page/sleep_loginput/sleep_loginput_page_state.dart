import 'dart:developer';

import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/disturbance_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/enviroment_section.dart';


import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/input_section.dart';import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/mood_stress_section.dart';import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/quality_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_efficiency_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_stages_section.dart';import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_time_section.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/step_wrapper.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/text_input_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sleep_analysis/loading/ai_loading_analysis_page.dart';
import '../sleep_analysis/models/sleeplog_model_page.dart';
import '../sleep_log_service/local_storage.dart';
// Import your section widgets here
// import 'sections/sleep_time_section.dart';
// import 'sections/quality_section.dart';
// import 'sections/mood_stress_section.dart';
// import 'sections/sleep_stages_section.dart';
// import 'sections/sleep_efficiency_section.dart';
// import 'sections/input_section.dart';
// import 'sections/environment_section.dart';
// import 'sections/disturbance_section.dart';
// import 'sections/text_input_section.dart';
// import '../sleep_analysis/loading/ai_loading_analysis_page.dart';
// import 'step_wrapper.dart';

class SleepLogInputPage extends StatelessWidget {
  const SleepLogInputPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepLog.reset(),
      child: const _SleepLogFlow(),
    );
  }
}

/// Data holder for each step
class _StepData {
  final String title;
  final IconData icon;
  final Widget content;

  const _StepData(this.title, this.icon, this.content);
}

/// Main Flow Widget
class _SleepLogFlow extends StatefulWidget {
  const _SleepLogFlow({Key? key}) : super(key: key);

  @override
  State<_SleepLogFlow> createState() => _SleepLogFlowState();
}

class _SleepLogFlowState extends State<_SleepLogFlow> {
  late final PageController _controller;
  late final List<_StepData> _steps;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    _steps = [
      const _StepData('Sleep Times', Icons.timeline, SleepTimeSection()),
      const _StepData('Sleep Quality', Icons.star_border, QualitySection()),
      const _StepData('Mood & Stress', Icons.psychology, MoodStressSection()),
      const _StepData('Sleep Stages', Icons.waves, SleepStagesSection()),
      const _StepData('Efficiency', Icons.account_tree, SleepEfficiencySection()),
      const _StepData('Pre-Bed Habits', Icons.nightlight_round, InputSection()),
      _StepData(
        'Environment',
        Icons.rocket_launch,
        Column(
          children: const [
            EnvironmentSection(),
            SizedBox(height: 24),
            DisturbanceSection(),
          ],
        ),
      ),
      const _StepData('Dream Journal', Icons.drive_file_rename_outline, TextInputSection()),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saved = await SleepLogLocalStorage.loadPartial();
      if (saved != null) {
        context.read<SleepLog>().copyFrom(saved);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _steps.length - 1) {
      setState(() => _index++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      await SleepLogLocalStorage.clearPartial();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AILoadingAnalysisPage(
              sleepLog: context.read<SleepLog>(),
            ),
          ),
        );

      }
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, i) {
                  final step = _steps[i];
                  return StepWrapper(
                    title: step.title,
                    icon: step.icon,
                    child: step.content,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  if (_index > 0)
                    TextButton(onPressed: _back, child: const Text('Back')),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: active ? 24 : 8,
                          decoration: BoxDecoration(
                            color: active
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_index == _steps.length - 1 ? 'Analyze' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
