
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
    this.smartGoals,
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
    if (_data == null && widget.loadReport != null) {
      _fetchOnce();
    }
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

    void put(String key, dynamic val) { if (val != null) m[key] = val; }
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
    return input.map((key, value) => MapEntry(key.toString(), value));
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
            _buildKeyMetrics(theme),
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
    final text = _readString(['executive_summary', 'summary', 'overview']);
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

  Widget _buildKeyMetrics(ThemeData theme) {
    final totalSleep = widget.totalSleepHours ?? _readNum(['metrics.total_sleep_hours', 'metrics.totalSleepHours', 'total_sleep_hours']).toDouble();
    final efficiency = widget.efficiency ?? _readNum(['metrics.sleep_efficiency', 'metrics.sleepEfficiency', 'sleep_efficiency']).toDouble();

    num deep = widget.deepPct ?? _readNum(['metrics.deep_pct', 'sleep_stages.deep', 'sleepStages.deep', 'deepPct']);
    num rem  = widget.remPct  ?? _readNum(['metrics.rem_pct', 'sleep_stages.rem',  'sleepStages.rem',  'remPct']);
    num light= widget.lightPct?? _readNum(['metrics.light_pct','sleep_stages.light','sleepStages.light','lightPct']);

    final items = [
      _MetricItem(label: 'Total Sleep', value: (totalSleep > 0) ? '${totalSleep.toStringAsFixed(1)} h' : '—'),
      _MetricItem(label: 'Efficiency', value: (efficiency > 0) ? '${efficiency.toStringAsFixed(0)}%' : '—'),
      _MetricItem(label: 'Deep', value: (deep >= 0) ? '${deep.toStringAsFixed(0)}%' : '—'),
      _MetricItem(label: 'REM', value: (rem >= 0) ? '${rem.toStringAsFixed(0)}%' : '—'),
      _MetricItem(label: 'Light', value: (light >= 0) ? '${light.toStringAsFixed(0)}%' : '—'),
    ];

    return _SectionCard(
      title: 'Sleep Efficiency & Stages',
      subtitle: 'Core quality indicators',
      child: _MetricsGrid(items: items),
    );
  }

  Widget _buildRiskAssessment(ThemeData theme) {
    List risks = const [];
    if (widget.riskAssessment is Map && (widget.riskAssessment as Map)['risks'] is List) {
      risks = List.from((widget.riskAssessment as Map)['risks']);
    } else {
      risks = _readList(['risk_assessment.risks', 'riskAssessment.risks']);
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
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp, height: 1.35),
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
    List steps = const [];
    String headline = 'Daily Energy Plan';

    if (widget.energyPlan is Map) {
      final map = widget.energyPlan as Map;
      if (map['steps'] is List) steps = List.from(map['steps']);
      if (map['title'] != null) headline = map['title'].toString();
    } else {
      steps = _readList(['energy_plan.steps', 'energyPlan.steps', 'plan.steps']);
      headline = _readString(['energy_plan.title', 'energyPlan.title'], fallback: headline);
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
    List windows;
    if (widget.wakeWindows is List) {
      windows = List.from(widget.wakeWindows as List);
    } else {
      windows = _readList(['wake_windows', 'wakeWindows']);
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
    List scenarios;
    if (widget.whatIfScenarios is List) {
      scenarios = List.from(widget.whatIfScenarios as List);
    } else {
      scenarios = _readList(['what_if_scenarios', 'whatIfScenarios']);
    }

    return _SectionCard(
      title: 'What-If Scenarios',
      subtitle: 'Small changes, predicted impact',
      child: scenarios.isEmpty
          ? _EmptyText('Add more sleep logs to unlock simulations.')
          : Column(
        children: scenarios
            .map((s) => ListTile(
          leading: const Icon(Icons.auto_graph),
          title: Text(s.toString()),
        ))
            .toList(),
      ),
    );
  }


  // ---- Safe readers ----

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
