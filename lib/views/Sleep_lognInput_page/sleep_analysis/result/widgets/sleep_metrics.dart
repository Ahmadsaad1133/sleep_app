import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// -----------------------------------------------------------------------------
// Global UI constants for SleepMetrics
//
// We reuse the same colour palette defined in other UI files to ensure
// consistency across the app.  These constants define backgrounds,
// card surfaces and accent gradients inspired by holographic and
// aurora‑like visual motifs.
const Color kBackgroundStart = Color(0xFF071B2C);
const Color kBackgroundEnd   = Color(0xFF101E3C);
const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [kBackgroundStart, kBackgroundEnd],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const LinearGradient kCardGradient = LinearGradient(
  colors: [Color(0xFF0E1B40), Color(0xFF172452)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient kAccentGradient = LinearGradient(
  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Optimized SleepMetrics widget.
/// Key changes for performance:
/// - Removed parent setState driven by animation ticks.
/// - CustomPainters use `repaint` (Listenable) so only they repaint.
/// - Each MetricCard listens to the shared Animation instead of forcing whole tree rebuilds.
/// - RepaintBoundary added around animated sections to isolate repaints.
/// - Particle count and heavy shadows are configurable and can be reduced if needed.
class SleepMetrics extends StatefulWidget {
  final Map<String, dynamic> sleepMetrics;

  const SleepMetrics({Key? key, required this.sleepMetrics}) : super(key: key);

  @override
  State<SleepMetrics> createState() => _SleepMetricsState();
}

class _SleepMetricsState extends State<SleepMetrics>
    with SingleTickerProviderStateMixin {
  late final AnimationController _masterController;
  final List<_Particle> _particles = [];
  final int _particleCount = 28; // reduce if still lagging

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Initialize particles once (cheap one-time work)
    final rnd = Random(42);
    for (var i = 0; i < _particleCount; i++) {
      _particles.add(
        _Particle(
          offset: Offset(rnd.nextDouble(), rnd.nextDouble()),
          radius: rnd.nextDouble() * 2.6 + 0.8,
          speed: rnd.nextDouble() * 0.6 + 0.15,
          alpha: (rnd.nextDouble() * 0.6 + 0.15),
          orbit: rnd.nextDouble() * 0.6 + 0.2,
        ),
      );
    }

    // IMPORTANT: do NOT call setState on each tick. CustomPainters and
    // AnimatedBuilders will listen to the controller directly (repaint).
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    final n = double.tryParse(v.toString());
    return n ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {
        'key': 'avg_duration',
        'title': 'Sleep Duration',
        'value': _toDouble(widget.sleepMetrics['avg_duration'], fallback: 7.2),
        'unit': 'hrs',
        'icon': Icons.timer,
        'gradient': const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      },
      {
        'key': 'efficiency',
        'title': 'Efficiency',
        'value': _toDouble(widget.sleepMetrics['efficiency'], fallback: 85),
        'unit': '%',
        'icon': Icons.bar_chart,
        'gradient': const LinearGradient(
          colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        ),
      },
      {
        'key': 'latency',
        'title': 'Latency',
        'value': _toDouble(widget.sleepMetrics['latency'], fallback: 15),
        'unit': 'min',
        'icon': Icons.hourglass_bottom,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF7EB3), Color(0xFFFF758C)],
        ),
      },
      {
        'key': 'waso',
        'title': 'Awakenings',
        'value': _toDouble(widget.sleepMetrics['waso'], fallback: 20),
        'unit': 'min',
        'icon': Icons.nightlight_round,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFFA62E), Color(0xFFFFD166)],
        ),
      },
      {
        'key': 'consistency',
        'title': 'Consistency',
        'value': _toDouble(widget.sleepMetrics['consistency'], fallback: 75),
        'unit': '%',
        'icon': Icons.calendar_today,
        'gradient': const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
        ),
      },
      {
        'key': 'restoration_index',
        'title': 'Restoration',
        'value': _toDouble(widget.sleepMetrics['restoration_index'], fallback: 80),
        'unit': '/100',
        'icon': Icons.health_and_safety,
        'gradient': const LinearGradient(
          colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
        ),
      },
    ];

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Ambient particle field (isolated repaint)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _ParticlePainter(_particles, _masterController),
              ),
            ),
          ),

          // Frosted glass base
          Center(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.6),
                gradient: kCardGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 22.r,
                    offset: Offset(0, 8.h),
                  ),
                  BoxShadow(
                    color: Color(0xFF2575FC).withOpacity(0.05),
                    blurRadius: 32.r,
                    spreadRadius: 4.r,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              ),
                            ),
                            child: Icon(Icons.analytics, color: Colors.white, size: 26.sp),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SLEEP CONSTELLATION',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Personal metrics · AI-curated · 2050 UI',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () => _showDetailsSheet(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(Icons.info_outline, color: Colors.white70, size: 20.sp),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 18.h),

                      // Metrics grid
                      LayoutBuilder(builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxis = width > 780 ? 3 : 2;

                        return GridView.builder(
                          itemCount: metrics.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxis,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.05,
                          ),
                          itemBuilder: (context, index) {
                            final m = metrics[index];
                            return _MetricCard(
                              title: m['title'] as String,
                              value: m['value'] as double,
                              unit: m['unit'] as String,
                              icon: m['icon'] as IconData,
                              gradient: m['gradient'] as Gradient,
                              masterAnimation: _masterController,
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.36,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (context, ctrl) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                border: Border.all(color: Colors.white12),
              ),
              padding: EdgeInsets.all(18.w),
              child: ListView(
                controller: ctrl,
                children: [
                  Center(
                    child: Container(
                      width: 60.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('Sleep Insights & Guidance',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 12.h),
                  Text(
                    'This panel contains deeper AI-driven insights, recommended sleep windows and micro-actions to improve your metrics. Tap any metric for history and trends.',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 18.h),

                  for (var i = 0; i < 4; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.bolt, color: Colors.white, size: 18.sp),
                      ),
                      title: Text('Suggestion ${i + 1}', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Micro-habit to try tonight', style: TextStyle(color: Colors.white60)),
                      trailing: Icon(Icons.chevron_right, color: Colors.white30),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// -------------------- Metric Card Widget --------------------
class _MetricCard extends StatefulWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final Gradient gradient;
  final Animation<double> masterAnimation;

  const _MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    required this.masterAnimation,
  }) : super(key: key);

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  double _normalizedProgress() {
    if (widget.unit.contains('%')) return (widget.value.clamp(0, 100)) / 100.0;
    if (widget.unit.contains('hrs')) return (widget.value / 9.0).clamp(0.0, 1.0);
    if (widget.unit.contains('min')) return (widget.value / 60.0).clamp(0.0, 1.0);
    if (widget.unit.contains('/100')) return (widget.value / 100.0).clamp(0.0, 1.0);
    return (widget.value / 100.0).clamp(0.0, 1.0);
  }

  String _displayValue(double v, String unit) {
    if (unit.contains('%')) return v.toStringAsFixed(0);
    if (unit.contains('hrs')) return v.toStringAsFixed(1);
    if (unit.contains('min')) return v.toStringAsFixed(0);
    if (unit.contains('/100')) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  void _showMetricDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.6),
        title: Text(widget.title),
        content: Text('Metric value: ${_displayValue(widget.value, widget.unit)}${widget.unit}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _normalizedProgress();

    return RepaintBoundary(
      child: Semantics(
        label: '${widget.title}: ${widget.value}${widget.unit}',
        child: GestureDetector(
          onTapDown: (_) => _hoverController.forward(),
          onTapUp: (_) => _hoverController.reverse(),
          onTapCancel: () => _hoverController.reverse(),
          onTap: () => _showMetricDetails(context),
          child: AnimatedBuilder(
            animation: Listenable.merge([_hoverController]),
            builder: (context, _) {
              final scale = 1.0 + (_hoverController.value * 0.02);
              final elevation = 6 + (_hoverController.value * 8);

              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: widget.gradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: elevation,
                        offset: Offset(0, elevation / 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.06,
                          child: IgnorePointer(
                            child: Transform.rotate(
                              angle: (widget.masterAnimation.value * 2 * pi * 0.04) + progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white10, Colors.white12],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Radial gauge (repaints only via masterAnimation)
                                SizedBox(
                                  width: 68.r,
                                  height: 68.r,
                                  child: CustomPaint(
                                    painter: _RadialGaugePainter(
                                      progress: progress,
                                      animation: widget.masterAnimation,
                                    ),
                                    // child center avatar is static; does not cause repaints
                                    child: Center(
                                      child: CircleAvatar(
                                        radius: 18.r,
                                        backgroundColor: Colors.white10,
                                        child: Icon(widget.icon, size: 18.sp, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.title,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          )),
                                      SizedBox(height: 6.h),
                                      Shimmer(
                                        duration: const Duration(seconds: 2),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${_displayValue(widget.value, widget.unit)} ',
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w900,
                                                  fontFamily: 'NunitoSansBold',
                                                ),
                                              ),
                                              TextSpan(
                                                text: widget.unit,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white70,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                            SizedBox(height: 10.h),

                            // Sparkline (repaints only via masterAnimation)
                            SizedBox(
                              width: double.infinity,
                              height: 24.h,
                              child: CustomPaint(
                                painter: _SparklinePainter(widget.masterAnimation),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// -------------------- Painters & Particles --------------------
class _RadialGaugePainter extends CustomPainter {
  final double progress; // 0..1
  final Animation<double> animation; // used for glow + subtle motion

  _RadialGaugePainter({required this.progress, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.white12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, base);

    final prog = progress.clamp(0.0, 1.0);
    final sweep = 2 * pi * prog;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final progPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweep,
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, (0.55 + (t * 0.45)) * 6);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, progPaint);

    final end = Offset(center.dx + radius * cos(-pi / 2 + sweep), center.dy + radius * sin(-pi / 2 + sweep));
    final glowPaint = Paint()..color = Colors.white.withOpacity(0.06 + t * 0.25);
    canvas.drawCircle(end, 4 + (t * 4), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.animation != animation;
}

class _SparklinePainter extends CustomPainter {
  final Animation<double> animation;

  _SparklinePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.85);

    final path = Path();
    final rnd = Random(12345);
    final points = List.generate(12, (i) {
      final x = (i / 11) * size.width;
      final base = sin((t * 2 * pi) + i * 0.6) * (size.height * 0.28);
      final jitter = (rnd.nextDouble() - 0.5) * (size.height * 0.12);
      final y = (size.height / 2) - base + jitter;
      return Offset(x, y.clamp(0.0, size.height));
    });

    for (var i = 0; i < points.length; i++) {
      if (i == 0) path.moveTo(points[i].dx, points[i].dy);
      else path.lineTo(points[i].dx, points[i].dy);
    }

    paint.shader = LinearGradient(colors: [Colors.white70, Colors.white30]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.animation != animation;
}

class _Particle {
  final Offset offset; // normalized 0..1
  final double radius;
  final double speed;
  final double alpha;
  final double orbit;

  _Particle({required this.offset, required this.radius, required this.speed, required this.alpha, required this.orbit});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Animation<double> animation;

  _ParticlePainter(this.particles, this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final center = size.center(Offset.zero);
    final minSide = min(size.width, size.height);

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final angle = (t * 2 * pi * p.speed) + (i * 0.73);
      final orbitRadius = (minSide * 0.36) * p.orbit;
      final dx = center.dx + (orbitRadius * cos(angle + p.offset.dx * 2 * pi));
      final dy = center.dy + (orbitRadius * sin(angle + p.offset.dy * 2 * pi));
      final r = p.radius;

      final paint = Paint()..color = Colors.white.withOpacity(p.alpha * 0.14);
      canvas.drawCircle(Offset(dx, dy), r, paint);

      final halo = Paint()..color = Colors.white.withOpacity(p.alpha * 0.04);
      canvas.drawCircle(Offset(dx, dy), r * 3, halo);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.animation != animation || oldDelegate.particles != particles;
}
