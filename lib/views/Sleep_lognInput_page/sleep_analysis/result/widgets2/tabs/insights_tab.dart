// insights_tab.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../services/api/api_service.dart';
import '../../../models/sleeplog_model_page.dart';
import '../neo_design.dart';

class InsightsTab extends StatefulWidget {
  final SleepLog sleeplog;
  final Map<String, dynamic> insightsData;
  final String historicalAnalysis;

  const InsightsTab({
    super.key,
    required this.sleeplog,
    required this.insightsData,
    required this.historicalAnalysis,
  });

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab>
    with AutomaticKeepAliveClientMixin<InsightsTab>, TickerProviderStateMixin {
  late String _aiTip;
  final _random = Random();
  late AnimationController _pulseController;
  double _pulseOpacity = 0.4;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _aiTip = _generateDailyTip();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseController.addListener(() {
      if (mounted) {
        setState(() {
          _pulseOpacity = 0.2 + (_pulseController.value * 0.4);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _generateDailyTip() {
    const tips = [
      'Maintain consistent sleep schedule for better rest',
      'Avoid caffeine 6 hours before bedtime',
      'Keep your bedroom cool and dark',
      'Limit screen time before bed to improve sleep quality',
      'Try meditation before sleep to reduce stress',
      'Ensure your mattress and pillows provide proper support',
    ];
    return tips[_random.nextInt(tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final insightsData = widget.insightsData;
    final historicalAnalysis = widget.historicalAnalysis;

    final dreamData = insightsData['dream_vividness'] ?? {
      'level': 'N/A',
      'prediction': 'No data'
    };
    final moodData = insightsData['mood_forecast'] ?? {
      'mood': 'Unknown',
      'confidence': 0
    };
    final cognitiveData = insightsData['cognitive_performance'] ?? {
      'focus': 0,
      'memory': 0,
      'problem_solving': 0
    };

    return Container(
      decoration: const BoxDecoration(
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCosmicCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.nightlight_round,
                      title: "Dream Analysis",
                      color: Colors.deepPurple,
                    ),
                    SizedBox(height: 10.h),
                    _buildDreamVividness(dreamData),
                  ]),
            ),
            SizedBox(height: 16.h),
            _buildCosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    icon: Icons.mood,
                    title: "Mood Forecast",
                    color: Colors.amber,
                  ),
                  SizedBox(height: 16.h),
                  _buildMoodForecast(moodData),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildCosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    icon: Icons.lightbulb_outline,
                    title: "Cognitive Performance",
                    color: Colors.teal,
                  ),
                  SizedBox(height: 16.h),
                  _buildCognitivePerformance(cognitiveData),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildCosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    icon: Icons.tips_and_updates,
                    title: "AI Tip of the Day",
                    color: Colors.lightBlue,
                  ),
                  SizedBox(height: 16.h),
                  _buildAITip(),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildCosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    icon: Icons.history,
                    title: "Historical Sleep Analysis",
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16.h),
                  _buildHistoricalSection(historicalAnalysis),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Builds a glass‑like cosmic card with unified styling.
  Widget _buildCosmicCard({required Widget child}) {
    return NeoCard(
      padding: EdgeInsets.all(20.w),
      child: child,
    );
  }

  Widget _buildDreamVividness(Map<String, dynamic> dreamData) {
    final vividness = dreamData['level'] ?? 'N/A';
    final prediction = dreamData['prediction'] ?? 'No prediction';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                vividness.toString(),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.deepPurpleAccent,
                  height: 1.2,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade400,
                  ],
                ),
              ),
              child: Icon(
                vividness.toString().contains('High') ? Icons.nightlight_round : Icons.cloud,
                size: 24.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          prediction,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodForecast(Map<String, dynamic> moodData) {
    final mood = moodData['mood'] ?? 'N/A';
    final confidenceRaw = moodData['confidence'] ?? 0;
    final confidence = (confidenceRaw is num) ? confidenceRaw.toDouble() : double.tryParse(confidenceRaw.toString()) ?? 0.0;
    final progressValue = (confidence.clamp(0.0, 100.0)) / 100.0;
    final moodColor = _getMoodColor(mood.toString());

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mood.toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: moodColor,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "${confidence.toInt()}%",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: moodColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        LinearProgressIndicator(
          value: progressValue,
          minHeight: 14.h,
          borderRadius: BorderRadius.circular(10.r),
          backgroundColor: Colors.grey.shade800,
          color: moodColor,
          valueColor: AlwaysStoppedAnimation<Color>(moodColor),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Confidence Level",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
            Text(
              "${confidence.toInt()}%",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCognitivePerformance(Map<String, dynamic> cognitiveData) {
    final focus = cognitiveData['focus'] ?? 0;
    final memory = cognitiveData['memory'] ?? 0;
    final problemSolving = cognitiveData['problem_solving'] ?? 0;

    return Column(
      children: [
        _buildCognitiveMetric("Focus", focus, Colors.blueAccent),
        SizedBox(height: 16.h),
        _buildCognitiveMetric("Memory", memory, Colors.greenAccent),
        SizedBox(height: 16.h),
        _buildCognitiveMetric("Problem Solving", problemSolving, Colors.orange),
      ],
    );
  }

  Widget _buildCognitiveMetric(String label, dynamic value, Color color) {
    final val = (value is num) ? value.toDouble().clamp(0.0, 100.0) : double.tryParse(value.toString()) ?? 0.0;
    final percentage = val.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 14.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.grey.shade800,
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOut,
                width: MediaQuery.of(context).size.width * (percentage / 100) * 0.6,
                height: 14.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAITip() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.lightBlue.shade400,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.amber,
            size: 32.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            _aiTip,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontStyle: FontStyle.italic,
              color: Colors.amber.shade200,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSection(String historicalAnalysis) {
    return MarkdownBody(
      data: historicalAnalysis,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: Colors.white70,
          fontSize: 14.sp,
          height: 1.5,
        ),
        h1: TextStyle(
          color: Colors.blue.shade300,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
        h2: TextStyle(
          color: Colors.green.shade300,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
        h3: TextStyle(
          color: Colors.purple.shade300,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
        listBullet: TextStyle(
          color: Colors.white70,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'positive':
        return Colors.greenAccent;
      case 'neutral':
        return Colors.amber;
      case 'negative':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }
}