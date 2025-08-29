
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets2/neo_design.dart'; // NeoBackground, NeoCard, neonA/B/C

/// SleepMetrics
/// Refactored to share the *same* visual language as SleepEnvironmentAnalysis:
/// - Uses NeoBackground + NeoCard wrappers
/// - Gradient section titles via ShaderMask (neonA/B/C)
/// - Subtle glassy tiles (border + faint gradient) identical to Environment factors
/// - Consistent paddings, radii, and typography
class SleepMetrics extends StatelessWidget {
  final Map<String, dynamic> sleepMetrics;
  const SleepMetrics({super.key, required this.sleepMetrics});

  // ---------- Helpers ----------
  double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  String _fmt(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

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
    // Canonical metrics list (keys unchanged)
    final metrics = [
      {
        'key': 'avg_duration',
        'title': 'Sleep Duration',
        'value': _toDouble(sleepMetrics['avg_duration'], fallback: 7.2),
        'unit': 'h',
        'icon': Icons.timer_outlined,
        'max': 10.0,
      },
      {
        'key': 'efficiency',
        'title': 'Efficiency',
        'value': _toDouble(sleepMetrics['efficiency'], fallback: 85),
        'unit': '%',
        'icon': Icons.speed_outlined,
        'max': 100.0,
      },
      {
        'key': 'sleep_quality_score',
        'title': 'Quality',
        'value': _toDouble(sleepMetrics['sleep_quality_score'], fallback: 7.8),
        'unit': '/10',
        'icon': Icons.star_rate_outlined,
        'max': 10.0,
      },
      {
        'key': 'sleep_consistency',
        'title': 'Consistency',
        'value': _toDouble(sleepMetrics['sleep_consistency'], fallback: 78),
        'unit': '%',
        'icon': Icons.sync_lock_outlined,
        'max': 100.0,
      },
      {
        'key': 'deep_sleep',
        'title': 'Deep Sleep',
        'value': _toDouble(sleepMetrics['deep_sleep'], fallback: 18),
        'unit': '%',
        'icon': Icons.nightlight_round,
        'max': 100.0,
      },
      {
        'key': 'rem_sleep',
        'title': 'REM Sleep',
        'value': _toDouble(sleepMetrics['rem_sleep'], fallback: 22),
        'unit': '%',
        'icon': Icons.visibility_outlined,
        'max': 100.0,
      },
      {
        'key': 'awakenings',
        'title': 'Awakenings',
        'value': _toDouble(sleepMetrics['awakenings'], fallback: 2),
        'unit': 'x',
        'icon': Icons.notifications_active_outlined,
        'max': 10.0,
      },
      {
        'key': 'sleep_onset_latency',
        'title': 'Sleep Latency',
        'value': _toDouble(sleepMetrics['sleep_onset_latency'], fallback: 15),
        'unit': 'min',
        'icon': Icons.hourglass_bottom_outlined,
        'max': 120.0,
      },
      {
        'key': 'time_in_bed',
        'title': 'Time in Bed',
        'value': _toDouble(sleepMetrics['time_in_bed'], fallback: 8.0),
        'unit': 'h',
        'icon': Icons.bed_outlined,
        'max': 12.0,
      },
      {
        'key': 'wake_after_sleep_onset',
        'title': 'WASO',
        'value': _toDouble(sleepMetrics['wake_after_sleep_onset'], fallback: 20),
        'unit': 'min',
        'icon': Icons.alarm_off_outlined,
        'max': 120.0,
      },
      {
        'key': 'heart_rate_avg',
        'title': 'Avg HR',
        'value': _toDouble(sleepMetrics['heart_rate_avg'], fallback: 62),
        'unit': 'bpm',
        'icon': Icons.favorite_outline,
        'max': 120.0,
      },
      {
        'key': 'hrv',
        'title': 'HRV',
        'value': _toDouble(sleepMetrics['hrv'], fallback: 42),
        'unit': 'ms',
        'icon': Icons.auto_graph_outlined,
        'max': 200.0,
      },
      {
        'key': 'respiratory_rate',
        'title': 'Resp. Rate',
        'value': _toDouble(sleepMetrics['respiratory_rate'], fallback: 13.0),
        'unit': 'rpm',
        'icon': Icons.air_outlined,
        'max': 30.0,
      },
    ];

    return NeoBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card to match Environment Analysis
              NeoCard(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Sleep Metrics', Icons.analytics_outlined),
                    SizedBox(height: 12.h),
                    Text(
                      'Core nightly indicators measured by your Sleep AI.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5.sp, height: 1.3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Grid wrapped in a NeoCard to match section framing
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
                        childAspectRatio: 1.15,
                      ),
                      itemCount: metrics.length,
                      itemBuilder: (context, i) {
                        final m = metrics[i];
                        return _MetricTileNeo(
                          title: m['title'] as String,
                          value: (m['value'] as double).clamp(0, (m['max'] as double)),
                          unit: m['unit'] as String,
                          icon: m['icon'] as IconData,
                          max: m['max'] as double,
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

/// Individual metric tile styled like Environment factor tiles:
/// - Subtle gradient surface + white12 border + 16 radius
/// - Row title with icon and kebab (more_horiz) to match
/// - Arc gauge painter identical parameters to Environment
class _MetricTileNeo extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final double max;

  const _MetricTileNeo({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: ${value.toStringAsFixed(1)} $unit',
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
              child: Row(
                children: [
                  // Gauge
                  SizedBox(
                    width: 64.w,
                    height: 64.w,
                    child: CustomPaint(
                      painter: _CircularArcGaugeMetrics(
                        value: value,
                        max: max,
                        start: 150, // degrees
                        sweep: 240, // degrees
                        trackColor: Colors.white10,
                        gradient: const SweepGradient(colors: [neonA, neonB, neonC]),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Value & unit
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: ' $unit',
                                style: TextStyle(color: Colors.white70, fontSize: 12.5.sp),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Simple qualitative chip
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            _qualitativeLabel(value, max),
                            style: TextStyle(color: Colors.white70, fontSize: 11.5.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _qualitativeLabel(double value, double max) {
    final p = (value / max) * 100.0;
    if (p >= 80) return 'Excellent';
    if (p >= 60) return 'Good';
    if (p >= 40) return 'Fair';
    return 'Low';
  }
}

/// Gauge painter aligned with SleepEnvironmentAnalysis
class _CircularArcGaugeMetrics extends CustomPainter {
  final double value;
  final double max;
  final double start; // degrees
  final double sweep; // degrees
  final Color trackColor;
  final SweepGradient gradient;

  _CircularArcGaugeMetrics({
    required this.value,
    required this.max,
    required this.start,
    required this.sweep,
    required this.trackColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 2;

    final startR = start * pi / 180.0;
    final sweepR = sweep * pi / 180.0;

    // Track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = trackColor;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startR, sweepR, false, track);

    // Progress
    final p = (value / max).clamp(0.0, 1.0);
    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startR, sweepR * p, false, prog);
  }

  @override
  bool shouldRepaint(covariant _CircularArcGaugeMetrics oldDelegate) {
    return oldDelegate.value != value || oldDelegate.max != max;
  }
}
