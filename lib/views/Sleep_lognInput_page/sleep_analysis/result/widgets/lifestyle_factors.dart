
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets2/neo_design.dart'; // NeoBackground, NeoCard, neonA/B/C
import '../../models/sleeplog_model_page.dart';

/// LifestyleFactors
/// Refactored to share the *same design* as the Overview / SleepEnvironment sections:
/// - NeoBackground + NeoCard
/// - Gradient section title (neonA/B/C)
/// - Subtle glass tiles for each factor (border + faint gradient)
/// - No heavy holders / orbits / background painters
class LifestyleFactors extends StatelessWidget {
  final SleepLog? lastSleepLog;
  const LifestyleFactors({super.key, required this.lastSleepLog});

  // ------- helpers -------
  String _fmtValue(String title, SleepLog? log) {
    if (log == null) return '—';
    switch (title) {
      case 'Caffeine':
        final mg = (log.caffeineIntake ?? 0).toString();
        return '$mg mg';
      case 'Exercise':
        final m = (log.exerciseMinutes ?? 0).toString();
        return '$m mins';
      case 'Screen Time (pre‑bed)':
        final m = (log.screenTimeBeforeBed ?? 0).toString();
        return '$m mins';
      case 'Medications':
        if (log.medications != null && log.medications!.isNotEmpty) {
          return log.medications!;
        }
        return 'None';
      case 'Diet Notes':
        final s = log.dietNotes?.trim();
        return (s == null || s.isEmpty) ? '—' : s;
      case 'Disturbances':
        if (log.disturbances != null && log.disturbances!.isNotEmpty) {
          return log.disturbances!.join(', ');
        }
        return 'None';
    }
    return '—';
  }

  String _chipLabel(String title, SleepLog? log) {
    if (log == null) return '—';
    switch (title) {
      case 'Caffeine':
        final mg = (log.caffeineIntake ?? 0);
        if (mg >= 300) return 'High';
        if (mg >= 150) return 'Moderate';
        return 'Low';
      case 'Exercise':
        final m = (log.exerciseMinutes ?? 0);
        if (m >= 45) return 'Excellent';
        if (m >= 20) return 'Good';
        return 'Low';
      case 'Screen Time (pre‑bed)':
        final m = (log.screenTimeBeforeBed ?? 0);
        if (m >= 90) return 'High';
        if (m >= 30) return 'Moderate';
        return 'Low';
      case 'Medications':
        final has = log.medications != null && log.medications!.isNotEmpty;
        return has ? 'Present' : 'None';
      case 'Diet Notes':
        final s = log.dietNotes?.trim();
        return (s == null || s.isEmpty) ? '—' : 'Noted';
      case 'Disturbances':
        final has = log.disturbances != null && log.disturbances!.isNotEmpty;
        return has ? 'Present' : 'None';
    }
    return '—';
  }

  IconData _iconFor(String title) {
    switch (title) {
      case 'Caffeine': return Icons.local_cafe;
      case 'Exercise': return Icons.directions_run;
      case 'Screen Time (pre‑bed)': return Icons.smartphone;
      case 'Medications': return Icons.medication_outlined;
      case 'Diet Notes': return Icons.restaurant_menu;
      case 'Disturbances': return Icons.nightlight_round;
      default: return Icons.category_outlined;
    }
  }

  List<String> _factorTitles() => const [
    'Caffeine',
    'Exercise',
    'Screen Time (pre‑bed)',
    'Medications',
    'Diet Notes',
    'Disturbances',
  ];

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        SizedBox(width: 8.w),
        ShaderMask(
          shaderCallback: (rect) =>
              const LinearGradient(colors: [neonA, neonB, neonC]).createShader(rect),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white, // masked
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = _factorTitles();

    return NeoBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header to mirror Environment section
              NeoCard(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Lifestyle Factors', Icons.health_and_safety_outlined),
                    SizedBox(height: 12.h),
                    Text(
                      'Daily habits that can influence your sleep.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5.sp, height: 1.3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Factors grid inside NeoCard
              NeoCard(
                padding: EdgeInsets.all(12.r),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final cross = w >= 1200 ? 4 : (w >= 900 ? 3 : 2);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.20,
                      ),
                      itemCount: titles.length,
                      itemBuilder: (context, i) {
                        final t = titles[i];
                        return _LifestyleTile(
                          title: t,
                          value: _fmtValue(t, lastSleepLog),
                          chip: _chipLabel(t, lastSleepLog),
                          icon: _iconFor(t),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile style aligned with Environment factor tiles
class _LifestyleTile extends StatelessWidget {
  final String title;
  final String value;
  final String chip;
  final IconData icon;

  const _LifestyleTile({
    required this.title,
    required this.value,
    required this.chip,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.03),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.white38, size: 16),
              ],
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(color: Colors.white70, fontSize: 11.5.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
