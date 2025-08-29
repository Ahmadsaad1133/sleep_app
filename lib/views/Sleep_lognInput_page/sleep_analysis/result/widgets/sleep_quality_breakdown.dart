
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets2/neo_design.dart'; // NeoBackground, NeoCard, neonA/B/C

/// SleepQualityBreakdown
/// Refactored to align with Overview section design:
/// - Uses NeoBackground + NeoCard
/// - Gradient section headers (neonA/B/C)
/// - Consistent paddings/typography
/// - Keeps data API intact: preloadedData map with keys:
///   neuroscientific_analysis, circadian_assessment, strength (Map),
///   improvement (Map), recommendations (List), health_implications
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
    final rawRecs = preloadedData['recommendations'];
    final List<String> recs = rawRecs is List
        ? rawRecs.map((e) => e.toString()).toList()
        : <String>[];
    final healthWarn = preloadedData['health_implications']?.toString() ?? '';

    return NeoBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (no holder / card)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Sleep Quality Breakdown', Icons.analytics_outlined),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _pill('Strengths ' + strengthMap.length.toString()),
                        _pill('Improve ' + improvementMap.length.toString()),
                        if (recs.isNotEmpty) _pill('Tips ' + recs.length.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Neuroscientific Analysis
              if (neurosci.isNotEmpty)
                Padding(padding: EdgeInsets.all(16.r), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Neuroscientific Analysis', Icons.psychology_outlined),
                    SizedBox(height: 10.h),
                    Text(neurosci, style: TextStyle(color: Colors.white70, fontSize: 13.sp, height: 1.35)),
                  ],
                ),),

              if (neurosci.isNotEmpty) SizedBox(height: 14.h),

              // Circadian Assessment
              if (circadian.isNotEmpty)
                Padding(padding: EdgeInsets.all(16.r), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Circadian Assessment', Icons.wb_twighlight),
                    SizedBox(height: 10.h),
                    Text(circadian, style: TextStyle(color: Colors.white70, fontSize: 13.sp, height: 1.35)),
                  ],
                ),),

              if (circadian.isNotEmpty) SizedBox(height: 14.h),

              // Strengths
              if (strengthMap.isNotEmpty)
                Padding(padding: EdgeInsets.all(16.r), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Strengths', Icons.verified_outlined),
                    SizedBox(height: 10.h),
                    ..._kvBullets(strengthMap, positive: true),
                  ],
                ),),

              if (strengthMap.isNotEmpty) SizedBox(height: 14.h),

              // Areas to Improve
              if (improvementMap.isNotEmpty)
                Padding(padding: EdgeInsets.all(16.r), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Areas to Improve', Icons.trending_down_outlined),
                    SizedBox(height: 10.h),
                    ..._kvBullets(improvementMap, positive: false),
                  ],
                ),),

              if (improvementMap.isNotEmpty) SizedBox(height: 14.h),

              // Recommendations
              if (recs.isNotEmpty)
                Padding(padding: EdgeInsets.all(16.r), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Recommendations', Icons.tips_and_updates_outlined),
                    SizedBox(height: 8.h),
                    ...recs.map((t) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.white70),
                          SizedBox(width: 8.w),
                          Expanded(child: Text(t, style: TextStyle(color: Colors.white70, fontSize: 12.5.sp, height: 1.35))),
                        ],
                      ),
                    ))
                  ],
                ),),

              if (recs.isNotEmpty) SizedBox(height: 14.h),

              // Health Implications / Warnings
              if (healthWarn.isNotEmpty)
                Padding(padding: EdgeInsets.all(16.r), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Health Implications', Icons.health_and_safety_outlined),
                    SizedBox(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_outlined, size: 18, color: Colors.amber),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(healthWarn, style: TextStyle(color: Colors.amber.shade200, fontSize: 13.sp, height: 1.35))),
                      ],
                    ),
                  ],
                ),),
            ],
          ),
        ),
      ),
    );
  }

  // ---- UI helpers (local copy to avoid cross-file deps) ------------------
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        SizedBox(width: 8.w),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(colors: [neonA, neonB, neonC]).createShader(rect),
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ],
    );
  }

  static Widget _pill(String text) {
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

  List<Widget> _kvBullets(Map<String, dynamic> map, {required bool positive}) {
    final icon = positive ? Icons.check_circle_outline : Icons.remove_circle_outline;
    final Color iconColor = positive ? Colors.greenAccent.shade100 : Colors.redAccent.shade100;
    final entries = map.entries.toList();
    return [
      for (final e in entries)
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: iconColor),
              SizedBox(width: 8.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${e.key}: ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5.sp),
                      ),
                      TextSpan(
                        text: e.value?.toString() ?? '',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }
}
