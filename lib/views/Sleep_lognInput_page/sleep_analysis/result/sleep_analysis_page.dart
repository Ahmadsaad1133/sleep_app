import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/tabs/dream_tab.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/error_state.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/loading_state.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_environment_analysis.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/cosmic_background.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/creative_app_bar.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/dreamscape_visualization.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/starry_background.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/tabs/insights_tab.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/tabs/overview_tab.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/tabs/report_tab.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/tabs/sleep_details_tab.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets2/tabs/metrics_tab.dart';
import '../../../../constants/colors.dart';
import '../../../services/api/api_service.dart';
import '../models/sleeplog_model_page.dart';
import '../plan/sleep_ai_plan_page.dart';

class SleepAnalysisResultPage extends StatelessWidget {
  final Map<String, dynamic>? analysisResult;
  final SleepLog? sleepLog;
  final String? sleepLogId;

  const SleepAnalysisResultPage({
    super.key,
    this.analysisResult,
    this.sleepLog,
    this.sleepLogId,
  });

  @override
  Widget build(BuildContext context) {
    return _SleepAnalysisResultPageContent(
      key: key,
      analysisResult: analysisResult,
      sleepLog: sleepLog,
      sleepLogId: sleepLogId,
    );
  }
}

class SleepFactorDisplay {
  final String name;
  final double? currentValue;
  final double? maxValue;

  SleepFactorDisplay({
    required this.name,
    this.currentValue,
    this.maxValue,
  });
}

class _SleepAnalysisResultPageContent extends StatefulWidget {
  final Map<String, dynamic>? analysisResult;
  final SleepLog? sleepLog;
  final String? sleepLogId;

  const _SleepAnalysisResultPageContent({
    super.key,
    this.analysisResult,
    this.sleepLog,
    this.sleepLogId,
  });

  @override
  State<_SleepAnalysisResultPageContent> createState() =>
      _SleepAnalysisResultPageContentState();
}

class _SleepAnalysisResultPageContentState
    extends State<_SleepAnalysisResultPageContent>
    with TickerProviderStateMixin {
  late Future<Map<String, dynamic>> _analysisFuture;
  final ConfettiController _confettiController = ConfettiController();
  int _sleepScore = 0;
  List<String> _aiHighlights = [];
  List<String> _recommendations = [];
  SleepLog? _lastSleepLog;
  bool _isAnalysisParsed = false;
  bool _patternVisualization = false;
  late TabController _tabController;
  Map<String, dynamic> _sleepMetrics = {};
  Map<String, double> _sleepStages = {};
  Map<String, dynamic> _sleepTrends = {};
  String _detailedReport = '';
  late AnimationController _scoreAnimationController;
  Map<String, dynamic> _sleepPatterns = {};
  List<String> _predictiveWarnings = [];
  Map<String, dynamic> _behavioralFactors = {};
  String _chronotype = '';
  String _sleepMidpoint = '';
  List<Map<String, dynamic>> _interventions = [];
  Map<String, dynamic> _sleepEfficiencyAnalysis = {};
  Map<String, dynamic> _sleepDepthAnalysis = {};
  Map<String, dynamic> _recoveryAnalysis = {};
  Map<String, dynamic> _sleepEnvironmentAnalysis = {};
  List<Map<String, dynamic>> _sleepCycles = [];
  bool _isLoadingEnvironment = false;
  String? _environmentError;
  late Future<String> _historicalAnalysisFuture;
  List<SleepLog> _recentLogs = [];

  /// Compute sleep stage percentages from the latest sleep log and fetch
  /// a detailed sleep stages analysis. This ensures that the sleep stages
  /// passed to the API are normalized percentages rather than raw minutes.
  ///
  /// The SleepLog model stores `deepSleepMinutes`, `remSleepMinutes`, and
  /// `lightSleepMinutes` values. These are minutes by default, which will
  /// cause the `getSleepStagesAnalysis` API to reject the input (because it
  /// expects percentages that sum between 50 and 150). This helper sums
  /// the minutes, converts each stage into a percentage, and then calls
  /// `ApiService.getSleepStagesAnalysis` with a properly structured map.
  ///
  /// Once complete, `_sleepStages` is updated with capitalized keys for
  /// display in the UI (e.g. "Deep", "REM", "Light").
  Future<void> _computeSleepStagesAnalysis() async {
    // If we already have a valid sleep stages map (values sum to a normal
    // percentage range), no need to recompute.
    final currentSum = _sleepStages.values.fold(0.0, (a, b) => a + b);
    if (currentSum >= 50.0 && currentSum <= 150.0) {
      return;
    }

    // Prefer the last loaded log; fall back to the widget's sleepLog if needed.
    final log = _lastSleepLog ?? widget.sleepLog;
    if (log == null) return;

    // Extract minute values from the SleepLog, defaulting to 0 if null.
    final double deepMinutes = (log.deepSleepMinutes ?? 0).toDouble();
    final double remMinutes = (log.remSleepMinutes ?? 0).toDouble();
    final double lightMinutes = (log.lightSleepMinutes ?? 0).toDouble();
    final double totalMinutes = deepMinutes + remMinutes + lightMinutes;

    // Avoid division by zero; if no minutes are recorded, keep stages at zero.
    if (totalMinutes <= 0) {
      setState(() {
        _sleepStages = {
          'Deep': 0.0,
          'REM': 0.0,
          'Light': 0.0,
        };
      });
      return;
    }

    // Calculate percentages for each stage.
    final Map<String, double> percentMap = {
      'Deep': (deepMinutes / totalMinutes) * 100,
      'REM': (remMinutes / totalMinutes) * 100,
      'Light': (lightMinutes / totalMinutes) * 100,
    };

    // Build the API payload with lowercase keys as expected by the backend.
    final Map<String, double> apiMap = {
      'deep': percentMap['Deep']!,
      'rem': percentMap['REM']!,
      'light': percentMap['Light']!,
    };

    try {
      // Call the sleep stages analysis API. We ignore the response for now
      // because only the normalized input is critical for successful calls.
      await ApiService.getSleepStagesAnalysis(apiMap);
    } catch (_) {
      // Even if the analysis call fails, we still update the UI with
      // normalized percentages so that OverviewTab2050 receives valid data.
    }

    // Update the sleep stages map for the UI.
    setState(() {
      _sleepStages = Map<String, double>.from(percentMap);
    });
  }

  /// Weekly trend values in hours from the last 7 sleep logs.
  /// When populated, these values override the synthetic trend generated by
  /// [_getWeeklyTrend].
  List<double> _weeklyTrendData = [];

  // Dream/mood forecast state
  Map<String, dynamic>? _dreamMoodForecast;
  bool _isLoadingForecast = false;

  List<SleepFactorDisplay> _sleepFactorsDisplay = [
    SleepFactorDisplay(name: 'Duration'),
    SleepFactorDisplay(name: 'Efficiency'),
    SleepFactorDisplay(name: 'Quality'),
    SleepFactorDisplay(name: 'Continuity'),
  ];

  Map<String, int> get _sleepFactors {
    final map = <String, int>{};
    for (final factor in _sleepFactorsDisplay) {
      map[factor.name] = factor.currentValue?.toInt() ?? 0;
    }
    return map;
  }

  // ---------- helpers to safely coerce dynamic structures ----------
  Map<String, dynamic> _asMap(dynamic m) {
    if (m == null) return <String, dynamic>{};
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    if (m is String) {
      final trimmed = m.trim();
      if (trimmed.startsWith('{')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          // ignore JSON parse errors and fall through to empty map
        }
      }
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic l) {
    if (l == null) return <Map<String, dynamic>>[];
    if (l is List<Map<String, dynamic>>) return l;
    final list = l as List;
    return list.map((e) {
      if (e is Map<String, dynamic>) return e;
      if (e is Map) return Map<String, dynamic>.from(e);
      return <String, dynamic>{};
    }).toList();
  }

  Map<String, double> _asMapDouble(dynamic m) {
    if (m == null) return <String, double>{};
    final raw = _asMap(m);
    final out = <String, double>{};
    raw.forEach((k, v) {
      if (v is num) {
        out[k] = v.toDouble();
      } else {
        out[k] =
            double.tryParse(v?.toString() ?? '') ?? 0.0;
      }
    });
    return out;
  }

  List<String> _asStringList(dynamic l) {
    if (l == null) return <String>[];
    if (l is List<String>) return l;
    final list = l as List;
    return list
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _asRecommendationList(dynamic r) {
    if (r == null) return <String>[];
    if (r is List) {
      return r
          .map((e) {
        if (e is Map) {
          final map = e as Map;
          final title = map['title']?.toString() ?? '';
          final reason = map['reason']?.toString() ?? '';
          return title.isNotEmpty ? title : reason;
        }
        return e?.toString() ?? '';
      })
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [r.toString()];
  }

  Map<String, dynamic> _normalizeForecastForInsights(
      Map<String, dynamic>? forecast) {
    final Map<String, dynamic> insights = {};
    if (forecast == null) return insights;
    final dp = forecast['dream_prediction'];
    final mf = forecast['mood_forecast'];
    final ca = forecast['cognitive_assessment'];
    // Map dream prediction to dream_vividness
    if (dp is Map) {
      final prediction = dp['prediction'];
      final explanation = dp['explanation'];
      insights['dream_vividness'] = {
        'level': prediction ?? 'N/A',
        'prediction':
        explanation ?? 'No data',
      };
    }
    // Mood forecast can be passed directly (keep mood and confidence)
    if (mf is Map) {
      insights['mood_forecast'] = {
        'mood': mf['mood'] ?? 'Unknown',
        'confidence': mf['confidence'] ?? 0,
      };
    }
    // Map cognitive assessment to cognitive performance indices (focus, memory, problem solving).
    // If creative_processing_index is unavailable or zero, fall back to emotional_insight_index or threat_processing_index.
    if (ca is Map) {
      final num? psi =
      ca['problem_solving_index'] as num?;
      final num? mci =
      ca['memory_consolidation_index']
      as num?;
      final num? cpi =
      ca['creative_processing_index'] as num?;
      final num? eii =
      ca['emotional_insight_index'] as num?;
      final num? tpi =
      ca['threat_processing_index'] as num?;
      // Choose focus value: prefer creative processing, otherwise emotional or threat indices
      final double focusVal = () {
        if (cpi != null && cpi > 0) {
          return cpi.toDouble();
        }
        if (eii != null && eii > 0) {
          return eii.toDouble();
        }
        if (tpi != null && tpi > 0) {
          return tpi.toDouble();
        }
        return 0.0;
      }();
      insights['cognitive_performance'] = {
        'focus': focusVal,
        'memory': (mci ?? 0).toDouble(),
        'problem_solving': (psi ?? 0).toDouble(),
      };
    }
    return insights;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return "0h 0m";
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  Future<Map<String, dynamic>> _getDailyComparison() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {}; // ✅ رجّع Map فاضي مش return بس

      final logsCollection = FirebaseFirestore.instance
          .collection('user_sleep_logs')
          .doc(user.uid)
          .collection('logs'); // ✅ fixed path

      final snapshot = await logsCollection
          .orderBy('date', descending: true) // ✅ use 'date'
          .limit(7)
          .get();

      debugPrint("Fetched ${snapshot.docs.length} logs for ${user.uid}");

      if (snapshot.docs.length < 2) {
        debugPrint('Not enough logs for comparison (found ${snapshot.docs.length})');
        return {};
      }

      final currentLogData = snapshot.docs[0].data();
      final previousLogData = snapshot.docs[1].data();

      debugPrint("Current log: $currentLogData");
      debugPrint("Previous log: $previousLogData");

      final currentLog = SleepLog.fromMap(currentLogData, snapshot.docs[0].id);
      final previousLog = SleepLog.fromMap(previousLogData, snapshot.docs[1].id);

      final comparison = await ApiService.compareSleepLogs(
        currentLog: currentLog.toMap(),
        previousLog: previousLog.toMap(),
      );

      return (comparison ?? {});
    } catch (e, st) {
      debugPrint('Error in daily comparison: $e\n$st');
      return {};
    }
  }


  List<Map<String, dynamic>>
  _getLifestyleCorrelations() {
    // Use API data if available, otherwise fall back to calculated values.
    final apiCorrelations = _asListOfMaps(
        widget.analysisResult?['lifestyleCorrelations']);

    return apiCorrelations;
  }

  int _calculateSleepDebt() {
    final targetHours = 8; // User's sleep target
    final actualHours =
        (_lastSleepLog?.durationMinutes ??
            0) /
            60;
    return (targetHours - actualHours)
        .clamp(0, 24)
        .toInt();
  }

  List<double> _getWeeklyTrend() {
    if (_weeklyTrendData.isNotEmpty) {
      return _weeklyTrendData;
    }
    return [];
  }


  /// Wrapper around `_getDailyComparison` that returns a normalized map for the UI.
  Future<Map<String, dynamic>> _getDailyComparisonNormalized() async {
    final raw = await _getDailyComparison();
    return _asMap(raw);

  }
  Future<void> _loadWeeklyTrendData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final logsCollection = FirebaseFirestore.instance
          .collection('user_sleep_logs')
          .doc(user.uid)
          .collection('logs'); // ✅ fixed path

      final snapshot = await logsCollection
          .orderBy('date', descending: true) // ✅ use 'date'
          .limit(7)
          .get();

      final List<double> points = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final dynamic minutes = data['duration_minutes'];

        if (minutes is num) {
          points.add(minutes.toDouble() / 60.0);
        } else {
          final parsed = double.tryParse(minutes?.toString() ?? '');
          if (parsed != null) points.add(parsed / 60.0);
        }
      }

      final ordered = points.reversed.toList();
      if (mounted) {
        setState(() {
          _weeklyTrendData = ordered;
        });
      } else {
        _weeklyTrendData = ordered;
      }
    } catch (e, st) {
      debugPrint('Error loading weekly trend: $e\n$st');
    }
  }


  /// Derive a morning readiness score from the dream/mood forecast or fallback to the sleep score.
  int _getMorningReadiness() {
    final forecast = _dreamMoodForecast;
    if (forecast != null) {
      final ca = forecast['cognitive_assessment'];
      if (ca is Map) {
        final idx = ca['problem_solving_index'];
        if (idx is num) {
          return idx.toInt().clamp(0, 100);
        }
      }
      final cp = forecast['cognitive_performance'];
      if (cp is Map) {
        final ps = cp['problem_solving'];
        if (ps is num) {
          return ps.toInt().clamp(0, 100);
        }
      }
    }
    return _sleepScore;
  }


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAnalysisData();
    _tabController =
        TabController(length: 6, vsync: this);
    // Preload weekly trend data based on the last 7 sleep logs.
    _loadWeeklyTrendData();
  }

  void _initializeAnimations() {
    _scoreAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        );
  }

  void _initializeAnalysisData() {
    if (widget.analysisResult != null &&
        widget.sleepLog != null) {
      _lastSleepLog = widget.sleepLog;
      _parseProfessionalAnalysis(
          widget.analysisResult!);
      _sleepScore =
          _calculateSleepScore(_lastSleepLog!);
      _calculateSleepFactors();
      _isAnalysisParsed = true;
      _scoreAnimationController.forward();
      if (_sleepScore >= 85) {
        _confettiController.play();
      }
      _analysisFuture = Future.value({
        'log': _lastSleepLog,
        'score': _sleepScore,
      });

      // Use preloaded data directly
      _sleepEnvironmentAnalysis =
          _asMap(widget.analysisResult?['environment_analysis']);
      _dreamMoodForecast = _asMap(
          widget.analysisResult?['dream_mood_forecast']);
      _historicalAnalysisFuture = Future.value(
          widget.analysisResult?['historical_analysis']?.toString() ??
              '');

      // Normalize sleep stage values into percentages and trigger the API.
      _computeSleepStagesAnalysis();
    } else {
      _analysisFuture =
          _fetchAndAnalyzeLastLog();
    }
  }

  void _parseProfessionalAnalysis(
      Map<String, dynamic> parsed) {
    try {
      final safeParsed = _asMap(parsed);

      setState(() {
        _sleepScore =
        (safeParsed['sleepScore'] is int)
            ? safeParsed['sleepScore']
        as int
            : int.tryParse(
            safeParsed['sleepScore']
                ?.toString() ??
                '') ??
            _sleepScore;
        _aiHighlights =
            _asStringList(safeParsed['key_insights']);
        final insightsRaw = safeParsed['sleep_insights'];
        final insights = _asMap(insightsRaw);
        final insightsData = _asMap(insights['data']);
        _aiHighlights = _asStringList(
            insightsData['key_insights'] ??
                insights['key_insights'] ??
                safeParsed['key_insights']);
        _recommendations = _asRecommendationList(
            insightsData['recommendations'] ??
                insights['recommendations'] ??
                safeParsed['recommendations']);
        _sleepMetrics =
            _asMap(
                safeParsed['sleepMetrics']);
        _sleepStages =
            _asMapDouble(
                safeParsed['sleepStages']);

        // Fallback: derive sleep stage percentages from the last sleep log when

        _detailedReport =
            safeParsed['detailedReport']
                ?.toString() ??
                'No report available. Analysis data: ${safeParsed.toString()}';

        _sleepPatterns =
            _asMap(safeParsed['sleepPatterns']);
        _predictiveWarnings =
            _asStringList(
                safeParsed['predictiveWarnings']);
        _behavioralFactors =
            _asMap(safeParsed['behavioralFactors']);
        _chronotype = safeParsed['chronotype']
            ?.toString() ??
            '';
        _sleepMidpoint =
            safeParsed['sleepMidpoint']
                ?.toString() ??
                '';

        _interventions =
            _asListOfMaps(
                safeParsed['interventions']);
        _sleepEfficiencyAnalysis =
            _asMap(
                safeParsed['sleepEfficiencyAnalysis']);
        _sleepDepthAnalysis =
            _asMap(
                safeParsed['sleepDepthAnalysis']);
        _recoveryAnalysis =
            _asMap(
                safeParsed['recoveryAnalysis']);
        _sleepCycles =
            _asListOfMaps(
                safeParsed['sleepCycles']);
        _sleepTrends =
            _asMap(
                safeParsed['sleepTrends']);

        _isAnalysisParsed = true;
      });
    } catch (e) {
      setState(() {
        _isAnalysisParsed = false;
      });
    }
  }

  int _calculateSleepScore(SleepLog log) {
    double score = 0;
    score += (log.durationMinutes /
        540 *
        40)
        .clamp(0, 40);
    score += (log.quality * 4)
        .clamp(0, 40);
    score += (1 -
        (log.stressLevel / 10)) *
        20;
    return score.clamp(0, 100).toInt();
  }

  void _calculateSleepFactors() {
    setState(() {
      _sleepFactorsDisplay = [
        SleepFactorDisplay(
          name: 'Duration',
          currentValue: (_lastSleepLog!
              .durationMinutes /
              540 *
              100)
              .clamp(0, 100),
          maxValue: 100,
        ),
        SleepFactorDisplay(
          name: 'Efficiency',
          currentValue: _sleepMetrics['efficiency']
              ?.toDouble() ??
              0,
          maxValue: 100,
        ),
        SleepFactorDisplay(
          name: 'Quality',
          currentValue:
          _lastSleepLog!.quality * 10,
          maxValue: 100,
        ),
        SleepFactorDisplay(
          name: 'Continuity',
          currentValue:
          _sleepMetrics['continuity']
              ?.toDouble() ??
              0,
          maxValue: 100,
        ),
      ];
    });
  }

  Future<Map<String, dynamic>>
  _fetchAndAnalyzeLastLog() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final query = await FirebaseFirestore.instance
          .collection('user_sleep_logs')
          .doc(user.uid)
          .collection('logs')
          .orderBy('date', descending: true)
          .limit(3)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(
            'No sleep logs found');
      }

      final logDoc = query.docs.first;
      final rawData = logDoc.data();
      final safeData = (rawData is Map)
          ? Map<String, dynamic>.from(
          rawData)
          : <String, dynamic>{};
      final log = SleepLog.fromMap(
          safeData, logDoc.id);

      final logs = [log.toMap()];

      final analysis =
      await ApiService.fetchSleepAnalysis(
          logs);
      final safeAnalysis = (analysis is Map)
          ? Map<String, dynamic>.from(analysis)
          : <String, dynamic>{};
      try {
        safeAnalysis['sleep_insights'] =
        await ApiService().getInsights(log.toMap())
            .timeout(const Duration(seconds: 20));
        safeAnalysis['historical_analysis'] =
        await ApiService.getHistoricalSleepAnalysis(limit: 10)
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        safeAnalysis['sleep_insights'] = {
          'status': 'timeout',
          'message': 'Insights timed out'
        };
        safeAnalysis['historical_analysis'] =
        'Historical analysis timed out';
      }

      _parseProfessionalAnalysis(safeAnalysis);
      _lastSleepLog = log;
      _sleepScore =
          _calculateSleepScore(log);
      _calculateSleepFactors();
      _scoreAnimationController.forward();
      if (_sleepScore >= 85) {
        _confettiController.play();
      }

      // Normalize sleep stage values into percentages and trigger the API.
      await _computeSleepStagesAnalysis();

      return {
        'log': log.toMap(),
        'score': _sleepScore
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Widget _buildEnvironmentAnalysis() {
    return SleepEnvironmentAnalysis(
      environmentAnalysis:
      _sleepEnvironmentAnalysis,
    );
  }

  void _restartCometAnimation() {
    setState(() {});
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _confettiController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldExit =
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Analysis?'),
        content: const Text(
            'Are you sure you want to exit? Your analysis progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  color:
                  AppColors.primaryPurple),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(
                  color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top;
    const double tabBarHeight = 48.0;
    final double minExtentVal =
        topPadding +
            kToolbarHeight +
            tabBarHeight;
    final double maxExtentVal = 260;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor:
        const Color(0xFF0A0E21),
        body: Stack(
          children: [
            CosmicBackground(),
            const StarryBackground(),
            DreamscapeVisualization(
                showDreamscape:
                _sleepScore >= 75),
            NestedScrollView(
              headerSliverBuilder:
                  (context, innerBoxIsScrolled) =>
              [
                SliverOverlapAbsorber(
                  handle:
                  NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context),
                  sliver:
                  SliverPersistentHeader(
                    pinned: true,
                    delegate:
                    _CreativeHeaderDelegate(
                      builder: (t) =>
                          CreativeAppBar(
                            sleepScore:
                            _sleepScore,
                            isAnalysisParsed:
                            _isAnalysisParsed,
                            tabController:
                            _tabController,
                            shrinkPercent: t,
                          ),
                      minExtentVal:
                      minExtentVal,
                      maxExtentVal:
                      maxExtentVal,
                    ),
                  ),
                ),
              ],
              body: FutureBuilder<
                  Map<String, dynamic>>(
                future: _analysisFuture,
                builder:
                    (context, snapshot) {
                  if (snapshot
                      .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const LoadingState();
                  }

                  if (snapshot.hasError ||
                      snapshot.data
                          ?.containsKey(
                          'error') ==
                          true) {
                    return ErrorState(
                      error: snapshot.data?[
                      'error'] ??
                          'Unknown error',
                      onRetry: () {
                        setState(() {
                          _analysisFuture =
                              _fetchAndAnalyzeLastLog();
                          _scoreAnimationController
                              .reset();
                          _isAnalysisParsed =
                          false;
                          _environmentError =
                          null;
                          _sleepEnvironmentAnalysis =
                          {};
                        });
                      },
                    );
                  }

                  if (!_isAnalysisParsed) {
                    return const LoadingState();
                  }

                  return TabBarView(
                    controller:
                    _tabController,
                    children: [
                      // 0: Overview
                      Builder(
                        builder:
                            (tabContext) =>
                            _wrapTabWithSliverWidget(
                              tabContext,
                              'Overview',
                              OverviewTab2050(
                                sleepScore:
                                _sleepScore,
                                totalSleepDuration:
                                _formatDuration(_lastSleepLog?.durationMinutes ??
                                    0),
                                sleepEfficiency:
                                _lastSleepLog?.efficiencyScore ??
                                    0.0,
                                sleepDebt:
                                _calculateSleepDebt(),
                                sleepStages:
                                _sleepStages,
                                aiHighlights: _aiHighlights,
                                // Provide a normalized daily comparison so the UI always receives the expected keys.
                                weeklyTrend:
                                _getWeeklyTrend(),
                                lifestyleCorrelations:
                                _getLifestyleCorrelations(),
                                recommendations:
                                _recommendations,
                                confettiController:
                                _confettiController,
                                moodSummary:
                                _behavioralFactors['mood_summary']?.toString(),
                                dreamPrediction: _dreamMoodForecast?[
                                'dream_prediction']?['prediction']
                                    ?.toString(),
                                morningReadiness: _getMorningReadiness(),
                              ),
                            ),
                      ),

                      // 1: Details
                      Builder(
                        builder:
                            (tabContext) =>
                            _wrapTabWithSliverList(
                              tabContext,
                              'Details',
                              SleepDetailsTab(
                                environmentAnalysis:
                                _buildEnvironmentAnalysis(),
                                lastSleepLog:
                                _lastSleepLog,
                                preloadedQualityData:
                                _asMap(widget.analysisResult?[
                                'quality_breakdown']),
                                dreamMoodForecast:
                                _dreamMoodForecast,
                              ).slivers,
                            ),
                      ),

                      // 2: Metrics (NEW TAB)
                      Builder(
                        builder:
                            (tabContext) =>
                            _wrapTabWithSliverList(
                              tabContext,
                              'Metrics',
                              MetricsTab(
                                sleepMetrics:
                                _sleepMetrics,
                                sleepCycles:
                                _sleepCycles,
                                lastSleepLog:
                                _lastSleepLog,
                              ).slivers,
                            ),
                      ),

                      // 3: Insights
                      Builder(
                        builder:
                            (tabContext) =>
                            _wrapTabWithSliverWidget(
                              tabContext,
                              'Insights',
                              InsightsTab(
                                sleeplog:
                                _lastSleepLog!,
                                // Normalize the dream/mood forecast into a UI-friendly map
                                insightsData:
                                _normalizeForecastForInsights(
                                    _dreamMoodForecast),
                                historicalAnalysis: widget
                                    .analysisResult?['historical_analysis']
                                    ?.toString() ??
                                    '',
                              ),
                            ),
                      ),

                      // 4: Report
                      Builder(
                        builder:
                            (tabContext) =>
                            _wrapTabWithSliverWidget(
                              tabContext,
                              'Report',
                              ReportTab(
                                detailedReport:
                                _detailedReport,
                              ),
                            ),
                      ),

                      // 5: Dream
                      Builder(
                        builder:
                            (innerContext) {
                          final fabHeight =
                              Theme.of(innerContext).floatingActionButtonTheme.sizeConstraints?.minHeight ??
                                  56.0;

                          final dreamTab =
                          DreamTab(
                            key: const ValueKey(
                                'dream_tab'),
                            dreamMoodForecast:
                            _dreamMoodForecast,
                            sleepData:
                            _lastSleepLog?.toMap() ??
                                {},
                            onRetry: () {
                              setState(
                                      () {});
                            },
                            isLoading:
                            false,
                          );

                          return CustomScrollView(
                            key:
                            const PageStorageKey<
                                String>('sleep_analysis_tab_Dream'),
                            slivers: [
                              SliverOverlapInjector(
                                handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(innerContext),
                              ),
                              ...dreamTab.buildSlivers(
                                context:
                                innerContext,
                                dreamMoodForecast:
                                _dreamMoodForecast,
                                bottomPadding:
                                fabHeight +
                                    24.0,
                                backgroundHeight:
                                0.0,
                                dreamLabMinHeight:
                                1000.0,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child:
              FloatingActionButton.extended(
                onPressed: _createSleepPlan,
                backgroundColor:
                AppColors.primaryPurple,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      30),
                ),
                icon: const Icon(
                    Icons.nights_stay_rounded),
                label: const Text(
                  'Create Sleep Plan',
                  style: TextStyle(
                      fontWeight:
                      FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void>
  _createSleepPlan() async {
    try {
      // Generate a plan from the detailed report,
      // then navigate to SleepAIPlanPage with the plan.
      final plan = await ApiService.generateSleepPlan(_detailedReport);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SleepAIPlanPage(plan: plan),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
            content: Text(
                'Failed to create plan: $e')),
      );
    }
  }

  /// Wrap a list of slivers in a CustomScrollView with the appropriate
  /// SliverOverlapInjector. The [context] provided must be a descendant of a
  /// NestedScrollView.
  Widget _wrapTabWithSliverList(
      BuildContext context,
      String keyName,
      List<Widget> slivers,
      ) {
    return CustomScrollView(
      key: PageStorageKey<String>('sleep_analysis_tab_$keyName'),
      slivers: [
        SliverOverlapInjector(
          handle:
          NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        ...slivers,
        const SliverToBoxAdapter(
          child: SizedBox(height: 60),
        ),
      ],
    );
  }

  /// Wrap a single widget (non-sliver) in a CustomScrollView with overlap
  /// handling. The [context] must be inside a NestedScrollView.
  Widget _wrapTabWithSliverWidget(
      BuildContext context,
      String keyName,
      Widget tabContent,
      ) {
    return CustomScrollView(
      key: PageStorageKey<String>('sleep_analysis_tab_$keyName'),
      slivers: [
        SliverOverlapInjector(
          handle:
          NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverToBoxAdapter(child: tabContent),
        const SliverToBoxAdapter(
          child: SizedBox(height: 60),
        ),
      ],
    );
  }
}

class _CreativeHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget Function(double shrinkPercent) builder;
  final double minExtentVal;
  final double maxExtentVal;

  const _CreativeHeaderDelegate({
    required this.builder,
    required this.minExtentVal,
    required this.maxExtentVal,
  });

  @override
  double get minExtent => minExtentVal;

  @override
  double get maxExtent => maxExtentVal;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent) {
    final double currentExtent =
    (maxExtent - shrinkOffset).clamp(
        minExtent, maxExtent);
    final double t =
    ((currentExtent - minExtent) /
        (maxExtent - minExtent))
        .clamp(0.0, 1.0);
    return SizedBox(
      height: currentExtent,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          child: builder(t),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(
      covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
