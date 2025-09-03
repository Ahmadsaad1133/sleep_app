// sleep_time_section.dart
import 'dart:ui';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/step_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../constants/fonts.dart';
import '../../../../utils/time_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';
import 'section_title.dart';
import 'mini_sleep_trend_chart.dart';

class SleepTimeSection extends StatelessWidget {
  const SleepTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _SleepTimeListLayout();
  }
}

// Updated layout: vertical list instead of grid
class _SleepTimeListLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth < 500 ? 12.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MiniSleepTrendChart(),
        SizedBox(height: spacing),
        SleepTimeCard(type: 'Bedtime'),
        SizedBox(height: spacing),
        SleepTimeCard(type: 'Wake Up'),
      ],
    );
  }
}

class SleepTimeCard extends StatefulWidget {
  final String type;

  const SleepTimeCard({super.key, required this.type});

  @override
  State<SleepTimeCard> createState() => _SleepTimeCardState();
}

class _SleepTimeCardState extends State<SleepTimeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isActive = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _isActive = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    _pickTime(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isActive = false);
    });
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isActive = false);
  }

  Color _accentColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return widget.type == 'Bedtime' ? scheme.primary : scheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SleepLog, String>(
      selector: (_, model) =>
      widget.type == 'Bedtime' ? model.bedtime : model.wakeTime,
      builder: (_, timeStr, __) {
        final time = parseTimeString(timeStr);
        final accent = _accentColor(context);
        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                          accent.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blueGrey[900]!.withOpacity(0.7),
                          Colors.blueGrey[800]!.withOpacity(0.4),
                        ],
                      ),
                      border: Border.all(
                        color: accent.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Cosmic background animation
                        Center(
                          child: Lottie.asset(
                            'assets/animations/cosmic_back.json',
                            fit: BoxFit.contain,
                            width: 200,
                            height: 200,
                          ),
                        ),
                        // Holographic glow
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  accent.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.type == 'Bedtime'
                                      ? Icons.nightlight_round
                                      : Icons.wb_sunny,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                AutoSizeText(
                                  widget.type.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: AppFonts.ComfortaaBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 12,
                                  maxFontSize: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AutoSizeText(
                              'SET TIME',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontFamily: AppFonts.ComfortaaLight,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                              maxFontSize: 12,
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.vertical,
                                    child: child,
                                  ),
                                );
                              },
                              child: AutoSizeText(
                                formatTimeOfDay(time),
                                key: ValueKey(time),
                                style: TextStyle(
                                  fontFamily: AppFonts.ComfortaaLight,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                minFontSize: 20,
                                maxFontSize: 36,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.keyboard),
                            color: Colors.white,
                            onPressed: () => _promptTimeInput(context),
                          ),
                        ),
                        if (_isActive)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  Future<void> _promptTimeInput(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Enter ${widget.type}'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., 10 pm',
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () async {
                  if (await _speech.initialize()) {
                    _speech.listen(onResult: (r) {
                      controller.text = r.recognizedWords;
                    });
                  }
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _speech.stop();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _speech.stop();
                final t = parseTimeString(controller.text);
                final formatted = formatTimeOfDay(t);
                final log = ctx.read<SleepLog>();
                if (widget.type == 'Bedtime') {
                  log.setBedtime(formatted);
                } else {
                  log.setWakeTime(formatted);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _pickTime(BuildContext context) async {
    final model = context.read<SleepLog>();
    final currentTimeStr =
    widget.type == 'Bedtime' ? model.bedtime : model.wakeTime;
    final initialTime = parseTimeString(currentTimeStr);
    final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
    final accent = _accentColor(context);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: accent,
            onPrimary: Colors.white,
            surface: const Color(0xFF0D1B2A),
            onSurface: Colors.white,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: accent, width: 1.0),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: const Color(0xFF0D1B2A),
            hourMinuteTextColor: Colors.white,
            dayPeriodTextColor: Colors.white,
            hourMinuteColor: MaterialStateColor.resolveWith((states) {
              return states.contains(MaterialState.selected)
                  ? accent.withOpacity(0.2)
                  : Colors.transparent;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: accent, width: 1.0),
            ),
            dialBackgroundColor: const Color(0xFF1E293B),
            dialHandColor: accent,
            entryModeIconColor: Colors.white,
            hourMinuteTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.ComfortaaLight,
              color: Colors.white,
            ),
            dayPeriodTextStyle: TextStyle(
              fontFamily: AppFonts.ComfortaaLight,
              color: Colors.white,
            ),
            helpTextStyle: TextStyle(
              fontFamily: AppFonts.ComfortaaBold,
              color: Colors.white,
            ),
          ),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: use24Hour,
          ),
          child: child!,
        ),
      ),
    );

    if (pickedTime != null && context.mounted) {
      final formatted =
          '${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}';
      if (widget.type == 'Bedtime') {
        model.setBedtime(formatted);
      } else {
        model.setWakeTime(formatted);
      }
    }
  }
}

// Validation mixin
mixin SleepTimeValidator on SleepLog {
  String? validateSleepTimes() {
    if (bedtime.isEmpty) return 'Please set your bedtime';
    if (wakeTime.isEmpty) return 'Please set your wake time';

    final bed = parseTimeString(bedtime);
    final wake = parseTimeString(wakeTime);

    // Overnight sleep allowed (bedtime after midnight)
    if (bed.hour > wake.hour) return null;

    // Same day: wake must be after bedtime
    if (bed.hour == wake.hour && bed.minute >= wake.minute) {
      return 'Wake time must be after bedtime';
    }

    return null;
  }
}
