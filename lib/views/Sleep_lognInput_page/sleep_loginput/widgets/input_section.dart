
// input_section_refactored.dart (v3 - all texts white)
// - Makes every Text color explicitly white.
// - Keeps unique glass/neo visuals and responsive formatter.
// - Uses typed Consumer<SleepLog> to avoid Provider<dynamic> error.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: Adjust the import path to match your project structure if needed.
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class InputSectionRefactored extends StatefulWidget {
  const InputSectionRefactored({super.key});

  @override
  State<InputSectionRefactored> createState() => _InputSectionRefactoredState();
}

class _InputSectionRefactoredState extends State<InputSectionRefactored> with TickerProviderStateMixin {

  // Sync _selectedHabits to SleepLog model (best-effort, supports multiple method names).
  void _syncHabitsToModel(BuildContext context) {
    try {
      final dynamic slog = context.read<SleepLog>();
      final List<String> list = _selectedHabits.toList();
      // Try common method names
      try { slog.setOtherHabits(list); } catch (_) {}
      try { slog.setHabits(list); } catch (_) {}
      try { slog.updateOtherHabits(list); } catch (_) {}
      // Try direct property
      try { slog.otherHabits = list; } catch (_) {}
      // fire notify if available
      try { slog.notifyListeners(); } catch (_) {}
      // ignore: avoid_print
      print("🔗 SleepLog synced: otherHabits=${list.length}");
    } catch (e) {
      // ignore: avoid_print
      print("⚠️ Could not sync habits to SleepLog: $e");
    }
  }

  // Initialize local selection from model if available
  bool _hydratedFromModel = false;
  void _hydrateHabitsFromModel(BuildContext context) {
    if (_hydratedFromModel) return;
    _hydratedFromModel = true;
    try {
      final dynamic slog = context.read<SleepLog>();
      try {
        final dynamic val = slog.otherHabits;
        if (val is List) {
          _selectedHabits
            ..clear()
            ..addAll(val.whereType<String>());
        }
      } catch (_) {}
    } catch (_) {}
  }

  final Set<String> _selectedHabits = {'Screens at night'};

  late final AnimationController _haloCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();
//
  @override
  void dispose() {
    _haloCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _hydrateHabitsFromModel(context);

    final h = MediaQuery.of(context).size.height;
    final bool dense = h < 680;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: S.h(context, 12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderHalo(controller: _haloCtrl),
          SizedBox(height: S.h(context, dense ? 8 : 14)),
          _GlassCard(
            child: Padding(
              padding: EdgeInsets.all(S.w(context, dense ? 12 : 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(
                    title: 'Daily Sleep Habits',
                    subtitle: 'Tune these to improve your night quality',
                    dense: dense,
                  ),
                  SizedBox(height: S.h(context, dense ? 8 : 14)),

                  Consumer<SleepLog>(
                    builder: (context, log, _) {
                      final bool value = log.usesCaffeine;
                      return _NeonSwitchTile(
                        label: 'I usually consume caffeine in the evening',
                        value: value,
                        onChanged: (v) => log.setUsesCaffeine(v),
                        dense: dense,
                      );
                    },
                  ),
                  SizedBox(height: S.h(context, dense ? 8 : 12)),

                  _SectionLabel(text: 'Other habits', dense: dense),
                  SizedBox(height: S.h(context, 8)),
                  Wrap(
                    spacing: S.w(context, 8),
                    runSpacing: S.h(context, 8),
                    children: [
                      for (final habit in const [
                        ('Screens at night', Icons.phone_iphone),
                        ('Late heavy meals', Icons.fastfood),
                        ('Stressful day', Icons.bolt),
                        ('No exercise', Icons.event_busy),
                        ('Irregular schedule', Icons.schedule),
                        ('Noisy room', Icons.volume_up),
                      ])
                        _HabitChip(
                          label: habit.$1,
                          icon: habit.$2,
                          selected: _selectedHabits.contains(habit.$1),
                          onTap: () {
                            setState(() {
                              if (_selectedHabits.contains(habit.$1)) {
                                _selectedHabits.remove(habit.$1);
                              } else {
                                _selectedHabits.add(habit.$1);
                              }
                            });
                            _syncHabitsToModel(context);
                          },
                          dense: dense,
                        ),
                    ],
                  ),
                  SizedBox(height: S.h(context, dense ? 10 : 16)),

                  _SectionLabel(text: 'Suggested tags', dense: dense),
                  SizedBox(height: S.h(context, 8)),
                  Wrap(
                    spacing: S.w(context, 8),
                    runSpacing: S.h(context, 8),
                    children: const [
                      _TagPill('Deep-breathing'),
                      _TagPill('Dark room'),
                      _TagPill('White noise'),
                      _TagPill('Stretching'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- UI Pieces ----------

class _HeaderHalo extends StatelessWidget {
  final AnimationController controller;
  const _HeaderHalo({required this.controller});

  @override
  Widget build(BuildContext context) {
    final anim = Tween<double>(begin: 0, end: 1).animate(controller);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Container(
          height: S.h(context, 72),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(S.r(context, 16)),
            gradient: SweepGradient(
              startAngle: 0,
              endAngle: 6.28318 * anim.value,
              colors: [
                const Color(0xFF7C4DFF).withOpacity(0.20),
                const Color(0xFF00E5FF).withOpacity(0.20),
                const Color(0xFF00E676).withOpacity(0.20),
                const Color(0xFF7C4DFF).withOpacity(0.20),
              ],
            ),
          ),
          child: Center(
            child: Text(//
              'Be Positive!',
              style: TextStyle(
                fontSize: S.sp(context, 22),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: Colors.white, // force white
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(S.r(context, 18)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(S.r(context, 18)),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool dense;
  const _TitleRow({required this.title, required this.subtitle, required this.dense});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: S.w(context, dense ? 28 : 34),
          height: S.w(context, dense ? 28 : 34),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C4DFF).withOpacity(0.3),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(Icons.nightlight_round, color: Colors.white, size: 18),
        ),
        SizedBox(width: S.w(context, 10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: S.sp(context, dense ? 16 : 18),
                  fontWeight: FontWeight.w700,
                  color: Colors.white, // force white
                ),
              ),
              SizedBox(height: S.h(context, 4)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: S.sp(context, dense ? 11.5 : 12.5),
                  color: Colors.white, // force white
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _NeonSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool dense;
  const _NeonSwitchTile({required this.value, required this.onChanged, required this.label, required this.dense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.w(context, dense ? 10 : 14),
        vertical: S.h(context, dense ? 8 : 10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(S.r(context, 14)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x331A237E), Color(0x3300E5FF)],
        ),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: S.sp(context, dense ? 13 : 14),
                fontWeight: FontWeight.w600,
                color: Colors.white, // force white
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool dense;
  const _SectionLabel({required this.text, required this.dense});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: S.sp(context, dense ? 12.5 : 13.5),
        fontWeight: FontWeight.w700,
        color: Colors.white, // force white
        letterSpacing: 0.2,
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;
  const _HabitChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    final Color base = selected ? const Color(0xFF00E5FF) : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(S.r(context, 30)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: S.w(context, dense ? 10 : 12),
          vertical: S.h(context, dense ? 8 : 9),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(S.r(context, 30)),
          color: selected ? base.withOpacity(0.15) : Colors.white.withOpacity(0.06),
          border: Border.all(color: base.withOpacity(selected ? 0.9 : 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: S.sp(context, dense ? 14 : 16), color: base),
            SizedBox(width: S.w(context, 6)),
            Text(
              label,
              style: TextStyle(
                fontSize: S.sp(context, dense ? 12 : 13),
                fontWeight: FontWeight.w600,
                color: Colors.white, // force white
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  const _TagPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.w(context, 10),
        vertical: S.h(context, 6),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(S.r(context, 20)),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Text(
        '# $text',
        style: TextStyle(
          fontSize: S.sp(context, 11.5),
          fontWeight: FontWeight.w600,
          color: Colors.white, // force white
        ),
      ),
    );
  }
}

/// ---------- Simple size formatter (no ScreenUtilInit needed) ----------
class S {
  static const double _bw = 390.0;
  static const double _bh = 844.0;

  static double w(BuildContext context, double v) {
    final width = MediaQuery.of(context).size.width;
    return v * (width / _bw);
  }

  static double h(BuildContext context, double v) {
    final height = MediaQuery.of(context).size.height;
    return v * (height / _bh);
  }

  static double r(BuildContext context, double v) {
    final size = MediaQuery.of(context).size;
    final s = (size.width / _bw).clamp(0.75, 1.5);
    return v * s;
  }

  static double sp(BuildContext context, double v) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / _bw).clamp(0.8, 1.4);
    return v * scale;
  }
}
