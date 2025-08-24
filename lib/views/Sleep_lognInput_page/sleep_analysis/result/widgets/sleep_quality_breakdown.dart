import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// -----------------------------------------------------------------------------
// Global UI constants for SleepQualityBreakdown
//
// These constants provide a unified palette across the various breakdown
// components.  Replicating them here avoids cross‑file dependencies while
// ensuring that the aurora gradients and glass cards share the same dark
// background and accent hues seen elsewhere in the app.
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

// Futuristic AI-styled SleepQualityBreakdown
//
// This widget replaces the previous `SleepQualityBreakdown` with a
// glassmorphic, neon‑accented design.  It accepts the same
// `preloadedData` map and produces a starry, aurora‑inspired layout
// without changing the public API.  Drop this file into your project
// to refresh the look; no separate 2050 class is needed.

/// A futuristic reimagining of the sleep quality breakdown using
/// glassmorphism, aurora gradients and neon accents. Drop this widget
/// into your existing code as a direct replacement for the older
/// SleepQualityBreakdown component to refresh the look without
/// changing its API. It accepts the same `preloadedData` map and
/// outputs a starry cosmic layout.
///
/// The design is inspired by modern UI trends such as translucent
/// glass cards layered over colourful blurred backgrounds and
/// holographic accents【953742701188010†L380-L417】.  These elements
/// create depth and a futuristic mood, while neon highlights echo
/// the holographic look【88460565188442†L167-L178】.  Aurora‑like
/// gradients add an organic feel reminiscent of Northern Lights
/// 【88460565188442†L180-L191】.
class SleepQualityBreakdown extends StatelessWidget {
  final Map<String, dynamic> preloadedData;

  const SleepQualityBreakdown({Key? key, required this.preloadedData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final neurosci = preloadedData['neuroscientific_analysis']?.toString() ?? '';
    final circadian = preloadedData['circadian_assessment']?.toString() ?? '';
    final strengthMap = preloadedData['strength'] is Map<String, dynamic>
        ? preloadedData['strength'] as Map<String, dynamic>
        : <String, dynamic>{};
    final improvementMap = preloadedData['improvement'] is Map<String, dynamic>
        ? preloadedData['improvement'] as Map<String, dynamic>
        : <String, dynamic>{};
    final recs = preloadedData['recommendations'] is List
        ? preloadedData['recommendations'] as List<dynamic>
        : <dynamic>[];
    final healthWarn = preloadedData['health_implications']?.toString() ?? '';

    // Wrap the entire breakdown in a Stack to add a starry background beneath
    return Stack(
      children: [
        // Cosmic star field painter behind everything
        Positioned.fill(
          child: CustomPaint(
            painter: _StarryBackgroundPainter(),
          ),
        ),
        // Main content column
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (neurosci.isNotEmpty)
              _FrostedAnalysisCard(
                title: 'BRAIN WAVES ANALYSIS',
                icon: Icons.psychology_rounded,
                accent: const Color(0xFF6A4EFF),
                content: neurosci,
              ),
            SizedBox(height: 18.h),
            if (circadian.isNotEmpty)
              _FrostedAnalysisCard(
                title: 'CIRCADIAN PATTERNS',
                icon: Icons.nights_stay_rounded,
                accent: const Color(0xFF00C2FF),
                content: circadian,
              ),
            SizedBox(height: 18.h),

            // Insights grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InsightHex(
                    title: 'SLEEP STRENGTHS',
                    icon: Icons.star_rounded,
                    color: const Color(0xFF4CD964),
                    insight: strengthMap,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _InsightHex(
                    title: 'IMPROVEMENT AREAS',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFFFF9500),
                    insight: improvementMap,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            if (recs.isNotEmpty)
              _WaveRecommendations(
                title: 'PERSONALIZED RECOMMENDATIONS',
                icon: Icons.lightbulb_rounded,
                recommendations: recs,
              ),

            if (healthWarn.isNotEmpty) ...[
              SizedBox(height: 14.h),
              _PulseAlert(content: healthWarn),
            ],
          ],
        ),
      ],
    );
  }
}

// ---------------------- Reusable UI primitives ----------------------

class _FrostedAnalysisCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final String content;

  const _FrostedAnalysisCard({required this.title, required this.icon, required this.accent, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        // Use the unified card gradient so the base colour matches the rest of the app.
        gradient: kCardGradient,
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NeonIconCircle(icon: icon, color: accent),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.sp, letterSpacing: 1.1)),
                SizedBox(height: 10.h),
                Text(content, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp, height: 1.6)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _NeonIconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _NeonIconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(0.25), Colors.transparent]),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 26.sp)),
    );
  }
}

class _InsightHex extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> insight;

  const _InsightHex({required this.title, required this.icon, required this.color, required this.insight});

  @override
  Widget build(BuildContext context) {
    final titleText = insight['title']?.toString() ?? '';
    final explanation = insight['explanation']?.toString() ?? '';
    final impact = insight['impact']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.22)),
        gradient: LinearGradient(colors: [color.withOpacity(0.06), Colors.black.withOpacity(0.16)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          _HexagonAvatar(icon: icon, color: color),
          SizedBox(height: 10.h),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13.sp)),
          SizedBox(height: 8.h),
          if (titleText.isNotEmpty)
            Text(titleText, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
          if (explanation.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(explanation, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13.sp, height: 1.5)),
          ],
          if (impact.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(12.r)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: color, size: 16.sp),
                  SizedBox(width: 8.w),
                  Flexible(child: Text('Impact: $impact', style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w600))),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}

class _HexagonAvatar extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _HexagonAvatar({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(size: Size(68.w, 68.w), painter: _HexPainter(color: color.withOpacity(0.12))),
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.25), border: Border.all(color: color.withOpacity(0.14))),
          child: Center(child: Icon(icon, color: color, size: 22.sp)),
        ),
      ],
    );
  }
}

class _HexPainter extends CustomPainter {
  final Color color;
  _HexPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill..color = color;
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaveRecommendations extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<dynamic> recommendations;

  const _WaveRecommendations({required this.title, required this.icon, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        gradient: LinearGradient(colors: [Colors.black.withOpacity(0.25), Colors.black.withOpacity(0.18)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              gradient: LinearGradient(colors: [Color(0xFF6A4EFF).withOpacity(0.36), Color(0xFF00C2FF).withOpacity(0.12)]),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 20.sp), SizedBox(width: 10.w), Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.sp))]),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(children: recommendations.map((r) {
              final m = r is Map<String, dynamic> ? r : <String, dynamic>{};
              return _RecommendationTile(data: m);
            }).toList()),
          )
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecommendationTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final action = data['action']?.toString() ?? '';
    final rationale = data['rationale']?.toString() ?? '';
    final implementation = data['implementation']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.black.withOpacity(0.28),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 6.w, height: 6.w, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A4EFF), Color(0xFF00C2FF)]), borderRadius: BorderRadius.circular(10.r))),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (action.isNotEmpty) Text(action, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
            if (rationale.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(rationale, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13.sp, height: 1.5)),
            ],
            if (implementation.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.36), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.amber.withOpacity(0.18))),
                child: Row(children: [Icon(Icons.auto_awesome, color: Colors.amber, size: 16.sp), SizedBox(width: 8.w), Expanded(child: Text(implementation, style: TextStyle(color: Colors.amber.shade200, fontSize: 13.sp))) ]),
              )
            ]
          ]),
        )
      ]),
    );
  }
}

class _PulseAlert extends StatelessWidget {
  final String content;
  const _PulseAlert({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        gradient: RadialGradient(colors: [Colors.red.withOpacity(0.12), Colors.transparent], radius: 1.2),
      ),
      child: Row(children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.red.withOpacity(0.3), Colors.transparent])),
          child: Center(child: Icon(Icons.favorite_rounded, color: Colors.white, size: 26.sp)),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Text(content, style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14.sp, height: 1.6))),
      ]),
    );
  }
}

/// A custom painter used to render a simple cosmic star field behind the
/// sleep quality breakdown. The star density scales with the available
/// space, and a mix of small white stars and occasional colored glows
/// creates subtle depth without distracting from the content. This
/// painter is lightweight and does not animate; it is meant to be used
/// statically as a backdrop for the futuristic design aesthetic.
class _StarryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(271828);
    final paint = Paint()..color = Colors.white;
    final starCount = (size.width * size.height / 1800).clamp(50, 140).toInt();
    // draw small twinkling stars
    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.3;
      final opacity = 0.2 + random.nextDouble() * 0.5;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withOpacity(opacity),
      );
    }
    // draw occasional colored glows to add depth
    for (int i = 0; i < starCount ~/ 6; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.8 + random.nextDouble() * 1.8;
      final opacity = 0.3 + random.nextDouble() * 0.4;
      final color = i % 3 == 0
          ? Colors.cyanAccent
          : i % 3 == 1
          ? Colors.amberAccent
          : Colors.purpleAccent;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
