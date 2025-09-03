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
      _goTo(_index + 1);
    } else {
      await widget.onFinish?.call();
    }
  }

  void _back() {
    if (_index > 0) {
      _goTo(_index - 1);
    }
  }
  void _goTo(int index) {
    setState(() => _index = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = (_index + 1) / widget.steps.length;

    return Column(
      children: [
        _ProgressBar(progress: progress, colors: colors),
        _StepIndicator(
          steps: widget.steps,
          index: _index,
          onTap: _goTo,
          colors: colors,
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
        _NavigationBar(
          index: _index,
          total: widget.steps.length,
          onBack: _back,
          onNext: _next,
          colors: colors,
        ),
      ],
    );
  }
}

/// Progress bar with animated gradient fill.
class _ProgressBar extends StatelessWidget {
  final double progress;
  final ColorScheme colors;

  const _ProgressBar({
    required this.progress,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(
    height: 6,
    child: Stack(
            children: [
    Container(color: colors.surfaceVariant),
    AnimatedFractionallySizedBox(
    widthFactor: progress,
    duration: const Duration(milliseconds: 300),
    alignment: Alignment.centerLeft,
    child: DecoratedBox(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [colors.primary, colors.secondary],
    ),
                  ),

                ),
              ),
            ],
          ),
        ),
    ),
    );
  }
}

/// Horizontal list of steps that acts as an indicator and navigator.
class _StepIndicator extends StatelessWidget {
  final List<LogInputStep> steps;
  final int index;
  final ValueChanged<int> onTap;
  final ColorScheme colors;

  const _StepIndicator({
    required this.steps,
    required this.index,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: i == index
                        ? colors.primaryContainer
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        steps[i].icon,
                        size: 18,
                        color: i == index
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        steps[i].title,
                        style: TextStyle(
                          fontSize: 12,
                          color: i == index
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom navigation bar that provides Back and Next/Analyze actions.
class _NavigationBar extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback onBack;
  final Future<void> Function() onNext;
  final ColorScheme colors;

  const _NavigationBar({
    required this.index,
    required this.total,
    required this.onBack,
    required this.onNext,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          if (index > 0)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          if (index > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  index == total - 1 ? 'Analyze' : 'Next',
                  key: ValueKey(index == total - 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
