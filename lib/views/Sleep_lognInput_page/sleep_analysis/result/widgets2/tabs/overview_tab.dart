
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/api/api_service.dart';
import '../../../models/sleeplog_model_page.dart';

// ============================================================================
//  OverviewTab2050 — 2025 AI-Connected Design (UI-only refresh)
//  NOTE: Public API is unchanged. No data models or field names were touched.
// ============================================================================

class OverviewTab2050 extends StatefulWidget {
  // ------------------------ PUBLIC FIELDS (UNCHANGED) ------------------------
  final int sleepScore;
  final String totalSleepDuration;
  final double sleepEfficiency;          // 0–100
  final int sleepDebt;
  final Map<String, double> sleepStages; // e.g., { "Deep": 18, "REM": 22, "Light": 55, "Awake": 5 }
  final List<String> aiHighlights;
  final List<double> weeklyTrend; // e.g., [6.3, 7.1, 5.9, ...] hours
  final List<Map<String, dynamic>> lifestyleCorrelations; // [{"label":"Caffeine","value":-0.32}, ...]
  final List<String> recommendations;
  final String? moodSummary;
  final String? dreamPrediction;
  final int? morningReadiness; // 0–100
  final ConfettiController confettiController;

  const OverviewTab2050({
    super.key,
    required this.sleepScore,
    required this.totalSleepDuration,
    required this.sleepEfficiency,
    required this.sleepDebt,
    required this.sleepStages,
    required this.aiHighlights,
    required this.weeklyTrend,
    required this.lifestyleCorrelations,
    required this.recommendations,
    required this.confettiController,
    this.moodSummary,
    this.dreamPrediction,
    this.morningReadiness,
  });

  @override
  State<OverviewTab2050> createState() => _OverviewTab2050State();
}

// -----------------------------------------------------------------------------
// THEME
// -----------------------------------------------------------------------------
const _bgStart = Color(0xFF060D1F);
const _bgEnd   = Color(0xFF0E1C3A);
const _cardStart = Color(0x0FFFFFFF);
const _cardEnd   = Color(0x11FFFFFF);
const _neonA = Color(0xFF7AE1FF);
const _neonB = Color(0xFF8F7BFF);
const _neonC = Color(0xFF2EF8A0);

class _OverviewTab2050State extends State<OverviewTab2050> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final ScrollController _scrollController;
  late Future<Map<String, dynamic>> _dailyComparisonFuture;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    // celebrate great sleep score
    if (widget.sleepScore >= 85) {
      _showConfetti = true;
      widget.confettiController.play();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    }
    _dailyComparisonFuture = _getDailyComparisonNormalized();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final hours = _parseHours(widget.totalSleepDuration);
    final debtH = widget.sleepDebt.toDouble();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgStart, _bgEnd],
        ),
      ),
      child: Stack(
        children: [
          // Neural mesh in the background
          const Positioned.fill(child: _NeuralMesh()),
          // Glow Orbs
          Positioned(
            top: -120,
            right: -80,
            child: _glowOrb(220, _neonB.withOpacity(0.16)),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _glowOrb(280, _neonC.withOpacity(0.12)),
          ),
          // Content
          SafeArea(
            child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(hours),
                    SizedBox(height: 16.h),
                    _buildMetricsRow(hours, debtH),
                    SizedBox(height: 14.h),
                    _buildWeeklyTrend(),
                    SizedBox(height: 14.h),
                    _buildStagesAndAIHighlights(),
                    if (widget.moodSummary != null || widget.dreamPrediction != null || widget.morningReadiness != null) ...[
                      SizedBox(height: 14.h),
                      _buildQuickAIStates(),
                    ],
                    SizedBox(height: 14.h),
                    _buildDailyCompare(),
                    SizedBox(height: 14.h),
                    _buildLifestyleCorrelations(),
                    if (widget.recommendations.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _buildRecommendations(),
                    ],
                    SizedBox(height: 28.h),
                  ],
                )
            ),
          ),
          if (_showConfetti)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: widget.confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                maxBlastForce: 18,
                minBlastForce: 6,
                gravity: 0.18,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildHeader(double hours) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _NeoCard(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _pulse,
                  child: SizedBox(
                    width: 84.w,
                    height: 84.w,
                    child: CustomPaint(
                      painter: _CircularArcGauge(
                        value: widget.sleepScore.toDouble(),
                        max: 100,
                        start: -120,
                        sweep: 240,
                        trackColor: Colors.white12,
                        gradient: const SweepGradient(
                          colors: [_neonA, _neonB, _neonC],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.sleepScore}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overview',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          )),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _chip('AI Connected', Icons.hub),
                          _chip('Personalized', Icons.auto_awesome),
                          _chip('Real‑time', Icons.bolt),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow(double hours, double debtH) {
    final eff = widget.sleepEfficiency.clamp(0, 100).toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: _NeoCard(
            child: _KPI(
              title: 'Duration',
              value: widget.totalSleepDuration,
              secondary: 'Debt ${widget.sleepDebt} h',
              icon: Icons.schedule,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _NeoCard(
            child: _KPI(
              title: 'Efficiency',
              value: '$eff%',
              secondary: 'Score ${widget.sleepScore}',
              icon: Icons.speed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrend() {
    return _NeoCard(
      padding: EdgeInsets.all(16.r),
      child: widget.weeklyTrend.isEmpty
          ? Text('Failed to load weekly trend.',
          style: TextStyle(color: Colors.white60, fontSize: 13.sp))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Weekly Trend', Icons.show_chart),
          SizedBox(height: 10.h),
          SizedBox(
            height: 80.h,
            child: _Sparkline(points: widget.weeklyTrend),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('Avg',
                  _avg(widget.weeklyTrend).toStringAsFixed(1) + ' h'),
              _miniStat('Best',
                  _max(widget.weeklyTrend).toStringAsFixed(1) + ' h'),
              _miniStat('Worst',
                  _min(widget.weeklyTrend).toStringAsFixed(1) + ' h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStagesAndAIHighlights() {
    final stages = widget.sleepStages;
    final entries = stages.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _NeoCard(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Sleep Stages', Icons.bedtime),
                SizedBox(height: 10.h),
                ...entries.map((e) => _stageBar(e.key, e.value)),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _NeoCard(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('AI Highlights', Icons.auto_awesome),
                SizedBox(height: 6.h),
                if (widget.aiHighlights.isEmpty)
                  Text('Failed to load AI highlights.',
                      style: TextStyle(color: Colors.white60, fontSize: 13.sp))
                else
                  ...widget.aiHighlights.take(5).map((t) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.brightness_1, size: 8.r, color: Colors.white70),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(t, style: TextStyle(color: Colors.white, fontSize: 13.5.sp)),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAIStates() {
    List<Widget> chips = [];
    if (widget.moodSummary != null) {
      chips.add(_stateTile('Mood', widget.moodSummary!, Icons.mood));
    }
    if (widget.dreamPrediction != null) {
      chips.add(_stateTile('Dreams', widget.dreamPrediction!, Icons.visibility));
    }
    if (widget.morningReadiness != null) {
      chips.add(_stateTile('Readiness', '${widget.morningReadiness}%', Icons.rocket_launch));
    }

    return _NeoCard(
      padding: EdgeInsets.all(16.r),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: chips,
      ),
    );
  }


  Widget _buildDailyCompare() {
    return _NeoCard(
      padding: EdgeInsets.all(16.r),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _dailyComparisonFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                const _PulseDot(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text('Analyzing today vs yesterday…',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                ),
              ],
            );
          }
          if (snap.hasError) {
            debugPrint('Daily comparison load error: ${snap.error}');
            return Text('Failed to load comparison data.',
                style: TextStyle(color: Colors.white60, fontSize: 13.sp));
          }
          if (!snap.hasData || (snap.data?.isEmpty ?? true)) {
            return Text('Failed to load comparison data.',
                style: TextStyle(color: Colors.white60, fontSize: 13.sp));
          }
          final data = snap.data!;
          final better = data['better'].toString();
          final worse  = data['worse'].toString();
          final delta  = data['delta'].toString();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Daily Compare', Icons.compare),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _badgeTile('Improved', better, Icons.trending_up)),
                  SizedBox(width: 10.w),
                  Expanded(child: _badgeTile('Declined', worse, Icons.trending_down)),
                  SizedBox(width: 10.w),
                  Expanded(child: _badgeTile('Delta', delta, Icons.swap_vert)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildLifestyleCorrelations() {
    final list = widget.lifestyleCorrelations;
    return _NeoCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Lifestyle Correlations', Icons.insights),
          SizedBox(height: 10.h),
          if (list.isEmpty)
            Text('Failed to load correlations.',
                style: TextStyle(color: Colors.white60, fontSize: 13.sp))
          else
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: list.map((m) {
                final label = (m['label'] ?? '').toString();
                final value = (m['value'] ?? 0.0) as num;
                return _correlationPill(label, value.toDouble());
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return _NeoCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Smart Suggestions', Icons.tips_and_updates),
          SizedBox(height: 8.h),
          ...widget.recommendations.map(
                (r) => Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.bolt, size: 16.r, color: Colors.white70),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(r, style: TextStyle(color: Colors.white, fontSize: 13.5.sp))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FIRESTORE + API HELPERS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _getDailyComparisonNormalized() async {
    final raw = await _getDailyComparison();
    return _normalizeDailyComparison(raw);
  }

  Future<Map<String, dynamic>> _getDailyComparison() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not signed in');
    }
    try {
      final logsCollection = FirebaseFirestore.instance
          .collection('user_sleep_logs')
          .doc(user.uid)
          .collection('logs');

      final query = await logsCollection
          .orderBy('date', descending: true)
          .limit(2)
          .get();

      if (query.docs.length < 2) {
        throw Exception('Not enough logs for comparison');
      }

      final current = SleepLog.fromMap(query.docs[0].data(), query.docs[0].id);
      final previous = SleepLog.fromMap(query.docs[1].data(), query.docs[1].id);

      return await ApiService.compareSleepLogs(
        currentLog: current.toMap(),
        previousLog: previous.toMap(),
      );

    } catch (e) {
      debugPrint('Daily comparison error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeDailyComparison(Map raw) {
    final Map<String, dynamic> map = _convertDynamicMap(raw);
    if (map.isEmpty) {
      return {'better': '—', 'worse': '—', 'delta': 0};
    }
    if (map.containsKey('better') &&
        map.containsKey('worse') &&
        map.containsKey('delta')) {
      return {
        'better': map['better'],
        'worse': map['worse'],
        'delta': map['delta'],
      };
    }
    final todayRaw = map['today'];
    final yesterdayRaw = map['yesterday'];

    double todayVal = 0.0;
    double yesterdayVal = 0.0;
    if (todayRaw is num) {
      todayVal = todayRaw.toDouble();
    } else {
      todayVal = double.tryParse(todayRaw?.toString() ?? '') ?? 0.0;
    }
    if (yesterdayRaw is num) {
      yesterdayVal = yesterdayRaw.toDouble();
    } else {
      yesterdayVal = double.tryParse(yesterdayRaw?.toString() ?? '') ?? 0.0;
    }
    final diff = todayVal - yesterdayVal;
    if (diff >= 0) {
      return {
        'better': todayVal.toStringAsFixed(1),
        'worse': yesterdayVal.toStringAsFixed(1),
        'delta': diff.toStringAsFixed(1),
      };
    } else {
      return {
        'better': yesterdayVal.toStringAsFixed(1),
        'worse': todayVal.toStringAsFixed(1),
        'delta': diff.toStringAsFixed(1),
      };
    }
  }

  Map<String, dynamic> _convertDynamicMap(
      Map<dynamic, dynamic> originalMap) {
    return originalMap.map<String, dynamic>((key, value) {
      final k = key.toString();
      dynamic v = value;
      if (value is Map<dynamic, dynamic>) {
        v = _convertDynamicMap(value);
      } else if (value is List) {
        v = value.map((e) {
          if (e is Map<dynamic, dynamic>) {
            return _convertDynamicMap(e);
          }
          return e;
        }).toList();
      }
      return MapEntry(k, v);
    });
  }


  Widget _chip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: Colors.white70),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _KPI({required String title, required String value, required String secondary, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [_neonA, _neonB]),
              boxShadow: [
                BoxShadow(
                  color: _neonB.withOpacity(0.28),
                  blurRadius: 18,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                    style: TextStyle(color: Colors.white60, fontSize: 11.sp, letterSpacing: 1.2)),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(secondary, style: TextStyle(color: Colors.white70, fontSize: 12.5.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageBar(String label, double percent) {
    final p = percent.clamp(0, 100) / 100.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64.w,
                child: Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: p,
                      child: Container(
                        height: 10.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(colors: [_neonA, _neonC]),
                          boxShadow: [
                            BoxShadow(color: _neonC.withOpacity(0.25), blurRadius: 10, spreadRadius: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text('${percent.toStringAsFixed(0)}%',
                  style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: Colors.white60, fontSize: 12.sp)),
        SizedBox(width: 6.w),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5.sp)),
      ],
    );
  }

  Widget _stateTile(String title, String value, IconData icon) {
    return Container(
      width: 220.w,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_cardStart, _cardEnd]),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Text(value, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 13.5.sp, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: Colors.white70),
              SizedBox(width: 6.w),
              Text(title, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _correlationPill(String label, double value) {
    final sign = value == 0 ? '' : value > 0 ? '+' : '';
    final col = value == 0 ? Colors.white70 : value > 0 ? _neonC : Colors.redAccent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: col.withOpacity(0.18), blurRadius: 12, spreadRadius: 0.5),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bubble_chart, size: 16.r, color: col),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          SizedBox(width: 8.w),
          Container(width: 1, height: 16.h, color: Colors.white12),
          SizedBox(width: 8.w),
          Text('$sign${value.toStringAsFixed(2)}',
              style: TextStyle(color: col, fontSize: 13.sp, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16.r),
        SizedBox(width: 8.w),
        Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5.sp)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MATH HELPERS
  // ---------------------------------------------------------------------------
  double _avg(List<double> xs) => xs.isEmpty ? 0 : xs.reduce((a,b)=>a+b) / xs.length;
  double _min(List<double> xs) => xs.isEmpty ? 0 : xs.reduce(min);
  double _max(List<double> xs) => xs.isEmpty ? 0 : xs.reduce(max);


  // Robust parser for duration strings into hours (for internal calculations only)
  double _parseHours(String s) {
    try {
      final t = s.trim().toUpperCase();
      // ISO 8601 like PT7H30M
      final iso = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?$');
      final mIso = iso.firstMatch(t);
      if (mIso != null) {
        final h = (mIso.group(1) ?? '0');
        final mm = (mIso.group(2) ?? '0');
        return double.parse(h) + double.parse(mm)/60.0;
      }
      // HH:MM
      if (t.contains(':')) {
        final parts = t.split(':');
        final h = double.tryParse(parts[0]) ?? 0;
        final mm = double.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        return h + mm/60.0;
      }
      // "7h 30m", "7h", "450m"
      final hRe = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*h');
      final mRe = RegExp(r'([0-9]+)\s*m');
      final mh = hRe.firstMatch(t);
      final mm = mRe.firstMatch(t);
      if (mh != null || mm != null) {
        final h = mh != null ? double.parse(mh.group(1)!) : 0.0;
        final m = mm != null ? double.parse(mm.group(1)!) : 0.0;
        return h + m/60.0;
      }
      // Plain number assume hours
      final asNum = double.tryParse(t);
      if (asNum != null) return asNum;
    } catch (_) {}
    return 0.0;
  }

  // ---------------------------------------------------------------------------
  // VISUALS
  // ---------------------------------------------------------------------------
  Widget _glowOrb(double size, Color c) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: c, blurRadius: size * .5, spreadRadius: size * .12)],
    ),
  );
}

// ============================================================================
//  WIDGETS (Private)
// ============================================================================

class _NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _NeoCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardStart, _cardEnd],
        ),
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> points;
  const _Sparkline({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(points: points),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  _SparklinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final xs = points.isEmpty ? [0.0, 0.0, 0.0] : points;
    final minV = xs.reduce(min);
    final maxV = xs.reduce(max);
    final range = max(0.0001, maxV - minV);
    final dx = size.width / (xs.length - 1);

    // background grid
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // line
    final path = Path();
    for (int i = 0; i < xs.length; i++) {
      final x = i * dx;
      final y = size.height - ((xs[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // gradient stroke
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = const LinearGradient(colors: [_neonA, _neonB, _neonC]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);

    // glow
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = _neonB.withOpacity(0.08);
    canvas.drawPath(path, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final s = 1 + 0.25 * sin(2 * pi * t);
        return Transform.scale(
          scale: s,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}

// Circular arc gauge painter
class _CircularArcGauge extends CustomPainter {
  final double value;
  final double max;
  final double start; // degrees
  final double sweep; // degrees
  final Color trackColor;
  final Gradient gradient;

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
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2);
    final startR = start * pi / 180;
    final sweepR = sweep * pi / 180;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round;

    // track
    canvas.drawArc(rect, startR, sweepR, false, track);
    // progress
    final p = (value / max).clamp(0.0, 1.0);
    canvas.drawArc(rect, startR, sweepR * p, false, prog);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Animated neural mesh background
class _NeuralMesh extends StatefulWidget {
  const _NeuralMesh();

  @override
  State<_NeuralMesh> createState() => _NeuralMeshState();
}

class _NeuralMeshState extends State<_NeuralMesh> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _NeuralMeshPainter(progress: _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NeuralMeshPainter extends CustomPainter {
  final double progress;
  _NeuralMeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.05);

    // dynamic curved lines
    for (int i = 0; i < 7; i++) {
      final path = Path();
      final amp = 20 + 12 * sin(progress * 2 * pi + i);
      final phase = progress * 2 * pi + i * 0.7;
      for (double x = -20; x <= size.width + 20; x += 16) {
        final y = size.height * (i + 1) / 8 + sin((x / 90) + phase) * amp;
        if (x == -20) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}