// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// ReportTab
/// A compact, engaging report UI built for *quick scanning* rather than long text.
///
/// Highlights:
/// - TL;DR summary card (short bullets)
/// - KPI chips (Total sleep, Efficiency, Deep/REM %)
/// - Composition Donut
/// - 7‑day Trend Sparkline + Streaks
/// - "What changed?" delta chips
/// - Actionable tips with checkboxes (persist within the widget’s lifetime)
/// - Export to image (no external packages)
/// - Keeps state when switching tabs (AutomaticKeepAliveClientMixin)
class ReportTab extends StatefulWidget {
  /// Optional direct values. If null, the section hides gracefully.
  final double? totalSleepHours; // e.g., 7.8
  final double? efficiency; // 0..100
  final int? awakenings; // count
  final double? deepPct; // 0..100
  final double? remPct; // 0..100
  final double? lightPct; // 0..100

  /// 7-day history of total sleep hours for sparkline (oldest -> latest).
  final List<double>? last7DaysHours;

  /// Deltas vs. yesterday or previous period. Positive = better (unless noted otherwise).
  /// Keys you can pass: totalSleep, efficiency, deepPct, remPct, awakenings (negative is better)
  final Map<String, double>? deltas;

  /// Short bullet points or AI-generated TL;DR lines (keep them snappy).
  final List<String>? tldrBullets;

  /// If provided, called with a PNG of the whole report (for sharing).
  final void Function(Uint8List bytes)? onExportPng;
  // === New optional inputs from other sections ===
  final int? sleepScore; // 0..100
  final Map<String, dynamic>? dailyComparison; // flexible keys
  final List<Map<String, dynamic>>? lifestyleCorrelations; // list of {name/factor, value/r}
  final Map<String, dynamic>? environmentAnalysis; // {noise, light, temp, air_quality, ...}
  final Map<String, dynamic>? dreamMoodForecast; // original forecast map
  final List<String>? aiHighlights; // from insights
  final List<String>? recommendations; // short strings
  final String? chronotype; // e.g., 'Bear'
  final String? sleepMidpoint; // e.g., '03:45'
  final int? morningReadiness; // 0..100 (approx)
  final List<Map<String, dynamic>>? whatIfScenarios; // [{label, delta_score, description}]
  final List<dynamic>? wakeWindows; // e.g., ['07:10–07:30', ...] or [{'from':'07:10','to':'07:30'}]
  final Map<String, dynamic>? riskAssessment; // {'risk_score':.., 'alerts':[...]}
  final Map<String, dynamic>? energyPlan; // {'light':'..','caffeine_cutoff':'..','nap_window':'..','notes':[...]}
  final Map<String, dynamic>? drivers; // {'positive':[],'negative':[]}
  final List<Map<String, dynamic>>? achievements; // [{'name':..,'progress':..}]
  final Map<String, dynamic>? hrvSummary; // {'rmssd':..,'sdnn':..,'balance':..}
  final Map<String, dynamic>? respiratory; // {'ahi':..,'events':..,'snore_index':..}
  final Map<String, dynamic>? glucoseCorrelation; // {'corr':..,'notes':..}
  final List<String>? actionItems; // actionable to-dos from API
  final Map<String, dynamic>? causalGraph; // {'nodes':[{id,label,score}], 'edges':[{from,to,weight}]}
  final Map<String, dynamic>? energyTimeline; // {'segments':[{'start':'09:00','end':'11:00','label':'focus','intensity':0.8}]}
  final List<dynamic>? cognitiveWindows; // ['09:00–11:00', ...] or [{'from':'','to':'','label':''}]
  final Map<String, dynamic>? microArousals; // {'index':..,'count':..,'notes':[]}
  final List<dynamic>? architectureNotes; // list of strings or maps with 'stage','note'
  final Map<String, dynamic>? recoveryPlan; // {'score':..,'steps':[]}
  final Map<String, dynamic>? nutrition; // {'corr':..,'advice':[]}
  final List<dynamic>? streaks; // [{'name':..,'days':..}]
  final List<String>? smartGoals; // SMART goals from API

  const ReportTab({
    super.key,
    this.totalSleepHours,
    this.efficiency,
    this.awakenings,
    this.deepPct,
    this.remPct,
    this.lightPct,
    this.last7DaysHours,
    this.deltas,
    this.tldrBullets,
    this.onExportPng,
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
  });

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey _captureKey = GlobalKey();

  // What‑if simulator local state
  double _simBedtimeEarlierMin = 0; // 0..120
  double _simScreenReduceMin = 0;   // 0..120
  double _simCaffCutoffHours = 0;   // 0..3


  // Local state for actionable tips.
  final Map<String, bool> _tipDone = {
    'Get sunlight within 1h of waking ☀️': false,
    'Avoid screens 60m before bed 📵': false,
    'Cut caffeine after 2pm ☕': false,
    'Keep bedroom cool & dark 🛏️': false,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;

    // Prepare safe values.
    final total = widget.totalSleepHours;
    final eff = widget.efficiency;
    final deep = widget.deepPct;
    final rem = widget.remPct;
    final light = widget.lightPct;
    final awaken = widget.awakenings;
    final history = (widget.last7DaysHours ?? []).where((e) => e.isFinite).toList();

    return RepaintBoundary(
      key: _captureKey,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1022),
              const Color(0xFF0B0C1A),
              const Color(0xFF0E1030),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerRow(context),
                SizedBox(height: 12),
                if (_hasAnyKpi(total, eff, deep, rem, awaken))
                  _kpiRow(context, total, eff, deep, rem, awaken),
                SizedBox(height: 12),
                _cardsPager(context, total, deep, rem, light, history),
                SizedBox(height: 12),
                // Likely drivers
                if ((widget.drivers ?? const {}).isNotEmpty) ...[
                  _driversFromApi(context),
                  SizedBox(height: 12),
                ],
                // HRV summary
                if ((widget.hrvSummary ?? const {}).isNotEmpty) ...[
                  _hrvCard(context),
                  SizedBox(height: 12),
                ],
                // Respiratory events
                if ((widget.respiratory ?? const {}).isNotEmpty) ...[
                  _respiratoryCard(context),
                  SizedBox(height: 12),
                ],
                // Glucose correlation
                if ((widget.glucoseCorrelation ?? const {}).isNotEmpty) ...[
                  _glucoseCard(context),
                  SizedBox(height: 12),
                ],
                // Achievements
                if ((widget.achievements ?? const []).isNotEmpty) ...[
                  _achievementsCard(context),
                  SizedBox(height: 12),
                ],
                // Action items
                if ((widget.smartGoals ?? const []).isNotEmpty) ...[
                  _smartGoalsCard(context),
                  SizedBox(height: 12),
                ],
                if ((widget.actionItems ?? const []).isNotEmpty) ...[
                  _actionItemsCard(context),
                  SizedBox(height: 12),
                ],
                // Causal graph
                if ((widget.causalGraph ?? const {}).isNotEmpty) ...[
                  _causalGraphCard(context),
                  SizedBox(height: 12),
                ],
                // Energy timeline
                if ((widget.energyTimeline ?? const {}).isNotEmpty) ...[
                  _energyTimelineCard(context),
                  SizedBox(height: 12),
                ],
                // Cognitive windows
                if ((widget.cognitiveWindows ?? const []).isNotEmpty) ...[
                  _cognitiveWindowsCard(context),
                  SizedBox(height: 12),
                ],
                // Micro‑arousals
                if ((widget.microArousals ?? const {}).isNotEmpty) ...[
                  _microArousalsCard(context),
                  SizedBox(height: 12),
                ],
                // Architecture notes
                if ((widget.architectureNotes ?? const []).isNotEmpty) ...[
                  _architectureNotesCard(context),
                  SizedBox(height: 12),
                ],
                // Recovery plan
                if ((widget.recoveryPlan ?? const {}).isNotEmpty) ...[
                  _recoveryPlanCard(context),
                  SizedBox(height: 12),
                ],
                // Nutrition
                if ((widget.nutrition ?? const {}).isNotEmpty) ...[
                  _nutritionCard(context),
                  SizedBox(height: 12),
                ],
                // Streaks
                if ((widget.streaks ?? const []).isNotEmpty) ...[
                  _streaksCard(context),
                  SizedBox(height: 12),
                ],
                // AI highlights & recommendations
                if ((widget.aiHighlights ?? const []).isNotEmpty || (widget.recommendations ?? const []).isNotEmpty) ...[
                  _aiHighlightsAndRecs(context),
                  SizedBox(height: 12),
                ],
                // API‑driven AI add‑ons
                _whatIfFromApi(context),
                SizedBox(height: 12),
                _wakeWindowsFromApi(context),
                SizedBox(height: 12),
                _causalDriversCard(context),
                SizedBox(height: 12),
                _riskAssessmentCard(context),
                SizedBox(height: 12),
                _energyPlanFromApi(context),
                SizedBox(height: 12),
                // Deltas / what changed
                if ((widget.deltas ?? {}).isNotEmpty) ...[
                  _whatChanged(context),
                  SizedBox(height: 8),
                ],

              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasAnyKpi(double? total, double? eff, double? deep, double? rem, int? awaken) {
    return total != null || eff != null || deep != null || rem != null || awaken != null;
  }

  Widget _headerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 4),
              Text('Short • Visual • Actionable', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        IconButton(
          onPressed: _exportPng,
          tooltip: 'Export as image',
          icon: Icon(Icons.ios_share, color: Colors.white),
        ),
      ],
    );
  }

  Widget _kpiRow(BuildContext context, double? total, double? eff, double? deep, double? rem, int? awaken) {
    final chips = <Widget>[];

    if (total != null) chips.add(_KpiChip(label: 'Total', value: _fmtHours(total), icon: Icons.nightlight_round, delta: widget.deltas?['totalSleep']));
    if (eff != null) chips.add(_KpiChip(label: 'Efficiency', value: '${eff.toStringAsFixed(0)}%', icon: Icons.speed, delta: widget.deltas?['efficiency']));
    if (deep != null) chips.add(_KpiChip(label: 'Deep', value: '${deep.toStringAsFixed(0)}%', icon: Icons.water_drop, delta: widget.deltas?['deepPct']));
    if (rem != null) chips.add(_KpiChip(label: 'REM', value: '${rem.toStringAsFixed(0)}%', icon: Icons.auto_awesome, delta: widget.deltas?['remPct']));
    if (awaken != null) chips.add(_KpiChip(label: 'Awakenings', value: '$awaken', icon: Icons.alarm, delta: -(widget.deltas?['awakenings'] ?? 0))); // lower is better

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i == 0) SizedBox(width: 2),
            chips[i],
            SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _cardsPager(BuildContext context, double? total, double? deep, double? rem,
      double? light, List<double> history) {
    final pages = <Widget>[];

    if ((widget.tldrBullets ?? const []).isNotEmpty) {
      pages.add(_tldrCard(context));
    }
    if (deep != null && rem != null && light != null) {
      pages.add(_compositionCard(context, deep, rem, light));
    }
    if (history.isNotEmpty) {//
      pages.add(_trendsCard(context, history));
    }
    if (widget.sleepScore != null ||
        widget.morningReadiness != null ||
        widget.chronotype != null) {
      pages.add(_scoreAndChrono(context));
    }
    if ((widget.lifestyleCorrelations ?? const []).isNotEmpty) {
      pages.add(_lifestyleCorrelationsCard(context));
    }
    if ((widget.environmentAnalysis ?? const {}).isNotEmpty) {
      pages.add(_environmentCard(context));
    }
    if ((widget.dreamMoodForecast ?? const {}).isNotEmpty) {
      pages.add(_dreamMoodCard(context));
    }

    if (pages.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: pages.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: pages[i],
        ),
      ),
    );
  }

  Widget _tldrCard(BuildContext context) {
    final bullets = (widget.tldrBullets ?? const []);
    if (bullets.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('TL;DR'),
            SizedBox(height: 6),
            for (final b in bullets.take(5))
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.white70)),
                    Expanded(child: Text(b, style: TextStyle(color: Colors.white, height: 1.2))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _compositionCard(BuildContext context, double? deep, double? rem, double? light) {
    final d = (deep ?? 0).clamp(0, 100).toDouble();
    final r = (rem ?? 0).clamp(0, 100).toDouble();
    final l = (light ?? (100 - d - r)).clamp(0, 100).toDouble();
    final total = (d + r + l);
    final nd = total == 0 ? 0.0 : d / total;
    final nr = total == 0 ? 0.0 : r / total;
    final nl = total == 0 ? 0.0 : l / total;

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _DonutPainter(values: [nd, nr, nl]),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardHeader('Sleep Composition'),
                  SizedBox(height: 8),
                  _legend('Deep', d),
                  _legend('REM', r),
                  _legend('Light', l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          _dot(),
          SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: Colors.white70))),
          Text('${value.toStringAsFixed(0)}%', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle));
  }

  Widget _trendsCard(BuildContext context, List<double> history) {
    final streak = _streakCount(history, threshold: 7.0);
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('7‑day Trend'),
            SizedBox(height: 8),
            Expanded(
              child: _Sparkline(values: history),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Avg: ${_fmtHours(history.isEmpty ? 0 : (history.reduce((a, b) => a + b) / history.length))}', style: TextStyle(color: Colors.white)),
                Text(streak >= 3 ? '🔥 ${streak}‑day streak ≥ 7h' : 'Keep it up!', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _whatChanged(BuildContext context) {
    final d = widget.deltas ?? {};
    final items = <Widget>[];

    void add(String label, double? val, {bool invert = false}) {
      if (val == null) return;
      items.add(_DeltaChip(label: label, delta: invert ? -val : val));
      items.add(SizedBox(width: 8));
    }

    add('Total', d['totalSleep']);
    add('Efficiency', d['efficiency']);
    add('Deep', d['deepPct']);
    add('REM', d['remPct']);
    add('Awakenings', d['awakenings'], invert: true);

    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text('What changed?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: items),
        ),
      ],
    );
  }

  Widget _tipsChecklist(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Do this tonight'),
            SizedBox(height: 6),
            for (final entry in _tipDone.entries)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: entry.value,
                onChanged: (v) => setState(() => _tipDone[entry.key] = v ?? false),
                title: Text(entry.key, style: TextStyle(color: Colors.white)),
                controlAffinity: ListTileControlAffinity.leading,
                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.flag,
            label: 'Set goal',
            onTap: () {
              _showSnack(context, 'Goal saved: ≥ 7h & efficiency ≥ 85%');
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Ask AI',
            onTap: () {
              _showSnack(context, 'Opening AI chat about your sleep…');
            },
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _fmtHours(double hours) {
    final totalMin = (hours * 60).round();
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '${h}h ${m}m';
  }

  int _streakCount(List<double> values, {required double threshold}) {
    int streak = 0;
    for (int i = values.length - 1; i >= 0; i--) {
      if (values[i] >= threshold) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // (removed)

  Widget _cardHeader(String title) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('auto', style: TextStyle(fontSize: 11, color: Colors.white70)),
        ),
      ],
    );
  }

  Future<void> _exportPng() async {
    try {
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (widget.onExportPng != null) {
        widget.onExportPng!(pngBytes);
      }
      if (mounted) _showSnack(context, 'Exported report image (PNG)');
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Export error: $e');
      }
    }
  }

  Widget _scoreAndChrono(BuildContext context) {
    final score = (widget.sleepScore ?? 0).clamp(0, 100);
    final readiness = (widget.morningReadiness ?? score).clamp(0, 100);
    final chrono = widget.chronotype;
    final midpoint = widget.sleepMidpoint;

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 96, height: 96,
              child: CustomPaint(painter: _GaugePainter(value: score / 100.0)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardHeader('Score & Chronotype'),
                  SizedBox(height: 6),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _pill('Score', '$score/100'),
                      _pill('Readiness', '$readiness/100'),
                      if (chrono != null && chrono.isNotEmpty) _pill('Chronotype', chrono),
                      if (midpoint != null && midpoint.isNotEmpty) _pill('Midpoint', midpoint),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _lifestyleCorrelationsCard(BuildContext context) {
    final items = (widget.lifestyleCorrelations ?? const [])
        .map((m) => m is Map ? m : {})
        .map<Map<String, dynamic>>((m) {
      // Normalize keys
      String name = (m['name'] ?? m['factor'] ?? m['metric'] ?? m['title'] ?? '').toString();
      final dynamic v = m['value'] ?? m['correlation'] ?? m['coef'] ?? m['r'] ?? m['score'];
      double val = 0.0;
      if (v is num) val = v.toDouble();
      else val = double.tryParse(v?.toString() ?? '') ?? 0.0;
      return {'name': name, 'val': val};
    })
        .where((e) => (e['name'] as String).isNotEmpty)
        .toList();

    items.sort((a,b) => (b['val'].abs()).compareTo((a['val']).abs()));
    final top = items.take(5).toList();

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Lifestyle correlations'),
            SizedBox(height: 10),
            for (final e in top) ...[
              _corrRow(e['name'] as String, (e['val'] as double)),
              SizedBox(height: 8),
            ],
            if (top.isEmpty) Text('No correlations found', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _corrRow(String label, double value) {
    final v = value.clamp(-1.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: Colors.white))),
            Text(v.toStringAsFixed(2), style: TextStyle(color: Colors.white70)),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: v.abs(),
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(v >= 0 ? Colors.lightGreenAccent : Colors.redAccent),
          ),
        )
      ],
    );
  }

  Widget _environmentCard(BuildContext context) {
    final env = (widget.environmentAnalysis ?? const {});
    final rows = <Widget>[];

    Map<String, dynamic> norm = {};
    env.forEach((k, v) {
      final kk = k.toString().replaceAll('_', ' ');
      double? score;
      if (v is num) score = v.toDouble();
      else if (v is Map && v['score'] is num) score = (v['score'] as num).toDouble();
      norm[kk] = score ?? v;
    });

    final keys = ['noise','light','temperature','air quality','humidity','bed comfort','screen exposure','caffeine'];
    for (final base in keys) {
      final entry = norm.entries.firstWhere(
            (e) => e.key.toString().toLowerCase().contains(base),
        orElse: () => MapEntry('', null),
      );
      if (entry.key.isNotEmpty) {
        rows.add(_envRow(entry.key, entry.value));
      }
    }

    if (rows.isEmpty) {
      // show generic dump
      env.forEach((k, v) => rows.add(_envRow(k.toString(), v)));
    }

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Environment factors'),
            SizedBox(height: 8),
            ...rows.take(6),
          ],
        ),
      ),
    );
  }

  Widget _envRow(String label, dynamic value) {
    double? score;
    String right = '';
    if (value is num) score = value.toDouble();
    if (value is Map && value['score'] is num) score = (value['score'] as num).toDouble();
    if (score != null) {
      String verdict = score >= 75 ? 'Good' : score >= 50 ? 'OK' : 'Poor';
      right = '${score.toStringAsFixed(0)} • $verdict';
    } else {
      right = value?.toString() ?? '';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(_titleCase(label), style: TextStyle(color: Colors.white))),
          Text(right, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  String _titleCase(String s) {
    return s.split(' ').map((w) => w.isEmpty ? '' : (w[0].toUpperCase() + w.substring(1))).join(' ');
  }

  Widget _dreamMoodCard(BuildContext context) {
    final f = widget.dreamMoodForecast ?? {};
    String mood = f['mood_forecast']?['mood']?.toString() ?? f['mood']?.toString() ?? 'Unknown';
    double conf = () {
      final c = f['mood_forecast']?['confidence'] ?? f['confidence'];
      if (c is num) return c.toDouble();
      return double.tryParse(c?.toString() ?? '') ?? 0.0;
    }();
    final dp = f['dream_prediction'] ?? f['dream'] ?? {};
    final pred = (dp is Map ? (dp['prediction'] ?? dp['level']) : null)?.toString() ?? '—';

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Dream & Mood'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _pill('Mood', mood),
                if (conf > 0) _pill('Confidence', '${conf.toStringAsFixed(0)}%'),
                _pill('Dream', pred),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiHighlightsAndRecs(BuildContext context) {
    final highlights = (widget.aiHighlights ?? const []).take(4).toList();
    final recs = (widget.recommendations ?? const []).take(4).toList();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('AI Highlights & To‑dos'),
            SizedBox(height: 6),
            if (highlights.isNotEmpty) ...[
              Text('Highlights', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              for (final h in highlights) _bullet(h),
              SizedBox(height: 8),
            ],
            if (recs.isNotEmpty) ...[
              Text('Recommendations', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              for (final r in recs) _bullet('• $r'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pill(String k, String v) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$k: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(v, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.white70)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white, height: 1.2))),
        ],
      ),
    );
  }




  // === API-driven AI add-ons ===

  Widget _whatIfFromApi(BuildContext context) {
    final scenarios = (widget.whatIfScenarios ?? const []);
    if (scenarios.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('What‑if (from AI)'),
            SizedBox(height: 8),
            for (final m in scenarios) ...[
              _bullet('${m['label'] ?? 'Scenario'} — Δ ${_fmtSigned(m['delta_score'])}'),
              if ((m['description'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 6),
                  child: Text(m['description'].toString(), style: TextStyle(color: Colors.white70)),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtSigned(dynamic v) {
    double val = 0.0;
    if (v is num) val = v.toDouble(); else { val = double.tryParse(v?.toString() ?? '') ?? 0.0; }
    final s = val >= 0 ? '+' : '';
    return '$s${val.toStringAsFixed(1)}';
  }

  Widget _wakeWindowsFromApi(BuildContext context) {
    final ww = widget.wakeWindows ?? const [];
    if (ww.isEmpty) return SizedBox.shrink();
    final strings = ww.map((e){
      if (e is String) return e;
      if (e is Map) {
        final f = e['from']?.toString() ?? '';
        final t = e['to']?.toString() ?? '';
        return f.isNotEmpty && t.isNotEmpty ? '$f–$t' : (e['label']?.toString() ?? '');
      }
      return '';
    }).where((s)=> s.isNotEmpty).toList();
    if (strings.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Smart wake windows'),
            SizedBox(height: 6),
            for (final s in strings) _bullet('• $s'),
          ],
        ),
      ),
    );
  }

  Widget _riskAssessmentCard(BuildContext context) {
    final r = widget.riskAssessment ?? const {};
    if (r.isEmpty) return SizedBox.shrink();
    final score = r['risk_score'] ?? r['riskScore'];
    final alertsSrc = r['alerts'] ?? r['warnings'];
    final alerts = (alertsSrc is List)
        ? alertsSrc.cast<String>()
        : <String>[];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Risk & alerts'),
            SizedBox(height: 6),
            if (score != null) _pill('Risk', score.toString()),
            if (alerts.isNotEmpty) ...[
              SizedBox(height: 6),
              for (final a in alerts) _bullet('• $a'),
            ]
          ],
        ),
      ),
    );
  }

  Widget _energyPlanFromApi(BuildContext context) {
    final e = widget.energyPlan ?? const {};
    if (e.isEmpty) return SizedBox.shrink();
    final light = e['light']?.toString();
    final cutoff =
    (e['caffeine_cutoff'] ?? e['caffeineCutoff'])?.toString();
    final nap = (e['nap_window'] ?? e['napWindow'])?.toString();
    final notesSrc = e['notes'] ?? e['note'];
    final notes = (notesSrc is List)
        ? notesSrc.cast<String>()
        : <String>[];

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Tomorrow’s energy plan'),
            SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (light != null && light.isNotEmpty) _pill('Bright light', light),
              if (cutoff != null && cutoff.isNotEmpty) _pill('Caffeine cutoff', cutoff),
              if (nap != null && nap.isNotEmpty) _pill('Nap window', nap),
            ]),
            if (notes.isNotEmpty) ...[
              SizedBox(height: 8),
              for (final n in notes) _bullet('• $n'),
            ]
          ],
        ),
      ),
    );
  }

  Widget _driversFromApi(BuildContext context) {
    final d = widget.drivers ?? const {};
    final pos = (d['positive'] is List) ? (d['positive'] as List) : const [];
    final neg = (d['negative'] is List) ? (d['negative'] as List) : const [];
    if (pos.isEmpty && neg.isEmpty) return SizedBox.shrink();

    Widget chip(dynamic m, String arrow) {
      String name = (m is Map) ? (m['name'] ?? m['factor'] ?? m['metric'] ?? '').toString() : m.toString();
      final v = (m is Map) ? (m['value'] ?? m['coef'] ?? m['correlation'] ?? 0) : 0;
      double val = v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0.0);
      return _pill('$arrow $name', val.toStringAsFixed(2));
    }

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Likely drivers'),
            SizedBox(height: 6),
            if (pos.isNotEmpty) ...[
              Text('Positive', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final m in pos.take(6)) chip(m, '↑')]),
            ],
            if (neg.isNotEmpty) ...[
              SizedBox(height: 10),
              Text('Negative', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final m in neg.take(6)) chip(m, '↓')]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hrvCard(BuildContext context) {
    final h = widget.hrvSummary ?? const {};
    if (h.isEmpty) return SizedBox.shrink();
    final rmssd = h['rmssd'];
    final sdnn = h['sdnn'];
    final balance = h['balance'] ?? h['balanceScore'];
    final rec = h['recovery_index'] ?? h['recoveryIndex'];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('HRV summary'),
          SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (rmssd != null) _pill('RMSSD', rmssd.toString()),
            if (sdnn != null) _pill('SDNN', sdnn.toString()),
            if (balance != null) _pill('Balance', balance.toString()),
            if (rec != null) _pill('Recovery', rec.toString()),
          ]),
        ]),
      ),
    );
  }

  Widget _respiratoryCard(BuildContext context) {
    final r = widget.respiratory ?? const {};
    if (r.isEmpty) return SizedBox.shrink();
    final ahi = r['ahi'];
    final events = r['events'] ?? r['eventCount'];
    final snore = r['snore_index'] ?? r['snoreIndex'];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Respiratory events'),
          SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (ahi != null) _pill('AHI', ahi.toString()),
            if (events != null) _pill('Events', events.toString()),
            if (snore != null) _pill('Snore', snore.toString()),
          ]),
        ]),
      ),
    );
  }

  Widget _glucoseCard(BuildContext context) {
    final g = widget.glucoseCorrelation ?? const {};
    if (g.isEmpty) return SizedBox.shrink();
    final corr = g['corr'] ?? g['correlation'];
    final notesSrc = g['notes'] ?? g['note'];
    final notes = (notesSrc is List)
        ? notesSrc.cast<String>()
        : <String>[];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Glucose ↔ Sleep'),
          SizedBox(height: 6),
          if (corr != null) _pill('corr', corr.toString()),
          if (notes.isNotEmpty) ...[SizedBox(height: 6), for (final n in notes) _bullet('• $n')],
        ]),
      ),
    );
  }

  Widget _achievementsCard(BuildContext context) {
    final a = widget.achievements ?? const [];
    if (a.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Achievements'),
          SizedBox(height: 6),
          Column(children: [
            for (final m in a.take(6)) Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Text((m['name'] ?? '').toString(), style: TextStyle(color: Colors.white))),
                SizedBox(width: 8),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                  value: (() { final v = m['progress']; if (v is num) return (v.toDouble()).clamp(0.0,1.0); final d = double.tryParse(v?.toString() ?? ''); return (d ?? 0).clamp(0.0,1.0);}()),
                  minHeight: 8, backgroundColor: Colors.white.withOpacity(0.12),
                ))),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
  Widget _smartGoalsCard(BuildContext context) {
    final goals = widget.smartGoals ?? const [];
    if (goals.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('SMART goals'),
            SizedBox(height: 6),
            for (final g in goals.take(6)) _bullet('• $g'),
          ],
        ),
      ),
    );
  }

  Widget _actionItemsCard(BuildContext context) {
    final items = widget.actionItems ?? const [];
    if (items.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Tonight’s to‑dos'),
          SizedBox(height: 6),
          for (final t in items.take(8)) _bullet('• $t'),
        ]),
      ),
    );
  }


  // What‑if simulator: uses lifestyle correlations to estimate impact on score.
  Widget _whatIfSimulator(BuildContext context) {
    final corr = (widget.lifestyleCorrelations ?? const [])
        .where((e) => e is Map)
        .cast<Map>()
        .toList();

    double coef(String keyLike) {
      final hit = corr.firstWhere(
            (m) => (m['name'] ?? m['factor'] ?? m['metric'] ?? '')
            .toString()
            .toLowerCase()
            .contains(keyLike),
        orElse: () => {},
      );
      final v = hit.isEmpty ? 0 : (hit['value'] ?? hit['correlation'] ?? hit['coef'] ?? hit['r'] ?? 0);
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    // Heuristic linear model
    // Earlier bedtime: positive effect; Screen reduce: positive; Caffeine earlier: positive.
    final betaBed = coef('bedtime').abs() + 0.15;
    final betaScreen = coef('screen').abs() + 0.12;
    final betaCaff = coef('caff').abs() + 0.10;

    final estDelta = (_simBedtimeEarlierMin/60.0)*betaBed*8
        + (_simScreenReduceMin/60.0)*betaScreen*6
        + (_simCaffCutoffHours)*betaCaff*4;

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('What‑if simulator'),
            SizedBox(height: 10),
            _simRow(
              'Sleep earlier',
              '${_simBedtimeEarlierMin.toStringAsFixed(0)} min',
              Slider(
                value: _simBedtimeEarlierMin, min: 0, max: 120, divisions: 12,
                onChanged: (v) => setState(()=> _simBedtimeEarlierMin = v),
              ),
            ),
            _simRow(
              'Reduce screens',
              '${_simScreenReduceMin.toStringAsFixed(0)} min',
              Slider(
                value: _simScreenReduceMin, min: 0, max: 120, divisions: 12,
                onChanged: (v) => setState(()=> _simScreenReduceMin = v),
              ),
            ),
            _simRow(
              'Caffeine cutoff ↑',
              '${_simCaffCutoffHours.toStringAsFixed(1)} h earlier',
              Slider(
                value: _simCaffCutoffHours, min: 0, max: 3, divisions: 6,
                onChanged: (v) => setState(()=> _simCaffCutoffHours = v),
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Text('Predicted score Δ: ', style: TextStyle(color: Colors.white70)),
                Text(estDelta >= 0 ? '+${estDelta.toStringAsFixed(1)}' : estDelta.toStringAsFixed(1),
                    style: TextStyle(color: estDelta >= 0 ? Colors.lightGreenAccent : Colors.redAccent, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _simRow(String label, String value, Widget slider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: Colors.white))),
              Text(value, style: TextStyle(color: Colors.white70)),
            ],
          ),
          slider,
        ],
      ),
    );
  }

  // Smart alarm window: pick bedtime and compute cycle-friendly wake windows.
  Widget _smartAlarmCard(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Smart wake windows'),
            SizedBox(height: 8),
            Text('Pick intended bedtime → we suggest REM-friendly wake windows.', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _ActionButton(
                icon: Icons.schedule,
                label: 'Pick bedtime',
                onTap: () async {
                  final now = TimeOfDay.now();
                  final picked = await showTimePicker(context: context, initialTime: now);
                  if (!mounted || picked == null) return;
                  _showWakeWindows(context, picked);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWakeWindows(BuildContext context, TimeOfDay bedtime) {
    // Compute 4–6 cycles of ~90m, plus ~15m sleep latency
    List<String> windows = [];
    final latency = Duration(minutes: 15);
    DateTime base = DateTime(0,1,1, bedtime.hour, bedtime.minute).add(latency);
    for (int cycles=4; cycles<=6; cycles++) {
      final wake = base.add(Duration(minutes: 90*cycles));
      final from = wake.subtract(Duration(minutes: 15));
      final to = wake.add(Duration(minutes: 15));
      windows.add('${_fmtTime(from)} – ${_fmtTime(to)}');
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1022),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Suggested wake windows', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: windows.map((w)=> Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('• $w', style: TextStyle(color: Colors.white70)),
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('OK')),
        ],
      ),
    );
  }

  String _fmtTime(DateTime t) {
    String two(int v)=> v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  // Causal drivers: top positive & negative lifestyle correlations
  Widget _causalDriversCard(BuildContext context) {
    final items = (widget.lifestyleCorrelations ?? const [])
        .where((e)=> e is Map)
        .cast<Map>()
        .map<Map<String, dynamic>>((m){
      String name = (m['name'] ?? m['factor'] ?? m['metric'] ?? m['title'] ?? '').toString();
      final v = m['value'] ?? m['correlation'] ?? m['coef'] ?? m['r'] ?? 0;
      double val = v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0.0);
      return {'name': name, 'val': val};
    }).where((e)=> (e['name'] as String).isNotEmpty).toList();

    if (items.isEmpty) {
      return SizedBox.shrink();
    }
    items.sort((a,b)=> (b['val'] as double).compareTo(a['val'] as double));
    final positives = items.where((e)=> (e['val'] as double) > 0).take(3).toList();
    final negatives = items.where((e)=> (e['val'] as double) < 0).toList()
      ..sort((a,b)=> (a['val'] as double).compareTo(b['val'] as double));
    final topNeg = negatives.take(3).toList();

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Likely drivers'),
            SizedBox(height: 8),
            Text('Positive', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in positives) _pill('↑ ${(e['name'] as String)}', (e['val'] as double).toStringAsFixed(2)),
            ]),
            SizedBox(height: 10),
            Text('Negative', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in topNeg) _pill('↓ ${(e['name'] as String)}', (e['val'] as double).toStringAsFixed(2)),
            ]),
          ],
        ),
      ),
    );
  }

  // Anomaly + risk display
  Widget _anomalyAndRisk(BuildContext context) {
    final h = (widget.last7DaysHours ?? const []).where((e)=> e.isFinite).toList();
    if (h.isEmpty) return SizedBox.shrink();
    final median = _median(h);
    final mad = _mad(h, median);
    final today = h.last;
    final z = mad == 0 ? 0 : (today - median).abs() / mad;
    final isAnom = z > 1.5;
    final avg = h.reduce((a,b)=> a+b) / h.length;
    final risk = (avg < 7.0 ? 68 : 20) + (isAnom ? 10 : 0);

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader('Anomaly & risk'),
                SizedBox(height: 6),
                Text(isAnom ? 'Unusual night detected' : 'Stable pattern', style: TextStyle(color: Colors.white)),
                SizedBox(height: 4),
                Text('Sleep debt risk next week: ~${risk.clamp(0,100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.white70)),
              ],
            )),
            SizedBox(width: 12),
            SizedBox(width: 72, height: 72, child: CustomPaint(painter: _GaugePainter(value: (risk/100.0)))),
          ],
        ),
      ),
    );
  }

  double _median(List<double> v) {
    final s = List<double>.from(v)..sort();
    final mid = s.length ~/ 2;
    if (s.length.isOdd) return s[mid];
    return (s[mid-1] + s[mid]) / 2.0;
  }
  double _mad(List<double> v, double med) {
    final dev = v.map((x)=> (x - med).abs()).toList()..sort();
    final mid = dev.length ~/ 2;
    if (dev.length.isOdd) return dev[mid];
    return (dev[mid-1] + dev[mid]) / 2.0;
  }

  // Energy plan card: next-day plan times using chronotype heuristics
  Widget _energyPlanCard(BuildContext context) {
    final chrono = (widget.chronotype ?? '').toLowerCase();
    DateTime base(DateTime dt, int h) => DateTime(dt.year, dt.month, dt.day, h);
    // Defaults (Bear)
    var light = '09:00';
    var caffeineCutoff = '14:00';
    var nap = '13:30–14:00';

    if (chrono.contains('lion')) {
      light = '08:00'; caffeineCutoff = '13:00'; nap = '12:30–13:00';
    } else if (chrono.contains('wolf')) {
      light = '10:00'; caffeineCutoff = '15:00'; nap = '14:30–15:00';
    } else if (chrono.contains('dolphin')) {
      light = '09:30'; caffeineCutoff = '13:30'; nap = '—';
    }

    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Tomorrow’s energy plan'),
            SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _pill('Bright light', light),
              _pill('Caffeine cutoff', caffeineCutoff),
              _pill('Nap window', nap),
            ]),
            SizedBox(height: 8),
            _bullet('Evening: dim screens 90m before bed, keep room ≤ 19–20°C.'),
          ],
        ),
      ),
    );
  }



  // === Extra API-driven smart features (inserted) ===

  Widget _causalGraphCard(BuildContext context) {
    final g = widget.causalGraph ?? const {};
    final nodes = (g['nodes'] is List) ? (g['nodes'] as List) : const [];
    final edges = (g['edges'] is List) ? (g['edges'] as List) : const [];
    if (nodes.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Causal graph'),
            SizedBox(height: 8),
            SizedBox(height: 180, child: CustomPaint(
              painter: _CausalGraphPainter(nodes: nodes, edges: edges),
            ))
          ],
        ),
      ),
    );
  }

  Widget _energyTimelineCard(BuildContext context) {
    final t = widget.energyTimeline ?? const {};
    final segs = (t['segments'] is List) ? (t['segments'] as List) : const [];
    if (segs.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Next‑day energy timeline'),
            SizedBox(height: 8),
            SizedBox(height: 28, child: CustomPaint(painter: _TimelinePainter(segments: segs))),
          ],
        ),
      ),
    );
  }

  Widget _cognitiveWindowsCard(BuildContext context) {
    final w = widget.cognitiveWindows ?? const [];
    if (w.isEmpty) return SizedBox.shrink();
    List<String> items = w.map((e){
      if (e is String) return e;
      if (e is Map) {
        final f = e['from']?.toString() ?? '';
        final t = e['to']?.toString() ?? '';
        final lab = e['label']?.toString() ?? '';
        return [f,t,lab].where((s)=> s.isNotEmpty).join(' ');
      }
      return '';
    }).where((s)=> s.isNotEmpty).toList();
    if (items.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Cognitive windows'),
          SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final s in items) _pill('Focus', s)]),
        ]),
      ),
    );
  }

  Widget _microArousalsCard(BuildContext context) {
    final m = widget.microArousals ?? const {};
    if (m.isEmpty) return SizedBox.shrink();
    final idx = m['index']; final cnt = m['count']; final notes = (m['notes'] is List)? (m['notes'] as List).cast<String>():<String>[];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Micro‑arousals'),
          SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (idx != null) _pill('Index', idx.toString()),
            if (cnt != null) _pill('Count', cnt.toString()),
          ]),
          if (notes.isNotEmpty) ...[SizedBox(height: 6), for (final n in notes) _bullet('• $n')],
        ]),
      ),
    );
  }

  Widget _architectureNotesCard(BuildContext context) {
    final a = widget.architectureNotes ?? const [];
    if (a.isEmpty) return SizedBox.shrink();
    final lines = a.map((e){
      if (e is String) return e;
      if (e is Map) {
        final st = e['stage']?.toString() ?? '';
        final nt = e['note']?.toString() ?? '';
        return [st, nt].where((s)=> s.isNotEmpty).join(': ');
      }
      return '';
    }).where((s)=> s.isNotEmpty).toList();
    if (lines.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Architecture notes'),
          SizedBox(height: 6),
          for (final l in lines.take(8)) _bullet('• $l'),
        ]),
      ),
    );
  }

  Widget _recoveryPlanCard(BuildContext context) {
    final r = widget.recoveryPlan ?? const {};
    if (r.isEmpty) return SizedBox.shrink();
    final score = r['score']; final steps = (r['steps'] is List) ? (r['steps'] as List).cast<String>() : <String>[];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Recovery plan'),
          SizedBox(height: 6),
          if (score != null) _pill('Score', score.toString()),
          if (steps.isNotEmpty) ...[SizedBox(height: 6), for (final s in steps) _bullet('• ' + s)],
        ]),
      ),
    );
  }

  Widget _nutritionCard(BuildContext context) {
    final n = widget.nutrition ?? const {};
    if (n.isEmpty) return SizedBox.shrink();
    final corr = n['corr']; final adv = (n['advice'] is List) ? (n['advice'] as List).cast<String>() : <String>[];
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader('Nutrition ↔ Sleep'),
          SizedBox(height: 6),
          if (corr != null) _pill('corr', corr.toString()),
          if (adv.isNotEmpty) ...[SizedBox(height: 6), for (final s in adv) _bullet('• ' + s)],
        ]),
      ),
    );
  }

  /// Display streak metrics (e.g. consecutive days meeting a goal). Each
  /// entry should contain at least a `name` and `days` field. If the list is
  /// empty, returns a zero‑height widget. Shows up to six entries.
  Widget _streaksCard(BuildContext context) {
    final s = widget.streaks ?? const [];
    if (s.isEmpty) return SizedBox.shrink();
    // Convert each element to a map for easy access. Filter out entries
    // without a name.
    final items = s.where((e) => e != null).map<Map<String, dynamic>>((e) {
      if (e is Map<String, dynamic>) return e;
      if (e is Map) return Map<String, dynamic>.from(e);
      return <String, dynamic>{};
    }).where((m) => (m['name'] ?? '').toString().isNotEmpty).toList();
    if (items.isEmpty) return SizedBox.shrink();
    return _GlassCard(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader('Streaks'),
            SizedBox(height: 6),
            Column(
              children: [
                for (final m in items.take(6))
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Streak name on the left
                        Expanded(
                          flex: 3,
                          child: Text(
                            (m['name'] ?? '').toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Number of days on the right
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${m['days'] ?? m['length'] ?? m['value'] ?? ''}d',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;//
  final IconData icon;
  final double? delta;
  const _KpiChip({required this.label, required this.value, required this.icon, this.delta});

  @override
  Widget build(BuildContext context) {
    Color arrowColor = Colors.white70;
    IconData? arrow;
    String deltaText = '';
    if (delta != null && delta!.abs() > 0.01) {
      final up = delta! > 0;
      arrow = up ? Icons.arrow_upward : Icons.arrow_downward;
      arrowColor = up ? Colors.lightGreenAccent : Colors.redAccent;
      deltaText = '${delta! > 0 ? '+' : ''}${delta!.toStringAsFixed(1)}';
      if (label == 'Awakenings') {
        // For awakenings, down is good; already handled by caller.
      } else if (label == 'Efficiency' || label == 'Total' || label == 'Deep' || label == 'REM') {
        // Normal direction.
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          if (arrow != null) ...[
            SizedBox(width: 8),
            Icon(arrow, size: 16, color: arrowColor),
            SizedBox(width: 2),
            Text(deltaText, style: TextStyle(color: arrowColor, fontWeight: FontWeight.w600)),
          ]
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String label;
  final double delta;
  const _DeltaChip({required this.label, required this.delta});

  @override
  Widget build(BuildContext context) {
    final up = delta > 0;
    final color = up ? Colors.lightGreenAccent : Colors.redAccent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Colors.white70)),
          SizedBox(width: 6),
          Icon(up ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: color),
          SizedBox(width: 2),
          Text('${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Simple donut painter (Deep / REM / Light). Colors are neutral; app theme can wrap/override if needed.
class _DonutPainter extends CustomPainter {
  final List<double> values; // normalized fractions 0..1, sum ~1
  _DonutPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.28;

    final paints = [
      Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..color = Colors.white.withOpacity(0.95),
      Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..color = Colors.white.withOpacity(0.6),
      Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..color = Colors.white.withOpacity(0.25),
    ];

    double start = -math.pi / 2;
    for (int i = 0; i < values.length && i < paints.length; i++) {
      final sweep = (values[i] * 2 * math.pi).clamp(0.0, 2 * math.pi);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paints[i]);
      start += sweep;
    }

    // middle label
    final totalPct = (values.fold(0.0, (a, b) => a + b) * 100).clamp(0, 100).toStringAsFixed(0);
    final tp = TextPainter(
      text: TextSpan(text: '$totalPct%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: radius * 0.45)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

/// Super lightweight sparkline for 7-day hours trend.
class _Sparkline extends StatelessWidget {
  final List<double> values;
  const _Sparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values),
      child: SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final t = values.length == 1 ? 0.5 : i / (values.length - 1);
      final x = t * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.10);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => !listEquals(oldDelegate.values, values);
}




class _GaugePainter extends CustomPainter {
  final double value; // 0..1
  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final radius = math.min(size.width, size.height)/2;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.2
      ..color = Colors.white.withOpacity(0.1);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.2
      ..color = Colors.white;

    final rect = Rect.fromCircle(center: center, radius: radius*0.8);
    const start = -3.14 * 0.75; // 225 deg
    const sweep = 3.14 * 1.5;   // 270 deg

    canvas.drawArc(rect, start, sweep, false, bg);
    canvas.drawArc(rect, start, sweep * value.clamp(0.0,1.0), false, fg);

    final tp = TextPainter(
      text: TextSpan(text: '${(value*100).round()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: radius*0.6)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width/2, tp.height/2));
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}

class _CausalGraphPainter extends CustomPainter {
  final List<dynamic> nodes;
  final List<dynamic> edges;
  _CausalGraphPainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    // Lay out nodes roughly in a circle; if nodes carry positions use them
    final cx = size.width/2, cy = size.height/2;
    final r = math.min(size.width, size.height)/2 - 22;
    final pos = <String, Offset>{};
    for (int i=0; i<nodes.length; i++) {
      final n = nodes[i] as Map;
      final id = (n['id'] ?? n['name'] ?? '$i').toString();
      final angle = (i / math.max(1, nodes.length)) * math.pi*2;
      pos[id] = Offset(cx + r*math.cos(angle), cy + r*math.sin(angle));
    }
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.35);
    for (final e in edges) {
      if (e is! Map) continue;
      final from = (e['from'] ?? '').toString();
      final to = (e['to'] ?? '').toString();
      if (!pos.containsKey(from) || !pos.containsKey(to)) continue;
      canvas.drawLine(pos[from]!, pos[to]!, edgePaint);
    }
    final nodePaint = Paint()..style = PaintingStyle.fill..color = Colors.white;
    for (int i=0; i<nodes.length; i++) {
      final n = nodes[i] as Map;
      final id = (n['id'] ?? n['name'] ?? '$i').toString();
      final label = (n['label'] ?? id).toString();
      final score = (){ var v=n['score']; if (v is num) return v.toDouble(); return double.tryParse(v?.toString()??'')??0.0;}();
      final p = pos[id]!;
      final rad = 6.0 + score.abs()*6.0;
      canvas.drawCircle(p, rad, nodePaint);
      final tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(color: Colors.white70, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, p + const Offset(8, -6));
    }
  }

  @override
  bool shouldRepaint(covariant _CausalGraphPainter oldDelegate) => oldDelegate.nodes != nodes || oldDelegate.edges != edges;
}

class _TimelinePainter extends CustomPainter {
  final List<dynamic> segments;
  _TimelinePainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..style = PaintingStyle.fill..color = Colors.white.withOpacity(0.08);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)), bg);
    double x = 2;
    final h = size.height-4;
    for (final s in segments) {
      if (s is! Map) continue;
      final wid = (){
        final w = s['width'];
        if (w is num) return (w.toDouble()).clamp(10.0, size.width-4);
        return null;
      }();
      final intensity = (){ final v = s['intensity']; if (v is num) return v.toDouble(); return double.tryParse(v?.toString()??'')??0.5;}();
      final w = wid ?? (size.width-4)/segments.length;
      final rect = Rect.fromLTWH(x, 2, w-2, h);
      final p = Paint()..style = PaintingStyle.fill..color = Colors.white.withOpacity(0.25 + 0.5*intensity.clamp(0,1));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), p);
      final lab = (s['label'] ?? '').toString();
      if (lab.isNotEmpty) {
        final tp = TextPainter(text: TextSpan(text: lab, style: const TextStyle(color: Colors.white, fontSize: 10)), textDirection: TextDirection.ltr, maxLines: 1)..layout(maxWidth: w-6);
        tp.paint(canvas, Offset(x+4, 4));
      }
      x += w;
      if (x > size.width-4) break;
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) => oldDelegate.segments != segments;
}//
