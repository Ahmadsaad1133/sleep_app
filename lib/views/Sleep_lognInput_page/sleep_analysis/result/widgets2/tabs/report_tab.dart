
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ReportTab (ScreenUtil + Sliver-friendly)
/// This widget is **non-scrollable** and is meant to be placed inside a parent's
/// CustomScrollView via SliverToBoxAdapter (as your _wrapTabWithSliverWidget likely does).
/// It supports:
/// - Modern map via [initialReportData]/[loadReport]
/// - Legacy named params (permissive dynamic types)
class ReportTab extends StatefulWidget {
  // Modern map-based
  final Map<String, dynamic>? initialReportData;
  final Future<Map<String, dynamic>> Function()? loadReport;
  final SliverOverlapAbsorberHandle? overlapHandle; // accepted but unused (no inner scroll)

  // Legacy named params (permissive types)
  final double? totalSleepHours;
  final double? efficiency;
  final num? deepPct;
  final num? remPct;
  final num? lightPct;
  final dynamic last7DaysHours;
  final num? sleepScore;

  // Sections
  final dynamic executiveSummary;
  final dynamic dailyComparison;
  final dynamic lifestyleCorrelations;
  final dynamic environmentAnalysis;
  final dynamic dreamMoodForecast;
  final dynamic aiHighlights;
  final dynamic recommendations;
  final String? chronotype;
  final String? sleepMidpoint;
  final dynamic morningReadiness;
  final dynamic whatIfScenarios;
  final dynamic wakeWindows;
  final dynamic riskAssessment;
  final dynamic energyPlan;
  final dynamic drivers;
  final dynamic achievements;
  final dynamic hrvSummary;
  final dynamic respiratory;
  final dynamic glucoseCorrelation;
  final dynamic actionItems;
  final dynamic causalGraph;
  final dynamic energyTimeline;
  final dynamic cognitiveWindows;
  final dynamic microArousals;
  final dynamic architectureNotes;
  final dynamic recoveryPlan;
  final dynamic nutrition;
  final dynamic streaks;
  final dynamic smartGoals;


  const ReportTab({
    Key? key,
    // modern
    this.initialReportData,
    this.loadReport,
    this.overlapHandle,
    // legacy
    this.totalSleepHours,
    this.efficiency,
    this.deepPct,
    this.remPct,
    this.lightPct,
    this.last7DaysHours,
    this.sleepScore,
    this.dailyComparison,
    this.lifestyleCorrelations,
    this.environmentAnalysis,
    this.dreamMoodForecast,
    this.aiHighlights,
    this.recommendations,
    this.chronotype,
    this.sleepMidpoint,
    this.morningReadiness,
    this.whatIfScenarios,
    this.wakeWindows,
    this.riskAssessment,
    this.energyPlan,
    this.drivers,
    this.achievements,
    this.hrvSummary,
    this.respiratory,
    this.glucoseCorrelation,
    this.actionItems,
    this.causalGraph,
    this.energyTimeline,
    this.cognitiveWindows,
    this.microArousals,
    this.architectureNotes,
    this.recoveryPlan,
    this.nutrition,
    this.streaks,
    this.smartGoals, this.executiveSummary,
  }) : super(key: key);

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  Map<String, dynamic>? _data;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _data = widget.initialReportData != null ? Map<String, dynamic>.from(widget.initialReportData!) : null;
    final legacy = _legacyParamsAsMap();
    if (legacy.isNotEmpty) {
      _data = {...?_data, ...legacy};

    }

    if (widget.loadReport != null) {
      final sectionPaths = [
        'executive_summary',
        'executiveSummary',
        'risk_assessment',
        'riskAssessment',
        'energy_plan',
        'energyPlan',
        'wake_windows',
        'wakeWindows',
        'sections.executive_summary',
        'sections.executiveSummary',
        'sections.risk_assessment',
        'sections.riskAssessment',
        'sections.energy_plan',
        'sections.energyPlan',
        'sections.wake_windows',
        'sections.wakeWindows',
      ];
      final hasSections = _data != null && sectionPaths.any((k) => _readByPath(_data!, k) != null);

      if (!hasSections) {
        _fetchOnce();
      }
    }
  }

  String _readString(List<String> keys, {String fallback = ''}) {
    final map = _data;
    if (map == null) return fallback;
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return fallback;
  }

  num _readNum(List<String> keys, {num fallback = -1}) {
    final map = _data;
    if (map == null) return fallback;
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (v is num) return v;
      if (v is String) {
        final parsed = num.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  List _readList(List<String> keys) {
    final map = _data;
    if (map == null) return const [];
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (v is List) return v;
      if (v != null) return [v];
    }
    return const [];
  }
  bool _hasMeaningful(dynamic v) {
    if (v == null) return false;
    if (v is String) return v.trim().isNotEmpty;
    if (v is Iterable) return v.isNotEmpty;
    if (v is Map) return v.isNotEmpty;
    return true;
  }

  dynamic _readAny(List<String> keys) {
    final map = _data;
    if (map == null) return null;
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (_hasMeaningful(v)) return v;
    }
    return null;
  }
  dynamic _readByPath(Map source, String path) {
    dynamic current = source;
    for (final part in path.split('.')) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
  Map<String, dynamic> _legacyParamsAsMap() {
    final m = <String, dynamic>{};

    if (widget.totalSleepHours != null ||
        widget.efficiency != null ||
        widget.deepPct != null ||
        widget.remPct != null ||
        widget.lightPct != null ||
        widget.last7DaysHours != null ||
        widget.sleepScore != null) {
      m['metrics'] = {
        if (widget.totalSleepHours != null) 'total_sleep_hours': widget.totalSleepHours,
        if (widget.efficiency != null) 'sleep_efficiency': widget.efficiency,
        if (widget.deepPct != null) 'deep_pct': widget.deepPct,
        if (widget.remPct != null) 'rem_pct': widget.remPct,
        if (widget.lightPct != null) 'light_pct': widget.lightPct,
        if (widget.last7DaysHours != null) 'last7days_hours': widget.last7DaysHours,
        if (widget.sleepScore != null) 'sleep_score': widget.sleepScore,
      };
    }

    void put(String key, dynamic val) {
      if (val != null) {
        if (val is Map<dynamic, dynamic>) {
          m[key] = _convertToStringKeyedMap(val);
        } else {
          m[key] = val;
        }
      }
    }
    put('executive_summary', widget.executiveSummary);
    put('daily_comparison', widget.dailyComparison);
    put('lifestyle_correlations', widget.lifestyleCorrelations);
    put('environment_analysis', widget.environmentAnalysis);
    put('dream_mood_forecast', widget.dreamMoodForecast);
    put('ai_highlights', widget.aiHighlights);
    put('recommendations', widget.recommendations);
    put('chronotype', widget.chronotype);
    put('sleep_midpoint', widget.sleepMidpoint);
    put('morning_readiness', widget.morningReadiness);
    put('what_if_scenarios', widget.whatIfScenarios);
    put('wake_windows', widget.wakeWindows);
    put('risk_assessment', widget.riskAssessment);
    put('energy_plan', widget.energyPlan);
    put('drivers', widget.drivers);
    put('achievements', widget.achievements);
    put('hrv_summary', widget.hrvSummary);
    put('respiratory', widget.respiratory);
    put('glucose_correlation', widget.glucoseCorrelation);
    put('action_items', widget.actionItems);
    put('causal_graph', widget.causalGraph);
    put('energy_timeline', widget.energyTimeline);
    put('cognitive_windows', widget.cognitiveWindows);
    put('micro_arousals', widget.microArousals);
    put('architecture_notes', widget.architectureNotes);
    put('recovery_plan', widget.recoveryPlan);
    put('nutrition', widget.nutrition);
    put('streaks', widget.streaks);
    put('smart_goals', widget.smartGoals);

    return m;
  }

// Add this helper method to convert dynamic maps to string-keyed maps
  Map<String, dynamic> _convertToStringKeyedMap(Map<dynamic, dynamic> dynamicMap) {
    return dynamicMap.map((key, value) {
      if (value is Map<dynamic, dynamic>) {
        return MapEntry(key.toString(), _convertToStringKeyedMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), value.map((item) {
          if (item is Map<dynamic, dynamic>) {
            return _convertToStringKeyedMap(item);
          }
          return item;
        }).toList());
      }
      return MapEntry(key.toString(), value);
    });
  }

  Future<void> _fetchOnce() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await widget.loadReport!.call();
      final normalized = _asStringKeyedMap(res);
      if (mounted) {
        setState(() {
          _data = {...?_data, ...normalized};
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e; _loading = false; });
      }
    }
  }

  Map<String, dynamic> _asStringKeyedMap(Map input) {
    return _convertToStringKeyedMap(input.cast<dynamic, dynamic>());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Non-scroll content to be embedded inside parent sliver
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          SizedBox(height: 12.h),
          if (_loading) _SkeletonList(),
          if (_error != null) _ErrorBox(error: _error),
          if (!_loading && _error == null) ...[
            _buildExecutiveSummary(theme),
            SizedBox(height: 12.h),
            _buildRiskAssessment(theme),
            SizedBox(height: 12.h),
            _buildEnergyPlan(theme),
            SizedBox(height: 12.h),
            _buildWakeWindows(theme),
            SizedBox(height: 12.h),
            _buildWhatIfScenarios(theme),
            SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }


  // ---- Sections ----
  Widget _buildExecutiveSummary(ThemeData theme) {
    // Try to read from both legacy parameter and data map
    final legacySummary = widget.executiveSummary;
    var raw = legacySummary is String
        ? legacySummary
        : _readString([
      'executive_summary',
      'executiveSummary',
      'summary',
      'overview',
      'sections.executive_summary',//
      'sections.executiveSummary',
    ]);

    final text = _ensurePlainReportText(raw);
    return _SectionCard(
      title: 'Executive Summary',
      subtitle: 'One-glance recap of your night',
      child: text.isEmpty
          ? _EmptyText('No summary available yet.')
          : Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp, height: 1.35),
      ),
    );
  }

  Widget _buildRiskAssessment(ThemeData theme) {
    // Try to read from legacy parameter first
    dynamic riskData = widget.riskAssessment;
    List risks = const [];

    if (riskData is Map && riskData['risks'] is List) {
      risks = List.from(riskData['risks']);
    } else if (riskData is List) {
      risks = List.from(riskData);
    } else {
      // Fall back to stored data
      risks = _readList([
        'risk_assessment.risks',
        'riskAssessment.risks',
        'risk_assessment',
        'riskAssessment',
        'sections.risk_assessment.risks',
        'sections.riskAssessment.risks',
        'sections.risk_assessment',
        'sections.riskAssessment',
      ]);
    }

    return _SectionCard(
      title: 'Risk Assessment',
      subtitle: 'Potential sleep disruptors',
      child: (risks.isEmpty)
          ? _EmptyText('No notable risks detected.')
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in risks.take(6))
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    margin: EdgeInsets.only(top: 6.h, right: 10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(.9),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnergyPlan(ThemeData theme) {
    // Try to read from legacy parameter first
    dynamic energyData = widget.energyPlan;
    List steps = const [];
    String headline = 'Daily Energy Plan';

    if (energyData is Map) {
      if (energyData['steps'] is List) steps = List.from(energyData['steps']);
      if (energyData['title'] != null) headline = energyData['title'].toString();
    } else if (energyData is List) {
      steps = List.from(energyData);
    } else {
      // Fall back to stored data
      steps = _readList([
        'energy_plan.steps',
        'energyPlan.steps',
        'plan.steps',
        'sections.energy_plan.steps',
        'sections.energyPlan.steps',
      ]);
      headline = _readString([
        'energy_plan.title',
        'energyPlan.title',
        'sections.energy_plan.title',
        'sections.energyPlan.title',
      ], fallback: headline);
    }

    return _SectionCard(
      title: headline,
      subtitle: 'Simple steps to feel better today',
      child: steps.isEmpty
          ? _EmptyText('No plan generated yet.')
          : Column(children: [for (final s in steps.take(6)) _StepRow(text: s.toString())]),
    );
  }

  Widget _buildWakeWindows(ThemeData theme) {
    // Try to read from legacy parameter first
    dynamic windowsData = widget.wakeWindows;
    List windows = [];

    if (windowsData is List) {
      windows = List.from(windowsData);
    } else {
      // Fall back to stored data
      windows = _readList([
        'wake_windows',
        'wakeWindows',
        'sections.wake_windows',
        'sections.wake_windows.items',
        'sections.wakeWindows',
        'sections.wakeWindows.items',
      ]);
    }

    return _SectionCard(
      title: 'Suggested Wake Windows',
      subtitle: 'Optimal times to start your day',
      child: windows.isEmpty
          ? _EmptyText('No wake windows available.')
          : Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [for (final w in windows) _Chip(text: w.toString())],
      ),
    );
  }

  Widget _buildWhatIfScenarios(ThemeData theme) {
    // Try to read from legacy parameter first
    dynamic scenariosData = widget.whatIfScenarios;
    List scenarios = [];

    if (scenariosData is List) {
      scenarios = List.from(scenariosData);
    } else {
      // Fall back to stored data
      scenarios = _readList([
        'what_if_scenarios',
        'whatIfScenarios',
        'scenarios',
        'items',
        'sections.what_if_scenarios',
        'sections.what_if_scenarios.items',
        'sections.whatIfScenarios',
        'sections.whatIfScenarios.items',
        'sections.scenarios',
        'sections.items',
      ]);
    }

    return _SectionCard(
      title: 'What-If Scenarios',
      subtitle: 'Small changes, predicted impact',
      child: scenarios.isEmpty
          ? _EmptyText('Add more sleep logs to unlock simulations.')
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in scenarios)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _BulletItem(
                title: s is Map && s['title'] != null ? s['title'].toString() : s.toString(),
                subtitle: s is Map && s['impact'] != null ? s['impact'].toString() : null,
              ),
            ),
        ],
      ),
    );
  }
}



// ---- UI Pieces ----

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.analytics_outlined, size: 24.sp, color: theme.colorScheme.primary),
        SizedBox(width: 8.w),
        Text(
          'Report',
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        Spacer(),
        _HelpBadge(),
      ],
    );
  }
}

class _HelpBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14.sp, color: theme.colorScheme.primary),
          SizedBox(width: 6.w),
          Text(
            'AI generated',
            style: theme.textTheme.labelMedium?.copyWith(fontSize: 12.sp, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: Offset(0, 4.h),
            color: Colors.black.withOpacity(.05),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.5.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}
// ADD THIS WIDGET in report_tab.dart (after _SectionCard is fine)
class _BulletItem extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _BulletItem({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text('•', style: theme.textTheme.titleMedium),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 18.w),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
        ]
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;
  const _EmptyText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 13.5.sp,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  _MetricItem({required this.label, required this.value});
}

class _MetricsGrid extends StatelessWidget {
  final List<_MetricItem> items;
  const _MetricsGrid({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 480.w;
        final cross = isWide ? 5 : 2;
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            mainAxisExtent: 72.h,
          ),
          itemBuilder: (context, i) {
            final it = items[i];
            return Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    it.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 12.5.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    it.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  final String text;
  const _StepRow({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18.sp, color: theme.colorScheme.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(fontSize: 12.5.sp),
      ),
    );
  }
}

class _WhatIfTile extends StatelessWidget {
  final String title;
  final String? impact;
  final String? detail;

  const _WhatIfTile({
    Key? key,
    required this.title,
    this.impact,
    this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, size: 18.sp, color: theme.colorScheme.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (impact != null && impact!.trim().isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    impact!,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 12.sp),
                  ),
                ),
            ],
          ),
          if (detail != null && detail!.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              detail!,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5.sp, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          _SkeletonCard(),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.035),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final Object? error;
  const _ErrorBox({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        'Failed to load report: ${error ?? 'Unknown error'}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontSize: 13.5.sp,
        ),
      ),
    );
  }
}


extension ReportTabStateSanitizer on _ReportTabState {
  String _ensurePlainReportText(dynamic input) {
    if (input == null) return '';
    if (input is String) {
      final s = input.trim();
      // Strip fenced code blocks ```...```
      final fence = RegExp(r'^```(?:[\\w+-]+)?\\s*([\\s\\S]*?)\\s*```$');
      final m = fence.firstMatch(s);
      final content = m != null ? (m.group(1) ?? '').trim() : s;

      // Try to parse JSON-like strings
      if (content.startsWith('{') || content.startsWith('[')) {
        try {
          final decoded = jsonDecode(content);
          return _flattenJson(decoded).trim();
        } catch (_) {
          // fall through
        }
      }
      // Unquote stray quotes
      final unquoted = content.replaceAll(RegExp(r'^[\\s"]+|[\\s"]+$'), '');
      return unquoted;
    }
    if (input is List) {
      final items = input
          .map((e) => _ensurePlainReportText(e))
          .where((e) => e.isNotEmpty)
          .toList();
      if (items.isEmpty) return '';
      return '• ' + items.join('\\n• ');
    }
    if (input is Map) {
      return _flattenJson(input).trim();
    }
    return input.toString();
  }

  String _flattenJson(dynamic v, {int depth = 0}) {
    final indent = '  ' * depth;
    if (v is Map) {
      final buf = StringBuffer();
      v.forEach((key, val) {
        if (val == null) return;
        final k = _titleize(key.toString());
        if (val is Map || val is List) {
          buf.writeln('$indent• $k:');
          buf.writeln(_flattenJson(val, depth: depth + 1));
        } else {
          buf.writeln('$indent• $k: ${val.toString()}');
        }
      });
      return buf.toString();
    }
    if (v is List) {
      final buf = StringBuffer();
      for (final e in v) {
        if (e is Map || e is List) {
          buf.writeln('$indent•');
          buf.writeln(_flattenJson(e, depth: depth + 1));
        } else {
          buf.writeln('$indent• ${e.toString()}');
        }
      }
      return buf.toString();
    }
    return '$indent• ${v.toString()}';
  }

  String _titleize(String s) {
    // snake_case and camelCase -> Title Case
    var t = s.replaceAll('_', ' ');
    t = t.replaceAllMapped(RegExp(r'(?<!^)([A-Z])'), (m) => ' ${m.group(1)}');
    t = t.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }
}
