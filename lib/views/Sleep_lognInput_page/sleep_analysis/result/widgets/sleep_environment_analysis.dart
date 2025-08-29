import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets2/neo_design.dart'; // Provides NeoBackground, NeoCard, neonA/B/C

/// SleepEnvironmentAnalysis
/// Refactored to match the same "Overview" neo design:
/// - Uses NeoBackground & NeoCard
/// - Consistent paddings/typography with overview
/// - Leaves data & keys unchanged (score, factors, recommendations, insights)
class SleepEnvironmentAnalysis extends StatefulWidget {
  final Map<String, dynamic> environmentAnalysis;

  const SleepEnvironmentAnalysis({
    super.key,
    required this.environmentAnalysis,
  });

  @override
  State<SleepEnvironmentAnalysis> createState() => _SleepEnvironmentAnalysisState();
}

class _SleepEnvironmentAnalysisState extends State<SleepEnvironmentAnalysis> with TickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final factors = widget.environmentAnalysis['factors'] as Map<String, dynamic>? ?? {};
    final recommendations = widget.environmentAnalysis['recommendations'] as Map<String, dynamic>? ?? {};
    final rawScore = widget.environmentAnalysis['score'];
    final double score = rawScore is int ? rawScore.toDouble() : (rawScore as double?) ?? 0.0;
    final insights = widget.environmentAnalysis['insights'] as String? ?? 'No insights available';

    final noiseLevel    = _getFactorValue(factors, 'noise_level');
    final lightExposure = _getFactorValue(factors, 'light_exposure');
    final temperature   = _getFactorValue(factors, 'temperature');
    final comfortLevel  = _getFactorValue(factors, 'comfort_level');

    return NeoBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & score
              NeoCard(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: SizedBox(
                        width: 96.w,
                        height: 96.w,
                        child: CustomPaint(
                          painter: _CircularArcGauge(
                            value: (score * 10).clamp(0, 100), // Keep same scale as overview gauge [0-100]
                            max: 100,
                            start: -120,
                            sweep: 240,
                            trackColor: Colors.white12,
                            gradient: const SweepGradient(
                              colors: [neonA, neonB, neonC],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  score.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '/ 10',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Sleep Environment', Icons.eco_outlined),
                          SizedBox(height: 8.h),
                          Text(
                            _getScoreDescription(score),
                            style: TextStyle(color: Colors.white70, fontSize: 12.sp, height: 1.3),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              _pill('${_ratingLabel(score)}'),
                              if (comfortLevel.isNotEmpty) _pill('Comfort: ${_formatValue(comfortLevel)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Factors row
              NeoCard(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Environment Factors', Icons.settings_input_component),
                    SizedBox(height: 12.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _factorTile(
                            title: 'Noise',
                            value: noiseLevel,
                            icon: Icons.volume_up,
                            onTap: () => _showRecommendationsSheet('Noise', _getRecommendations(recommendations, 'noise_level')),
                          ),
                          SizedBox(width: 10.w),
                          _factorTile(
                            title: 'Light',
                            value: lightExposure,
                            icon: Icons.lightbulb_outline,
                            onTap: () => _showRecommendationsSheet('Light', _getRecommendations(recommendations, 'light_exposure')),
                          ),
                          SizedBox(width: 10.w),
                          _factorTile(
                            title: 'Temperature',
                            value: temperature,
                            icon: Icons.thermostat,
                            onTap: () => _showRecommendationsSheet('Temperature', _getRecommendations(recommendations, 'temperature')),
                          ),
                          SizedBox(width: 10.w),
                          _factorTile(
                            title: 'Comfort',
                            value: comfortLevel,
                            icon: Icons.bed_outlined,
                            onTap: () => _showRecommendationsSheet('Comfort', _getRecommendations(recommendations, 'comfort_level')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Insights
              NeoCard(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Quick Insights', Icons.insights_outlined),
                    SizedBox(height: 10.h),
                    Text(insights, style: TextStyle(color: Colors.white, fontSize: 13.sp, height: 1.35)),
                  ],
                ),
              ),

              // General recommendations (if present)
              Builder(
                builder: (_) {
                  final recs = widget.environmentAnalysis['recommendations'];
                  List<String> generalRecs = [];
                  if (recs is Map && recs['general'] != null) {
                    final g = recs['general'];
                    if (g is List) generalRecs = g.cast<String>();
                    if (g is String) generalRecs = [g];
                  }
                  if (generalRecs.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: NeoCard(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('General Tips', Icons.tips_and_updates_outlined),
                          SizedBox(height: 8.h),
                          ...generalRecs.map((t) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: Colors.white70),
                                SizedBox(width: 8.w),
                                Expanded(child: Text(t, style: TextStyle(color: Colors.white70, fontSize: 12.5.sp, height: 1.35))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers ---------------------------------------------------------------
  String _getFactorValue(Map<String, dynamic> factors, String key) {
    final v = factors[key];
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  List<String> _getRecommendations(Map<String, dynamic>? recsMap, String key) {
    if (recsMap == null) return [];
    final recs = recsMap[key];
    if (recs is List) return recs.cast<String>();
    if (recs is String) return [recs];
    return [];
  }

  String _formatValue(String value) => value.isEmpty ? 'N/A' : value;

  String _ratingLabel(double score) {
    if (score >= 8.5) return 'Excellent';
    if (score >= 7.0) return 'Good';
    if (score >= 5.0) return 'Fair';
    return 'Poor';
  }

  String _getScoreDescription(double score) {
    if (score >= 8) return 'Perfect cosmic sleep environment';
    if (score >= 5) return 'Good environment with room for improvement';
    return 'Needs significant improvements';
  }

  void _showRecommendationsSheet(String title, List<String> recs) {
    if (recs.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: NeoCard(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('$title — Recommendations', Icons.tips_and_updates_outlined),
                  SizedBox(height: 10.h),
                  ...recs.map((e) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Colors.white70),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(e, style: TextStyle(color: Colors.white70, fontSize: 12.5.sp, height: 1.35))),
                      ],
                    ),
                  )),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                      label: const Text('Close', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Small neo helpers used in overview -----------------------------------
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        SizedBox(width: 8.w),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(colors: [neonA, neonB, neonC]).createShader(rect),
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

  Widget _pill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 11.5.sp)),
    );
  }

  Widget _factorTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$title factor: $value',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160.w,
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5.sp),
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: Colors.white38, size: 16),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                _formatValue(value),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              SizedBox(height: 4.h),
              Text(
                'Tap for tips',
                style: TextStyle(fontSize: 11.sp, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Simple circular arc gauge (same API as in Overview)
class _CircularArcGauge extends CustomPainter {
  final double value;
  final double max;
  final double start; // degrees
  final double sweep; // degrees
  final Color trackColor;
  final SweepGradient gradient;

  _CircularArcGauge({
    required this.value,
    required this.max,
    required this.start,
    required this.sweep,
    required this.trackColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final radius = min(size.width, size.height)/2 - 4;
    final startR = start * pi / 180.0;
    final sweepR = sweep * pi / 180.0;

    // track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = trackColor
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startR, sweepR, false, track);

    // progress
    final p = (value / max).clamp(0.0, 1.0);
    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startR, sweepR * p, false, prog);
  }

  @override
  bool shouldRepaint(covariant _CircularArcGauge oldDelegate) {
    return oldDelegate.value != value || oldDelegate.max != max;
  }
}
