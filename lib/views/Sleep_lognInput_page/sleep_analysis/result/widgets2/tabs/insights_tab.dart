// insights_tab.dart (refactored clean + raw widgets only)
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/sleeplog_model_page.dart';

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
  late final AnimationController _pulseController;
  late double _pulseOpacity;
  late String _aiTip;

  @override
  void initState() {
    super.initState();
    _aiTip = _generateDailyTip();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseOpacity = 0.3;
    _pulseController.addListener(() {
      if (!mounted) return;
      setState(() {
        _pulseOpacity = 0.2 + (_pulseController.value * 0.4);
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final insightsData = widget.insightsData;
    final historicalAnalysis = widget.historicalAnalysis;

    final dreamData = insightsData['dream_vividness'] ?? {
      'level': 'N/A',
      'prediction': 'No data',
    };
    final moodData = insightsData['mood_forecast'] ?? {
      'mood': 'Unknown',
      'confidence': 0,
    };
    final cognitiveData = insightsData['cognitive_performance'] ?? {
      'focus': 0,
      'memory': 0,
      'problem_solving': 0,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDreamVividness(dreamData),
          SizedBox(height: 16.h),
          _buildMoodForecast(moodData),
          SizedBox(height: 16.h),
          _buildCognitivePerformance(cognitiveData),
          SizedBox(height: 16.h),
          _buildAITip(),
          SizedBox(height: 16.h),
          _buildHistoricalSection(historicalAnalysis),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // -------------------- Sections --------------------

  Widget _buildDreamVividness(Map<String, dynamic> dreamData) {
    final String vividness = (dreamData['level'] ?? 'N/A').toString();
    final String prediction = (dreamData['prediction'] ?? 'No prediction').toString();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _glassTile(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vividness: $vividness",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            prediction,
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.4,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodForecast(Map<String, dynamic> moodData) {
    final String mood = (moodData['mood'] ?? 'Unknown').toString();
    final int confidence = (moodData['confidence'] is num)
        ? (moodData['confidence'] as num).clamp(0, 100).toInt()
        : 0;

    final Color moodColor = _colorForMood(mood);
    final double progressValue = confidence / 100.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _glassTile(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_emotions, color: moodColor),
              SizedBox(width: 8.w),
              Text(
                "Predicted mood: $mood",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 12.h,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(moodColor),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Confidence Level",
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
              Text(
                "$confidence%",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: moodColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCognitivePerformance(Map<String, dynamic> cognitiveData) {
    final int focus = (cognitiveData['focus'] ?? 0) is num ? (cognitiveData['focus'] as num).toInt() : 0;
    final int memory = (cognitiveData['memory'] ?? 0) is num ? (cognitiveData['memory'] as num).toInt() : 0;
    final int problemSolving = (cognitiveData['problem_solving'] ?? 0) is num
        ? (cognitiveData['problem_solving'] as num).toInt()
        : 0;

    return Column(
      children: [
        _buildCognitiveMetric("Focus", focus, Colors.blueAccent),
        SizedBox(height: 14.h),
        _buildCognitiveMetric("Memory", memory, Colors.greenAccent),
        SizedBox(height: 14.h),
        _buildCognitiveMetric("Problem Solving", problemSolving, Colors.orangeAccent),
      ],
    );
  }

  Widget _buildCognitiveMetric(String label, int percentage, Color color) {
    final double v = (percentage.clamp(0, 100)) / 100.0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _glassTile(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                "$percentage%",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 10.h,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITip() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _glassTile(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: _pulseOpacity,
            child: Icon(Icons.auto_awesome, color: Colors.amber, size: 28.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _aiTip,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: Colors.amber.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSection(String markdown) {
    final text = (markdown.isEmpty) ? "_No historical analysis available yet._" : markdown;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _glassTile(),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(color: Colors.white70, fontSize: 13.5.sp, height: 1.4),
          h2: TextStyle(color: Colors.white, fontSize: 16.5.sp, fontWeight: FontWeight.w800),
          h3: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
          blockquote: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  // -------------------- Helpers --------------------

  String _generateDailyTip() {
    const tips = [
      "Aim for consistent bed and wake times for better circadian rhythm.",
      "Limit caffeine after mid-afternoon to improve sleep onset latency.",
      "Dim screens 60–90 minutes before bed to reduce blue-light impact.",
      "A brief evening stretch can promote deeper, more restorative sleep.",
      "Keep your bedroom cool, dark, and quiet for optimal sleep quality.",
    ];
    final index = DateTime.now().day % tips.length;
    return tips[index];
  }

  Color _colorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'positive':
        return Colors.greenAccent;
      case 'neutral':
        return Colors.cyanAccent;
      case 'sad':
      case 'negative':
        return Colors.orangeAccent;
      case 'stressed':
        return Colors.pinkAccent;
      default:
        return Colors.blueAccent;
    }
  }
}

// Glass tile styling
BoxDecoration _glassTile() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: Colors.white12),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white54, Colors.white12],
      stops: [0.0, 1.0],
    ).scale(0.11),
  );
}
