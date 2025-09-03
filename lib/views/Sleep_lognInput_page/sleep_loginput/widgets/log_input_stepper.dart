import 'package:flutter/material.dart';
import 'step_wrapper.dart';

/// Model for a single step in the log input flow.
class LogInputStep {
  final String title;
  final IconData icon;
  final WidgetBuilder builder;

  const LogInputStep({
    required this.title,
    required this.icon,
    required this.builder,
  });
}

/// Reusable stepper widget that drives the multi-step input flow.
class LogInputStepper extends StatefulWidget {
  final List<LogInputStep> steps;
  final Future<void> Function()? onFinish;

  const LogInputStepper({
    super.key,
    required this.steps,
    this.onFinish,
  });

  @override
  State<LogInputStepper> createState() => _LogInputStepperState();
}

class _LogInputStepperState extends State<LogInputStepper> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      await widget.onFinish?.call();
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
    final colors = Theme.of(context).colorScheme;
    final progress = (_index + 1) / widget.steps.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: colors.surfaceVariant,
              color: colors.primary,
              minHeight: 6,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.steps.length,
            itemBuilder: (context, i) {
              final step = widget.steps[i];
              return StepWrapper(
                title: step.title,
                icon: step.icon,
                child: step.builder(context),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              if (_index > 0)
                OutlinedButton.icon(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              if (_index > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_index == widget.steps.length - 1 ? 'Analyze' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
