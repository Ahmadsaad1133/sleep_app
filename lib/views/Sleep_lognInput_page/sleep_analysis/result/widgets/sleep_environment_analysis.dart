import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/colors.dart';

// -----------------------------------------------------------------------------
// Global UI constants for sleep environment analysis
//
// These values mirror those used across the other widgets.  Defining them
// locally ensures the sleep environment analysis blends seamlessly with the
// unified 2025 aesthetic.  The colours evoke a deep‑space ambience and
// holographic edges found elsewhere in the app.
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

class SleepEnvironmentAnalysis extends StatefulWidget {
  final Map<String, dynamic> environmentAnalysis;

  const SleepEnvironmentAnalysis({
    super.key,
    required this.environmentAnalysis,
  });

  @override
  State<SleepEnvironmentAnalysis> createState() =>
      _SleepEnvironmentAnalysisState();
}

// <-- Changed mixin to TickerProviderStateMixin to support multiple controllers
class _SleepEnvironmentAnalysisState extends State<SleepEnvironmentAnalysis>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  @override
  void initState() {
    super.initState();

    // Orbiting controller (repeats)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    // Appear controller (one-time)
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  String _getFactorValue(Map<String, dynamic> factors, String key) {
    final value = factors[key];
    if (value == null) return 'N/A';
    if (value is String) return value;
    return value.toString();
  }

  List<String> _getRecommendations(Map<String, dynamic>? recsMap, String key) {
    if (recsMap == null) return [];
    final recs = recsMap[key];
    if (recs is List) return recs.cast<String>();
    if (recs is String) return [recs];
    return [];
  }

  Color _getRatingColor(String rating) {
    final lower = rating.toLowerCase();
    if (lower.contains('excellent') ||
        lower.contains('optimal') ||
        lower.contains('quiet') ||
        lower.contains('dark') ||
        lower.contains('comfortable') ||
        lower.contains('ideal')) {
      return AppColors.positiveGreen;
    }
    if (lower.contains('moderate') ||
        lower.contains('average') ||
        lower.contains('acceptable') ||
        lower.contains('neutral') ||
        lower.contains('adequate')) {
      return AppColors.warningOrange;
    }
    if (lower.contains('poor') ||
        lower.contains('noisy') ||
        lower.contains('bright') ||
        lower.contains('uncomfortable') ||
        lower.contains('hot') ||
        lower.contains('cold')) {
      return AppColors.negativeRed;
    }
    return Colors.white;
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return AppColors.positiveGreen;
    if (score >= 5) return AppColors.warningOrange;
    return AppColors.negativeRed;
  }

  String _getScoreDescription(double score) {
    if (score >= 8) return 'Perfect cosmic sleep environment';
    if (score >= 5) return 'Good environment with room for improvement';
    return 'Needs significant improvements';
  }

  void _showRecommendationsSheet(String title, List<String> recs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.36,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: SafeArea(
                  top: false,
                  child: Container(
                    color: Colors.black.withOpacity(0.45),
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$title — Recommendations',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: ListView.separated(
                            controller: controller,
                            itemCount: recs.isNotEmpty ? recs.length : 1,
                            separatorBuilder: (_, __) => Divider(color: Colors.white12),
                            itemBuilder: (context, index) {
                              if (recs.isEmpty) {
                                return ListTile(
                                  leading: Icon(Icons.info_outline, color: Colors.white70),
                                  title: Text('No specific recommendations',
                                      style: TextStyle(color: Colors.white70)),
                                );
                              }
                              final rec = recs[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: Colors.white12,
                                  child: Icon(Icons.lightbulb_outline, color: Colors.white),
                                ),
                                title: Text(
                                  rec,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.04),
                Colors.white.withOpacity(0.02)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24.r,
                offset: Offset(0, 6.h),
              ),
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.06),
                blurRadius: 40.r,
                spreadRadius: 4.r,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildOrbitingScoreSection(double score, {double? height}) {
    final percentage = (score / 10).clamp(0.0, 1.0);
    final color = _getScoreColor(score);

    return SizedBox(
      // If no height is passed, let it size naturally to content
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // subtle nebula
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.2, -0.5),
                    radius: 1.2,
                    colors: [
                      color.withOpacity(0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),
          ),

          // orbiting particles layers
          ...List.generate(4, (i) {
            final baseRadius = 72.w + i * 14.w;
            final size = 10.w + i * 3.w;
            final planetColor = [
              Colors.amber,
              Colors.cyan,
              Colors.purple,
              Colors.green
            ][i % 4];
            return AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                final angle = 2 *
                    pi *
                    (_orbitController.value * (1 + i * 0.18)) +
                    (i * pi / 4);
                final x = baseRadius * cos(angle);
                final y = (baseRadius * 0.6) * sin(angle);
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: planetColor,
                      boxShadow: [
                        BoxShadow(
                          color: planetColor.withOpacity(0.9),
                          blurRadius: 14.r,
                          spreadRadius: 1.r,
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // central glass score card
          FadeTransition(
            opacity: _appearAnim,
            child: _buildGlassCard(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Shimmer(
                    duration: const Duration(seconds: 3),
                    child: Text(
                      'ENVIRONMENT QUALITY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'NunitoSansBold',
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120.w,
                            height: 120.h,
                            child: CustomPaint(
                                painter: _NeonRingPainter(color, percentage)),
                          ),
                          Column(
                            children: [
                              Shimmer(
                                duration: const Duration(seconds: 3),
                                child: Text(
                                  score.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'NunitoSansBold',
                                    fontSize: 34.sp,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 18.r,
                                        color: color.withOpacity(0.45),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                '/10',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Shimmer(
                    duration: const Duration(seconds: 3),
                    child: Text(
                      _getScoreDescription(score),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Safely extract general recommendations if present
                          final recsMap =
                          widget.environmentAnalysis['recommendations'];
                          List<String> generalRecs = [];
                          if (recsMap is Map && recsMap['general'] != null) {
                            final g = recsMap['general'];
                            if (g is List) generalRecs = g.cast<String>();
                            if (g is String) generalRecs = [g];
                          }
                          _showRecommendationsSheet('Environment', generalRecs);
                        },
                        icon: Icon(Icons.rule, size: 18.sp),
                        label: const Text('View Tips'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          textStyle: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      OutlinedButton.icon(
                        onPressed: () {
                          final bottomPadding =
                              MediaQuery.of(context).viewInsets.bottom +
                                  MediaQuery.of(context).viewPadding.bottom;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Applied quick optimization presets'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.fromLTRB(
                                  16, 0, 16, bottomPadding + 16),
                            ),
                          );
                        },
                        icon: Icon(Icons.flash_on_outlined,
                            color: Colors.white70, size: 18.sp),
                        label: const Text('Quick Optimize',
                            style: TextStyle(color: Colors.white70)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetFactor({
    required String title,
    required String value,
    required IconData icon,
    required List<String> recommendations,
    required Gradient gradient,
  }) {
    final color = _getRatingColor(value);

    return Semantics(
      label: '$title factor: $value',
      child: GestureDetector(
        onTap: () {
          _showRecommendationsSheet(title, recommendations);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 96.w,
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 76.w,
                      height: 76.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first.withOpacity(0.32),
                            blurRadius: 18.r,
                            spreadRadius: 6.r,
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Icon(icon, size: 22.sp, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final factors =
        widget.environmentAnalysis['factors'] as Map<String, dynamic>? ?? {};
    final recommendations =
        widget.environmentAnalysis['recommendations'] as Map<String, dynamic>? ?? {};
    final score = widget.environmentAnalysis['score'] is int
        ? (widget.environmentAnalysis['score'] as int).toDouble()
        : widget.environmentAnalysis['score'] as double? ?? 0.0;
    final insights =
        widget.environmentAnalysis['insights'] as String? ?? 'No insights available';

    final noiseLevel = _getFactorValue(factors, 'noise_level');
    final lightExposure = _getFactorValue(factors, 'light_exposure');
    final temperature = _getFactorValue(factors, 'temperature');
    final comfortLevel = _getFactorValue(factors, 'comfort_level');

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 16.h),
        child: Stack(
          children: [
            // background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x0A0B1224), Color(0x050A1020)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // neon blobs
            Positioned(
              top: -40.h,
              left: -40.w,
              child: Container(
                width: 220.w,
                height: 220.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.purple.withOpacity(0.12), Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: -60.h,
              right: -20.w,
              child: Container(
                width: 260.w,
                height: 260.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.blue.withOpacity(0.10), Colors.transparent]),
                ),
              ),
            ),

            // main glass card (NO vertical scrolling - content will adapt to available height)
            LayoutBuilder(builder: (context, constraints) {
              final maxH = MediaQuery.of(context).size.height * 0.82;
              final cardMaxHeight = min(constraints.maxHeight, maxH + 150.h);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: cardMaxHeight,
                    maxWidth: min(constraints.maxWidth, 760.w),
                  ),
                  child: _buildGlassCard(
                    padding: EdgeInsets.all(18.w),
                    child: LayoutBuilder(builder: (ctx, inner) {
                      final availH = inner.maxHeight;
                      // Allocate a fraction of available height to the orbit section so layout won't overflow
                      final orbitH = min(220.h, availH * 0.44);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header
                          Row(
                            children: [
                              Shimmer(
                                duration: const Duration(seconds: 3),
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF2575FC).withOpacity(0.14),
                                        blurRadius: 10.r,
                                        spreadRadius: 2.r,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.holiday_village,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COSMIC SLEEP ENVIRONMENT',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.6.w,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Your room — analyzed with ambient sensors & AI',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(Icons.more_vert, color: Colors.white54),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // orbit + score (fixed fraction height)
                          Center(child: _buildOrbitingScoreSection(score, height: orbitH)),

                          SizedBox(height: 12.h),

                          // insights (single line, truncated)
                          _buildGlassCard(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.white70, size: 20.sp),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    insights,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Shimmer(
                                  duration: const Duration(seconds: 3),
                                  child: Icon(Icons.chevron_right, color: Colors.white24),
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // factors horizontally scrollable (kept horizontal scroll)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildPlanetFactor(
                                  title: 'Noise',
                                  value: noiseLevel,
                                  icon: Icons.volume_up,
                                  recommendations: _getRecommendations(recommendations, 'noise_level'),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF7EB3), Color(0xFFFF758C)],
                                  ),
                                ),
                                _buildPlanetFactor(
                                  title: 'Light',
                                  value: lightExposure,
                                  icon: Icons.lightbulb_outline,
                                  recommendations: _getRecommendations(recommendations, 'light_exposure'),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFA62E), Color(0xFFFFD166)],
                                  ),
                                ),
                                _buildPlanetFactor(
                                  title: 'Temp',
                                  value: temperature,
                                  icon: Icons.thermostat,
                                  recommendations: _getRecommendations(recommendations, 'temperature'),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                                  ),
                                ),
                                _buildPlanetFactor(
                                  title: 'Comfort',
                                  value: comfortLevel,
                                  icon: Icons.king_bed,
                                  recommendations: _getRecommendations(recommendations, 'comfort_level'),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                              ],
                            ),
                          ),

                          // small spacer to keep layout balanced
                          SizedBox(height: 8.h),
                        ],
                      );
                    }),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Painter for neon ring & smooth progress
class _NeonRingPainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1

  _NeonRingPainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.white12;

    // background ring
    canvas.drawCircle(center, radius - 6, basePaint);

    // neon gradient stroke
    final progPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    final rect = Rect.fromCircle(center: center, radius: radius);
    progPaint.shader = ui.Gradient.sweep(
      center,
      [
        color.withOpacity(0.0),
        color.withOpacity(0.9),
        color.withOpacity(0.45),
      ],
      [0.0, 0.5, 1.0],
      TileMode.clamp,
      -pi / 2,
      -pi / 2 + 2 * pi * progress,
    );

    canvas.drawArc(
      rect.inflate(-6),
      -pi / 2,
      2 * pi * progress,
      false,
      progPaint,
    );

    // inner glow
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 22
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius - 6, glow);
  }

  @override
  bool shouldRepaint(covariant _NeonRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

