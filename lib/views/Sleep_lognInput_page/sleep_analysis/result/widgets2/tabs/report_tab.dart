// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../neo_design.dart';

import '../../../../../services/api/api_service.dart';

/// ReportTab
/// - Sliver-friendly (non-scrollable), to be wrapped in SliverToBoxAdapter by parent
/// - Accepts modern map data or legacy named params (dynamic-friendly)
class ReportTab extends StatefulWidget {
  // Modern map-based
  final Map<String, dynamic>? initialReportData;
  final Future<Map<String, dynamic>> Function()? loadReport;
  final SliverOverlapAbsorberHandle? overlapHandle; // accepted but unused here

  // Legacy named params (permissive types)
  final double? totalSleepHours;
  final double? efficiency;
  final num? deepPct;
  final num? remPct;
  final num? lightPct;
  final dynamic last7DaysHours;
  final num? sleepScore;

  // Sections (legacy)
  final dynamic executiveSummary;
  final dynamic riskAssessment;
  final dynamic energyPlan;
  final dynamic wakeWindows;
  final dynamic whatIfScenarios;
  final dynamic drivers;
  final dynamic lifestyleCorrelations;
  final dynamic environmentAnalysis;
  final dynamic recommendations;
  final String? chronotype;
  final String? sleepMidpoint;

  const ReportTab({
    super.key,
    // modern
    this.initialReportData,
    this.loadReport,
    this.overlapHandle,
    // legacy metrics
    this.totalSleepHours,
    this.efficiency,
    this.deepPct,
    this.remPct,
    this.lightPct,
    this.last7DaysHours,
    this.sleepScore,
    // legacy sections
    this.executiveSummary,
    this.riskAssessment,
    this.energyPlan,
    this.wakeWindows,
    this.whatIfScenarios,
    this.drivers,
    this.lifestyleCorrelations,
    this.environmentAnalysis,
    this.recommendations,
    this.chronotype,
    this.sleepMidpoint,
  });

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {

  Future<void> _fetchOnce() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Map<String, dynamic> normalized = <String, dynamic>{};

      if (widget.loadReport != null) {
        // Use the caller-provided loader
        normalized = await widget.loadReport!.call();
      } else {
        // Default: pull latest logs and build report using ApiService
        final report = await ApiService.fetchReportForLatestLogs(historyLimit: 7);
        normalized = Map<String, dynamic>.from(report);
      }

      if (mounted) {
        setState(() {
          // Merge with any prefilled/legacy data
          _data = {...?_data, ...normalized};
          _loading = false;
        });
      }

      // Fetch historical text analysis in the background (non-blocking)
      try {
        final histRaw = await ApiService.getHistoricalSleepAnalysis(limit: 10);
        dynamic decoded;
        if (histRaw is String) {
          final s = histRaw.trimLeft();
          if (s.startsWith('[') || s.startsWith('{')) {
            decoded = jsonDecode(s);
          } else {
            decoded = null; // plain text; ignore
          }
        } else {
          decoded = histRaw;
        }
        if (mounted && decoded is List && decoded.isNotEmpty) {
          final list = <Map<String, dynamic>>[];
          for (final h in decoded) {
            if (h is Map) list.add(Map<String, dynamic>.from(h));
          }
          setState(() => _historical = list);
        }
      } catch (e) {
        debugPrint('Error fetching historical sleep analysis: $e');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }


  Map<String, dynamic>? _data;
  List<Map<String, dynamic>>? _historical;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _data = widget.initialReportData != null
        ? Map<String, dynamic>.from(widget.initialReportData!)
        : null;

    // merge legacy if present
    final legacy = _legacyParamsAsMap();
    if (legacy.isNotEmpty) {
      _data = {...?_data, ...legacy};
    }

    // Show placeholders immediately and fetch real data without requiring a
    // manual refresh.
    // If no initial data, show placeholders and fetch report once.
    if (_data == null || _data!.isEmpty) {
      _loading = true;
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
        if (widget.last7DaysHours != null) 'last7DaysHours': widget.last7DaysHours,
        if (widget.sleepScore != null) 'sleep_score': widget.sleepScore,
      };
    }

    void put(String key, dynamic value) {
      if (value != null) m[key] = value;
    }

    put('executive_summary', widget.executiveSummary);
    put('risk_assessment', widget.riskAssessment);
    put('energy_plan', widget.energyPlan);
    put('wake_windows', widget.wakeWindows);
    put('what_if_scenarios', widget.whatIfScenarios);
    put('drivers', widget.drivers);
    put('lifestyle_correlations', widget.lifestyleCorrelations);
    put('environmentAnalysis', widget.environmentAnalysis);
    put('recommendations', widget.recommendations);
    put('chronotype', widget.chronotype);
    put('sleep_midpoint', widget.sleepMidpoint);

    return m;
  }


  // ---------- small data helpers ----------
  String _readString(List<String> keys, {String fallback = ''}) {
    final map = _data;
    if (map == null) return fallback;
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v != null) return v.toString();
    }
    return fallback;
  }

  List<dynamic> _readList(List<String> keys) {
    final map = _data;
    if (map == null) return const [];
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (v is List) return List<dynamic>.from(v);
      if (v != null) return [v];
    }
    return const [];
  }

  Map<String, dynamic> _readMap(List<String> keys) {
    final map = _data;
    if (map == null) return const {};
    for (final k in keys) {
      final v = _readByPath(map, k);
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    return const {};
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

  String _titleize(String text) {
    return text
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : (w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : '')))
        .join(' ');
  }


  Widget _sectionTitle(String title, IconData icon) {
    return Row(
        children: [
          Icon(icon, color: Colors.white, size: 16.r),
          SizedBox(width: 8.w),
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5.sp)),
        ]);
  }
// ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              if (_loading) _SkeletonList(),
              if (_error != null) _ErrorBox(error: _error),

              if (!_loading && _error == null) ...[
                _buildExecutiveSummary(theme),
                SizedBox(height: 12.h),
                _buildKeyMetrics(theme),
                SizedBox(height: 12.h),
                _buildTrendsAndDebt(theme),
                SizedBox(height: 12.h),
                _buildChronotypeQuick(theme),
                SizedBox(height: 12.h),
                _buildRiskHotspots(theme),
                SizedBox(height: 12.h),
                _buildRiskAssessment(theme),
                SizedBox(height: 12.h),
                _buildDynamicFactors(theme),
                SizedBox(height: 12.h),
                _buildActionCenter(theme),
                SizedBox(height: 12.h),
                _buildEnergyPlan(theme),
                SizedBox(height: 12.h),
                _buildWakeWindows(theme),
                SizedBox(height: 12.h),
                _buildWhatIfScenarios(theme),
                SizedBox(height: 24.h),
              ],
            ])));
  }
  Widget _EmptyText(String message) {
    return Center(
        child: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 16)));
  }


  Widget _buildExecutiveSummary(ThemeData theme) {
    List bullets = _readList(['executive_summary.bullets', 'executiveSummary.bullets']);
    String textBlob = _readString(['executive_summary.text', 'executiveSummary.text']);
// If not provided as nested .text, accept a direct string too
    if (textBlob.isEmpty) {
      final direct = _readString(['executive_summary', 'executiveSummary', 'summary', 'overview']);
      if (direct.isNotEmpty) textBlob = direct;
    }

    // flatten code fences & json-ish
    if ((textBlob.isEmpty || textBlob == 'null') && bullets.isNotEmpty) { textBlob = bullets.map((e)=> e.toString()).join('\n'); }
    String plainText(String t) {
      t = t
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n|```$', multiLine: true), '')
          .trim();
      try {
        final dynamic decoded = jsonDecode(t);
        return _flattenJson(decoded);
      } catch (_) {
        final looksJson = RegExp(r'^[\s\n]*[\{\[]').hasMatch(t) &&
            RegExp(r'[\}\]]\s*$').hasMatch(t);
        if (looksJson) {
          t = t.replaceAll(RegExp(r'[\{\}\[\]\" ]'), '').replaceAll(',', '\n').replaceAll(':', ': ');
        }
        return t;
      }
    }

    if (bullets.isEmpty && textBlob.isEmpty) {
      // synth from risk/energy if possible
      final riskMap = _readMap(['risk_assessment', 'riskAssessment', 'risks', 'risk']);
      final energyMap = _readMap(['energy_plan', 'energyPlan']);
      final synth = <String>[];
      final riskLevel = riskMap['level']?.toString();
      final energyTip = energyMap['advice']?.toString();
      if (riskLevel != null) synth.add('Risk level: ${_titleize(riskLevel)}');
      if (energyTip != null) synth.add('Energy tip: $energyTip');
      bullets = synth;
    }


    // Raw-dump fallback if empty

    if (!(bullets.isNotEmpty || (textBlob.trim().isNotEmpty))) {
      return _SectionCard(
          title: 'Executive Summary',
          subtitle: 'Fast overview for today',
          child: _EmptyText('No summary available yet.'));
    }

    return _SectionCard(
        title: 'Executive Summary',
        subtitle: 'Fast overview for today',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bullets.isNotEmpty) ...[
                for (final b in bullets)
                  Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('• ', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                        Expanded(
                            child: Text(b.toString(),
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white))),
                      ])),
              ] else if (textBlob.isNotEmpty) ...[
                Text(plainText(textBlob),
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              ] else
                _EmptyText('No summary available yet.'),
            ]));
  }

  Widget _buildKeyMetrics(ThemeData theme) {
    final m = _readMap(['metrics']);
    final total = (m['total_sleep_hours'] ?? widget.totalSleepHours) as num?;
    final eff = (m['sleep_efficiency'] ?? widget.efficiency) as num?;
    final deep = (m['deep_pct'] ?? widget.deepPct) as num?;
    final rem = (m['rem_pct'] ?? widget.remPct) as num?;
    final light = (m['light_pct'] ?? widget.lightPct) as num?;
    final score = (m['sleep_score'] ?? widget.sleepScore) as num?;

    final items = <_MetricItem>[
      _MetricItem(label: 'Duration', value: total != null ? '${total.toStringAsFixed(2)} h' : '—'),
      _MetricItem(label: 'Efficiency', value: eff != null ? '${eff.toStringAsFixed(1)} %' : '—'),
      _MetricItem(label: 'Deep', value: deep != null ? '${deep.toString()} %' : '—'),
      _MetricItem(label: 'REM', value: rem != null ? '${rem.toString()} %' : '—'),
      _MetricItem(label: 'Light', value: light != null ? '${light.toString()} %' : '—'),
      _MetricItem(label: 'Score', value: score != null ? score.toStringAsFixed(1) : '—'),
    ];

    return _SectionCard(
        title: 'Sleep Efficiency & Stages',
        subtitle: 'Core quality indicators',
        child: _MetricsGrid(items: items));
  }

  Widget _buildTrendsAndDebt(ThemeData theme) {
    final List<double> scoreSeries = [];
    final List<double> effSeries = [];
    final List<double> hoursSeries = [];

    for (final h in _historical ?? const <Map<String, dynamic>>[]) {
      try {
        final m = (h['metrics'] ?? {}) as Map;
        final s = m['sleep_score'] ?? h['sleepScore'] ?? h['score'];
        final e = m['sleep_efficiency'] ?? h['efficiency'];
        final t = m['total_sleep_hours'] ?? h['totalSleepHours'] ?? h['hours'];
        if (s is num) scoreSeries.add(s.toDouble());
        if (e is num) effSeries.add(e.toDouble());
        if (t is num) hoursSeries.add(t.toDouble());
      } catch (_) {}
    }

    if (scoreSeries.isEmpty && effSeries.isEmpty && hoursSeries.isEmpty) {
      // fallback from metrics.last7DaysHours if provided
      for (final v in _readList(['metrics.last7DaysHours', 'last7DaysHours'])) {
        if (v is num) hoursSeries.add(v.toDouble());
      }
    }

    final hasAnything = scoreSeries.length >= 2 || effSeries.length >= 2 || hoursSeries.length >= 2;
    if (!hasAnything) return SizedBox.shrink();

    // Weekly sleep debt vs 7.5h target
    final target = 7.5;
    double debt = 0.0;
    final recent = hoursSeries.take(7).toList();
    for (final h in recent) {
      debt += (target - h);
    }
    final debtStr = (debt >= 0 ? '+' : '−') + debt.abs().toStringAsFixed(1) + 'h';

    return _SectionCard(
        title: 'Trends & Sleep Debt',
        subtitle: 'Mini history and weekly balance',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scoreSeries.length >= 2) _TrendTile(title: 'Sleep Score', series: scoreSeries, unit: ''),
              if (effSeries.length >= 2) SizedBox(height: 8.h),
              if (effSeries.length >= 2) _TrendTile(title: 'Efficiency', series: effSeries, unit: '%'),
              if (hoursSeries.length >= 2) SizedBox(height: 8.h),
              if (hoursSeries.length >= 2) _TrendTile(title: 'Duration', series: hoursSeries, unit: 'h'),
              SizedBox(height: 10.h),
              Row(
                  children: [
                    _impactDot(debt >= 0 ? 'negative' : 'positive', size: 10),
                    SizedBox(width: 8.w),
                    Text('Weekly Sleep Debt: ', style: theme.textTheme.labelLarge),
                    Text(debtStr, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  ]),
            ]));
  }

  Widget _buildChronotypeQuick(ThemeData theme) {
    final chronotype = _readString(['chronotype']);
    final midpoint = _readString(['sleep_midpoint', 'sleepMidpoint']);
    if (chronotype.isEmpty && midpoint.isEmpty) return SizedBox.shrink();

    return _SectionCard(
        title: 'Chronotype & Midpoint',
        subtitle: 'Personal rhythm snapshot',
        child: Row(
            children: [
              if (chronotype.isNotEmpty) _Chip(text: _titleize(chronotype)),
              if (chronotype.isNotEmpty && midpoint.isNotEmpty) SizedBox(width: 8.w),
              if (midpoint.isNotEmpty) _Chip(text: 'Midpoint $midpoint'),
            ]));
  }

  Widget _buildRiskHotspots(ThemeData theme) {
    final comp = _readMap(['risk_assessment.components', 'riskAssessment.components']);
    if (comp.isEmpty) return SizedBox.shrink();

    final entries = <MapEntry<String, double>>[];
    comp.forEach((k, v) {
      double val = 0.0;
      if (v is num) val = v.toDouble();
      else if (v is String) {
        final s = v.replaceAll('%', '');
        val = double.tryParse(s) ?? 0.0;
        if (v.contains('%')) val = val / 100.0;
      }
      entries.add(MapEntry(k.toString(), val.abs()));
    });
    entries.sort((a, b) => b.value.compareTo(a.value));

    return _SectionCard(
        title: 'Risk Hotspots',
        subtitle: 'Where to focus first',
        child: LayoutBuilder(
            builder: (context, constraints) {
              final total = entries.fold<double>(0.0, (p, e) => p + e.value);
              if (total <= 0) return _EmptyText('No components found.');
              return Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.2))),
                  child: Row(
                      children: [
                      for (final e in entries) ...[
              Expanded(
              flex: (e.value * 1000).round().clamp(1, 1000),
              child: Container(
              height: 18.h,
              decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(6.r)),
              alignment: Alignment.center,
              child: Text(
              _titleize(e.key.replaceAll('_', ' ')),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700))),
              )],
              ]));
            }));
  }

  Widget _buildRiskAssessment(ThemeData theme) {
    // Read multiple aliases and shapes
    final ra = _readMap(['risk_assessment', 'riskAssessment', 'risks', 'risk']);
    List risks = _readList(['risk_assessment.risks', 'risk_assessment.hotspots', 'riskAssessment.hotspots', 'risks', 'risk']);
    final level = ra['level']?.toString();
    final score = ra['score'] is num ? (ra['score'] as num).toDouble() : null;
    final advice = (ra['advice'] ?? ra['notes'] ?? ra['note'])?.toString();


    if (!(risks.isNotEmpty || (level != null && level.toString().isNotEmpty) ||
        (advice != null && advice!.trim().isNotEmpty) || score != null)) {
      return _SectionCard(
          title: 'Risk Assessment',
          subtitle: 'Potential sleep disruptors',
          child: _EmptyText('No risk assessment available.'));
    }

    return _SectionCard(
        title: 'Risk Assessment',
        subtitle: 'Potential sleep disruptors',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (level != null || score != null)
                Row(children: [
                  if (level != null) _Chip(text: _titleize(level)),
                  if (score != null)
                    ...[SizedBox(width: 8.w),
                      _Chip(text: 'Score ${score.toStringAsFixed(0)}')],
                ]),
              if (advice != null && advice.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(advice,
                    style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              ],
              SizedBox(height: 8.h),
              if (risks.isEmpty)
                _EmptyText('No notable risks detected.')
              else
                ...risks.map((r) {
                  if (r is Map) {
                    final title =
                    (r['title'] ?? r['name'] ?? 'Risk').toString();
                    final impact =
                    (r['impact'] ?? r['effect'] ?? '').toString();
                    return Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 18.r),
                              SizedBox(width: 8.w),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                        if (impact.trim().isNotEmpty)
                                          Text(impact,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(color: Colors.white)),
                                  ])),
                            ]));
                  } else {
                    return Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(children: [
                          Icon(Icons.warning_amber_rounded, size: 18.r),
                          SizedBox(width: 8.w),
                          Expanded(
                              child: Text(r.toString(),
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white))),
                        ]));
                  }
                }).toList(),
            ]));
  }
  Widget _buildDynamicFactors(ThemeData theme) {
    final List<_FactorEntry> factors = [];

    // drivers
    for (final d in _readList(['drivers', 'key_factors', 'contributors', 'top_drivers'])) {
      if (d is String) {
        factors.add(_FactorEntry(label: _titleize(d), impact: _inferImpactFromLabel(d)));
      } else if (d is Map) {
        final map = Map<String, dynamic>.from(d);
        final name = (map['name'] ?? map['label'] ?? map['factor'] ?? '').toString();
        final impact = (map['impact'] ?? map['direction'] ?? map['polarity'] ?? 'neutral').toString();
        final score = _toDouble(map['score'] ?? map['weight'] ?? map['strength']);
        final tip = map['tip']?.toString();
        if (name.isNotEmpty) {
          factors.add(_FactorEntry(label: _titleize(name), impact: impact, score: score, tip: tip));
        }
      }
    }

    // lifestyle correlations
    final lcMap = _readMap(['lifestyle_correlations', 'lifestyleCorrelations']);
    if (lcMap.isNotEmpty) {
      lcMap.forEach((k, v) {
        String impact = 'neutral';
        double? score;
        if (v is num) {
          score = v.toDouble();
          impact = score >= 0 ? 'positive' : 'negative';
        } else if (v is Map) {
          final mv = Map<String, dynamic>.from(v);
          score = _toDouble(mv['score'] ?? mv['correlation'] ?? mv['value']);
          impact = (mv['impact'] ?? mv['direction'] ?? (score != null && score >= 0 ? 'positive' : 'negative')).toString();
        }
        factors.add(_FactorEntry(label: _titleize(k.toString().replaceAll('_', ' ')), impact: impact, score: score));
      });
    } else {
      final lcList = _readList(['lifestyle_correlations', 'lifestyleCorrelations']);
      for (final item in lcList) {
        if (item is Map) {
          final label = (item['label'] ?? item['name'] ?? item['key'] ?? '').toString();
          final val = item['value'];
          String impact = 'neutral';
          double? score;
          if (val is num) { score = val.toDouble(); impact = score >= 0 ? 'positive' : 'negative'; }
          final tip = item['tip']?.toString();
          if (label.isNotEmpty) {
            factors.add(_FactorEntry(label: _titleize(label), impact: impact, score: score, tip: tip));
          }
        }
      }
    }

    // environment factors
    final envFactors = _readMap(['environment_analysis.factors', 'environmentAnalysis.factors']);
    envFactors.forEach((k, v) {
      final valStr = v?.toString() ?? '';
      if (valStr.isNotEmpty) {
        factors.add(_FactorEntry(label: _titleize(k.toString().replaceAll('_', ' ')), impact: 'neutral', tip: valStr));
      }
    });

    // de-dup
    final seen = <String>{};
    final deduped = <_FactorEntry>[];
    for (final f in factors) {
      final key = f.label.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        deduped.add(f);
      }
    }

    if (deduped.isEmpty) {
      return _SectionCard(
          title: 'Dynamic Factors',
          subtitle: 'What’s shaping tonight’s sleep',
          child: _EmptyText('Add more sleep logs to unlock your personalized factor map.'));
    }

    return _SectionCard(
        title: 'Dynamic Factors',
        subtitle: 'What’s shaping tonight’s sleep',
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [
                  for (final f in deduped) ...[
                    _DynamicFactorTile(
                        entry: f,
                        onTap: () {
                          final tips = _readMap(['recommendations', 'tips']);
                          final List<String> recs = [];
                          if (tips.isNotEmpty) {
                            final key = f.label.toLowerCase().replaceAll(' ', '_');
                            final v = tips[key] ?? tips[f.label] ?? tips[key.replaceAll('_', '')];
                            if (v is List) {
                              for (final t in v) {
                                if (t != null) recs.add(t.toString());
                              }
                            } else if (v is String) {
                              recs.add(v);
                            }
                          }
                          _showFactorTipsSheet(context, f, recs);
                        }),
                    SizedBox(width: 10.w),
                  ]
                ])));
  }

  void _showFactorTipsSheet(BuildContext context, _FactorEntry f, List<String> recs) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
        builder: (context) {
          final theme = Theme.of(context);
          return Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        children: [
                          _impactDot(f.impact, size: 12),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: Text(f.label, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))),
                          if (f.score != null)
                            Text('${(f.score! >= 0 ? '+' : '')}${f.score!.toStringAsFixed(2)}', style: theme.textTheme.labelLarge),
                        ]),
                    if (f.tip != null && f.tip!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(f.tip!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    ],
                    if (recs.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text('Suggestions', style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8.h),
                      for (final r in recs) Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                Expanded(child: Text(r, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white))),
                              ])),
                    ],
                  ]));
        });
  }

  Widget _buildActionCenter(ThemeData theme) {
    final actions = <String>[];
    for (final x in _readList(['action_items', 'actions', 'next_actions'])) {
      if (x is String) actions.add(x);
      else if (x is Map) {
        final t = (x['text'] ?? x['title'] ?? x['action'])?.toString();
        if (t != null && t.isNotEmpty) actions.add(t);
      }
    }
    if (actions.isEmpty) {
      for (final r in _readList(['recommendations', 'tips'])) {
        if (r is String) actions.add(r);
      }
    }
    if (actions.isEmpty) return SizedBox.shrink();

    return _SectionCard(
        title: 'Action Center',
        subtitle: 'Quick wins for tonight',
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [
                  for (final t in actions) ...[
                    _ActionItemTile(text: t),
                    SizedBox(width: 10.w),
                  ],
                ])));
  }

  Widget _buildEnergyPlan(ThemeData theme) {
    // Accept multiple aliases and shapes
    final e = _readMap(['energy_plan', 'energyPlan', 'daily_energy_plan', 'dailyEnergyPlan', 'energy']);
    final blocksRaw = e['plan'] ?? e['blocks'] ?? e['schedule'] ?? e['items'];
    final advice = (e['advice'] ?? e['note'] ?? e['notes'])?.toString();
    final blocksList = (blocksRaw is List) ? List.from(blocksRaw) : (blocksRaw != null ? [blocksRaw] : <dynamic>[]);
    final blocks = blocksList.map((b) {
      if (b is Map) {
        final start = b['start'] ?? b['from'] ?? b['begin'];
        final end = b['end'] ?? b['to'] ?? b['finish'];
        final timeRange = (b['time_range'] ?? b['timeRange'] ?? (start != null && end != null ? '$start–$end' : null))?.toString();
        return {
          'time_range': timeRange,
          'action': (b['action'] ?? b['title'] ?? b['task'] ?? b['activity'] ?? 'Activity').toString(),
          'rationale': (b['rationale'] ?? b['why'] ?? b['detail'] ?? b['explanation'] ?? '').toString(),
        };
      }
      return {'time_range': null, 'action': b.toString(), 'rationale': ''};
    }).toList();

    if (blocks.isEmpty && (advice == null || advice.trim().isEmpty)) {

      // Raw-dump fallback if nothing to show

      return _SectionCard(
          title: 'Daily Energy Plan',
          subtitle: 'How to pace your day',
          child: _EmptyText(
              'Add more sleep logs to unlock a personalized plan.'));
    }

    return _SectionCard(
        title: 'Daily Energy Plan',
        subtitle: 'How to pace your day',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (advice != null && advice.trim().isNotEmpty)
                Text(advice, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              if (blocks.isNotEmpty) ...[
                SizedBox(height: 10.h),
                ...blocks.map((b) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bolt_rounded, size: 18.r),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    b['time_range']?.toString() ?? '—',
                                    style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                Text(
                                    b['action']?.toString() ?? '',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                                if ((b['rationale'] ?? '').toString().trim().isNotEmpty)
                                  Text(
                                      b['rationale']?.toString() ?? '',
                                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                                SizedBox(height: 8.h),
                              ])),
                    ]))
              ],
            ]));
  }
  Widget _buildWakeWindows(ThemeData theme) {
    final _wwTop = _readList([
      'wake_windows',
      'wakeWindows',
      'wakeUpWindows',
      'suggested_wake_windows',
      'suggestedWakeWindows'
    ]);
    final ww =
    _wwTop.isNotEmpty ? _wwTop : _readList(['wake_windows.windows', 'wakeWindows.windows']);
    if (ww.isEmpty) {
      return _SectionCard(
          title: 'Suggested Wake Windows',
          subtitle: 'Best times to wake up',
          child: _EmptyText('No wake windows available.'));
    }
    return _SectionCard(
        title: 'Suggested Wake Windows',
        subtitle: 'Best times to wake up',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ww.map((w) {
              if (w is Map) {
                final start = (w['start'] ?? w['from'] ?? w['window_start'] ?? '').toString();
                final end = (w['end'] ?? w['to'] ?? w['window_end'] ?? '').toString();
                final type = (w['type'] ?? w['label'] ?? '').toString();
                final line = '${start.isNotEmpty ? start : '—'} – ${end.isNotEmpty ? end : '—'}'
                    '${type.isNotEmpty ? '  ($type)' : ''}';
                return Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(line, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)));
              } else {
                return Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(w.toString(), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)));
              }
            }).toList()));
  }

  Widget _buildWhatIfScenarios(ThemeData theme) {
    // Accept multiple aliases and shapes
    dynamic scenariosDyn = _readList([
      'what_if_scenarios',
      'whatIfScenarios',
      'what_if',
      'whatIf',
      'scenarios'
    ]);

    List scenarios = (scenariosDyn is List)
        ? List.from(scenariosDyn)
        : (scenariosDyn != null ? [scenariosDyn] : <dynamic>[]);

    // Expand nested {scenarios:[...]} shape
    if (scenarios.length == 1 &&
        scenarios.first is Map &&
        (scenarios.first['scenarios'] is List)) {
      scenarios = List.from(scenarios.first['scenarios']);
    }

    if (scenarios.isEmpty) {


      return _SectionCard(
          title: 'What-If Scenarios',
          subtitle: 'Small changes, predicted impact',
          child: _EmptyText(
              'No scenarios yet. Add more logs to unlock simulations.'));
    }



    return _SectionCard(
        title: 'What-If Scenarios',
        subtitle: 'Small changes, predicted impact',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: scenarios.map((s) {
              if (s is Map) {
                return _WhatIfTile(
                    title: (s['title'] ?? s['change'] ?? 'Scenario').toString(),
                    impact: (s['impact'] ?? s['effect'] ?? s['result'])?.toString(),
                    detail: (s['detail'] ?? s['explanation'] ?? s['why'])?.toString());
              } else {
                return _WhatIfTile(title: s.toString());
              }
            }).toList()));
  }

// helpers
  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  String _inferImpactFromLabel(String s) {
    final l = s.toLowerCase();
    if (l.contains('caffeine') || l.contains('screen') || l.contains('late') || l.contains('stress')) return 'negative';
    if (l.contains('walk') || l.contains('exercise') || l.contains('sun') || l.contains('wind down') || l.contains('tea')) return 'positive';
    return 'neutral';
  }

  String _flattenJson(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    if (v is List) {
      return v.map((e) => '- ${_flattenJson(e)}').join('\n');
    }
    if (v is Map) {
      final b = StringBuffer();
      v.forEach((k, val) {
        final key = k.toString();
        final child = _flattenJson(val);
        if (child.contains('\n')) {
          b.writeln('$key:');
          for (final line in child.split('\n')) {
            b.writeln('  $line');
          }
        } else {
          b.writeln('$key: $child');
        }
      });
      return b.toString().trimRight();
    }
    return v.toString();
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;

  const _SectionCard({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
  }) : super(key: key);

  IconData _guessIcon() {
    final t = title.toLowerCase();
    if (t.contains('summary')) return Icons.auto_awesome;
    if (t.contains('metric')) return Icons.speed;
    if (t.contains('risk')) return Icons.health_and_safety;
    if (t.contains('energy')) return Icons.battery_full;
    if (t.contains('wake')) return Icons.alarm;
    if (t.contains('what') && t.contains('if')) return Icons.science;
    if (t.contains('driver') || t.contains('insight')) return Icons.insights;
    if (t.contains('trend') || t.contains('history')) return Icons.trending_up;
    return Icons.widgets_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final ic = icon ?? _guessIcon();
    return NeoCard(
        padding: EdgeInsets.all(16.r),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                SizedBox(height: 6.h),
                Text(
                    subtitle!,
                    style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.w500)),
              ],
              SizedBox(height: 12.h),
              DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
            ]));
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
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35))),
        child: Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontSize: 12.5.sp)));
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
          final isWide = constraints.maxWidth >= 520;
          final cross = isWide ? 3 : 2;
          return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  mainAxisExtent: 96.h),
              itemBuilder: (context, i) {
                final it = items[i];
                return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.25))),
                    child: Row(
                        children: [
                          Container(
                              width: 36.w, height: 36.w, constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withOpacity(.12)),
                              alignment: Alignment.center,
                              child: Icon(Icons.brightness_7_outlined, size: 18, color: Colors.white)),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(it.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
                                    SizedBox(height: 2.h),
                                    Text(it.value, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.sp)),
                                  ])),
                        ]));
              });
        });
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
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.25))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  children: [
                    Icon(Icons.psychology_alt_outlined, size: 18),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                    if (impact != null) _Chip(text: impact!),
                  ]),
              if (detail != null) ...[
                SizedBox(height: 6.h),
                Text(detail!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              ],
            ]));
  }
}

class _ActionItemTile extends StatefulWidget {
  final String text;
  const _ActionItemTile({super.key, required this.text});

  @override
  State<_ActionItemTile> createState() => _ActionItemTileState();
}

class _ActionItemTileState extends State<_ActionItemTile> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
        onTap: () => setState(() => done = !done),
        child: Container(
            constraints: BoxConstraints(minWidth: 200.w),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.25)),
                color: done ? Colors.green.withOpacity(.12) : theme.colorScheme.surface.withOpacity(.8)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? Colors.greenAccent : Colors.white),
                  SizedBox(width: 10.w),
                  Expanded(
                      child: Text(
                          widget.text,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                              fontWeight: FontWeight.w600))),
                ])));
  }
}

class _DynamicFactorTile extends StatelessWidget {
  final _FactorEntry entry;
  final VoidCallback? onTap;
  const _DynamicFactorTile({Key? key, required this.entry, this.onTap}) : super(key: key);

  Color _bg(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    switch (entry.impact.toLowerCase()) {
      case 'positive': return c.primary.withOpacity(0.12);
      case 'negative': return Colors.redAccent.withOpacity(0.12);
      default: return c.secondary.withOpacity(0.10);
    }
  }

  Color _fg(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    switch (entry.impact.toLowerCase()) {
      case 'positive': return c.primary;
      case 'negative': return Colors.redAccent;
      default: return c.secondary;
    }
  }

  String _valueText() {
    if (entry.score != null) {
      final s = entry.score!;
      final sign = s >= 0 ? '+' : '';
      return '$sign${s.toStringAsFixed(2)}';
    }
    return entry.tip ?? 'Tap for tips';
  }

  IconData _icon() {
    final l = entry.label.toLowerCase();
    if (l.contains('caffeine') || l.contains('coffee')) return Icons.local_cafe_outlined;
    if (l.contains('screen') || l.contains('phone') || l.contains('blue light')) return Icons.phone_iphone_outlined;
    if (l.contains('stress') || l.contains('anxiety')) return Icons.bolt_outlined;
    if (l.contains('exercise') || l.contains('walk') || l.contains('workout')) return Icons.directions_run_outlined;
    if (l.contains('sun') || l.contains('light')) return Icons.wb_sunny_outlined;
    if (l.contains('noise')) return Icons.volume_up_outlined;
    if (l.contains('temperature') || l.contains('temp')) return Icons.thermostat_outlined;
    if (l.contains('alcohol')) return Icons.local_bar_outlined;
    if (l.contains('hydration') || l.contains('water')) return Icons.water_drop_outlined;
    return Icons.insights_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final text = _valueText();
    return Semantics(
        label: '${entry.label} factor: $text',
        child: GestureDetector(
            onTap: onTap,
            child: Container(
                width: 180.w,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(.25)),
                    color: _bg(context)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                children: [
                Icon(_icon(), size: 18.sp, color: _fg(context)),
            SizedBox(width: 8.w),
            Expanded(
                child: Text(entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5.sp)),
    )]),
            SizedBox(height: 8.h),
            Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 4.h),
            Row(
                children: [
                  _impactDot(entry.impact, size: 10),
                  SizedBox(width: 6.w),
                  Text(
                      entry.impact[0].toUpperCase() + entry.impact.substring(1),
                      style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                ]),
            ]))));
  }
}

class _FactorEntry {
  final String label;
  final String impact; // positive | negative | neutral
  final double? score; // optional numeric effect/correlation
  final String? tip;   // optional description
  _FactorEntry({required this.label, required this.impact, this.score, this.tip});
}

Widget _impactDot(String impact, {double size = 8}) {
  Color color;
  switch (impact.toLowerCase()) {
    case 'positive': color = Colors.greenAccent; break;
    case 'negative': color = Colors.redAccent; break;
    default: color = Colors.blueAccent; break;
  }
  return Container(
      width: size.w, height: size.w,
      decoration: BoxDecoration(color: color.withOpacity(.9), shape: BoxShape.circle));
}

class _TrendTile extends StatelessWidget {
  final String title;
  final List<double> series;
  final String unit;
  const _TrendTile({super.key, required this.title, required this.series, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = series.isNotEmpty ? series.first : 0.0;
    final last = series.isNotEmpty ? series[series.length - 1] : 0.0;
    final delta = last - first;
    final deltaStr = (delta >= 0 ? '+' : '−') + delta.abs().toStringAsFixed(2) + (unit.isNotEmpty ? unit : '');

    return Row(
        children: [
          Expanded(
              child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.25)),
                      borderRadius: BorderRadius.circular(14.r)),
                  child: CustomPaint(
                      painter: _MiniSparkline(series),
                      child: SizedBox.expand()))),
          SizedBox(width: 10.w),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
                Text(
                    '${last.toStringAsFixed(2)}${unit.isNotEmpty ? unit : ''}',
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                Text(deltaStr, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
              ]),
        ]);
  }
}

class _MiniSparkline extends CustomPainter {
  final List<double> series;
  _MiniSparkline(this.series);

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;
    final maxV = series.reduce((a, b) => a > b ? a : b);
    final minV = series.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
    final dx = size.width / (series.length - 1);

    final path = Path();
    for (int i = 0; i < series.length; i++) {
      final x = i * dx;
      final norm = (series[i] - minV) / range;
      final y = size.height - norm * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(.9);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heights = [
      100.h, // executive summary
      80.h, // key metrics
      100.h, // trends & debt
      80.h, // chronotype
      120.h, // risk hotspots
      100.h, // risk assessment
      120.h, // dynamic factors
      100.h, // action center
      100.h, // energy plan
      100.h, // wake windows
      100.h, // what-if scenarios
    ];
    return Column(
        children: [
        for (final h in heights)
    Container(
            margin: EdgeInsets.only(bottom: 12.h),
        height: h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white10))
        ]);
  }
}

class _ErrorBox extends StatelessWidget {
  final String? error;
  const _ErrorBox({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
    color: Colors.red.withOpacity(.08),
    border: Border.all(color: Colors.red.withOpacity(.2))),
    child: Text(error ?? 'Unknown error', style: TextStyle(color: Colors.white)));
  }
}//