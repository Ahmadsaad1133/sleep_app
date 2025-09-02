import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:particles_flutter/particles_flutter.dart';

import '../../../services/api/api_service.dart';
import '../result/sleep_analysis_page.dart';
import '../models/sleeplog_model_page.dart';



import '../../../../constants/colors.dart';
import '../../../../constants/fonts.dart';
import 'mini_pc_panel.dart';


class AILoadingAnalysisPage extends StatefulWidget {
  final SleepLog sleepLog;
  const AILoadingAnalysisPage({Key? key, required this.sleepLog}) : super(key: key);

  @override
  _AILoadingAnalysisPageState createState() => _AILoadingAnalysisPageState();
}

class _AILoadingAnalysisPageState extends State<AILoadingAnalysisPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;
  late Animation<double> _pulseAnim;

  // State variables
  double _progress = 0.0;
  String _currentStep = "Initializing cosmic analysis...";
  final List<String> _steps = const [
    "Saving cosmic sleep log...",
    "Analyzing dream patterns...",
    "Analyzing sleep environment...",
    "Analyzing sleep quality...",
    "Generating dream forecast...",
    "Generating sleep insights...",
    "Finalizing cosmic analysis..."
  ];
  final Random _random = Random();
  late List<vm.Vector3> _quantumParticles;
  int _activeStepIndex = 0;
  double _currentStepProgress = 0.0;
  bool _showCompletion = false;
  bool _isProcessing = true;
  DateTime? _lastBackPressTime;
  final Color _activeColor = AppColors.primaryColor;

  // Analysis data storage
  Map<String, dynamic> _fullAnalysisData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializeParticles();
    _startAnalysisProcess();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 0.95), weight: 50),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOut));

    _colorAnim = ColorTween(
      begin: _activeColor.withOpacity(0.7),
      end: _adjustColorLightness(_activeColor, 0.2),
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOut));

    _pulseAnim = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  void _initializeParticles() {
    _quantumParticles = List.generate(150, (index) {
      return vm.Vector3(
        _random.nextDouble() * 2 - 1,
        _random.nextDouble() * 2 - 1,
        _random.nextDouble() * 2 - 1,
      );
    });
  }

  Future<void> _startAnalysisProcess() async {
    await _ensureAnonymousAuth();
    _saveLogAndAnalyze();
  }

  Color _adjustColorLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Future<void> _ensureAnonymousAuth() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _mainController.stop();
      _pulseController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _mainController.repeat();
    }
  }

  // Fixed analysis process with proper timing and error handling
  Future<void> _saveLogAndAnalyze() async {
    try {
      // Step 1: Save to Firestore
      _updateStep(0, "Saving cosmic sleep log...");
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('anonymous_sleep_logs')
          .doc(uid)
          .collection('logs')
          .add(widget.sleepLog.toMap());
      _updateProgress(15);
      // Introduce a longer delay between sections to improve pacing.
      await Future.delayed(const Duration(seconds: 5));

      // Step 2: Enhanced dream analysis (if applicable)
      if (widget.sleepLog.dreamJournal.isNotEmpty) {
        _updateStep(1, "Analyzing dream patterns...");
        try {
          _fullAnalysisData['enhanced_dream_analysis'] =
          await ApiService.getEnhancedDreamAnalysis(
            dreamJournal: widget.sleepLog.dreamJournal,
            dreamElements: widget.sleepLog.dreamElements,
            mood: widget.sleepLog.mood,
            sleepQuality: widget.sleepLog.quality,
            stressLevel: widget.sleepLog.stressLevel,
          ).timeout(const Duration(seconds: 30));
        } on TimeoutException {
          _fullAnalysisData['enhanced_dream_analysis'] = {"status": "timeout", "message": "Dream analysis timed out"};
        }
        _updateProgress(30);
        await Future.delayed(const Duration(seconds: 5));
      } else {
        // Skip dream analysis if no journal
        _updateProgress(30);
        await Future.delayed(const Duration(seconds: 5));
      }

      // Step 3: Sleep Environment Analysis
      _updateStep(2, "Analyzing sleep environment...");
      try {
        _fullAnalysisData['environment_analysis'] =
        await ApiService.getSleepEnvironmentRecommendations(
          widget.sleepLog.noiseLevel,
          widget.sleepLog.lightExposure,
          widget.sleepLog.temperature,
          widget.sleepLog.comfortLevel,
        ).timeout(const Duration(seconds: 20));
      } on TimeoutException {
        _fullAnalysisData['environment_analysis'] = {"status": "timeout", "message": "Environment analysis timed out"};
      }
      _updateProgress(45);
      await Future.delayed(const Duration(seconds: 5));

      // Step 4: Sleep Quality Breakdown
      _updateStep(3, "Analyzing sleep quality...");
      Map<String, dynamic> sleepQualityData = {
        'duration_minutes': widget.sleepLog.durationMinutes,
        'disturbances': widget.sleepLog.disturbances.length,
        'waso_minutes': widget.sleepLog.wasoMinutes ?? 0,
        'deep_sleep_minutes': widget.sleepLog.deepSleepMinutes ?? 0,
        'rem_sleep_minutes': widget.sleepLog.remSleepMinutes ?? 0,
        'light_sleep_minutes': widget.sleepLog.lightSleepMinutes ?? 0,
        'quality': widget.sleepLog.quality,
        'stress_level': widget.sleepLog.stressLevel,
        'latency_minutes': widget.sleepLog.latencyMinutes ?? 0,
        'time_in_bed_minutes': widget.sleepLog.timeInBedMinutes ?? widget.sleepLog.durationMinutes,
        'caffeine_intake': widget.sleepLog.caffeineIntake,
        'exercise_minutes': widget.sleepLog.exerciseMinutes,
        'screen_time_before_bed': widget.sleepLog.screenTimeBeforeBed,
      };
      try {
        _fullAnalysisData['quality_breakdown'] =
        await ApiService.getEnhancedSleepQualityAnalysis(sleepQualityData)
            .timeout(const Duration(seconds: 25));
      } on TimeoutException {
        _fullAnalysisData['quality_breakdown'] = {"status": "timeout", "message": "Quality analysis timed out"};
      }
      _updateProgress(60);
      await Future.delayed(const Duration(seconds: 5));

      // Step 5: Dream/Mood Forecast
      _updateStep(4, "Generating dream forecast...");
      Map<String, dynamic> forecastData = {
        'duration_minutes': widget.sleepLog.durationMinutes.toDouble(),
        'quality': widget.sleepLog.quality.toDouble(),
        'stress_level': widget.sleepLog.stressLevel.toDouble(),
        'caffeine_intake': widget.sleepLog.caffeineIntake.toDouble(),
        'exercise_minutes': widget.sleepLog.exerciseMinutes.toDouble(),
        'screen_time_before_bed': widget.sleepLog.screenTimeBeforeBed.toDouble(),
      };
      try {
        _fullAnalysisData['dream_mood_forecast'] =
        await ApiService.getDreamPredictionAndMoodForecast(forecastData)
            .timeout(const Duration(seconds: 20));
      } on TimeoutException {
        _fullAnalysisData['dream_mood_forecast'] = {"status": "timeout", "message": "Forecast analysis timed out"};
      }
      _updateProgress(75);
      await Future.delayed(const Duration(seconds: 5));

      // Step 6: Sleep Insights
      _updateStep(5, "Generating sleep insights...");
      try {
        _fullAnalysisData['sleep_insights'] =
        await ApiService().getInsights(widget.sleepLog.toMap())
            .timeout(const Duration(seconds: 20));
        _fullAnalysisData['historical_analysis'] =
        await ApiService.getHistoricalSleepAnalysis(limit: 10)
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        // If either insights or historical analysis times out, provide fallback values.
        _fullAnalysisData['sleep_insights'] = {
          "status": "timeout",
          "message": "Insights timed out"
        };
        _fullAnalysisData['historical_analysis'] =
        "Historical analysis timed out";
      } on SleepAnalysisException catch (e) {
        // Handle cases where historical analysis fails due to missing logs or other
        // SleepAnalysisException errors. Provide a concise message instead of
        // throwing and interrupting the entire analysis pipeline.
        _fullAnalysisData['sleep_insights'] = {
          "status": "error",
          "message": e.message
        };
        _fullAnalysisData['historical_analysis'] = e.message;
      }
      _updateProgress(90);
      await Future.delayed(const Duration(seconds: 5));

      // Step 7: Main sleep analysis
      _updateStep(6, "Finalizing cosmic analysis...");
      Map<String, dynamic>? analysis;
      try {
        analysis = await ApiService.fetchSleepAnalysis([widget.sleepLog.toMap()])
            .timeout(const Duration(seconds: 30));
      } on TimeoutException {
        // Create a basic analysis structure if timeout occurs
        analysis = {
          'sleepStages': {},
          'dailyComparison': {},
          'lifestyleCorrelations': [],
          'status': 'timeout',
          'message': 'Main analysis timed out'
        };
      }

      if (analysis != null) {
        _fullAnalysisData.addAll(analysis);
        _fullAnalysisData['sleepStages'] = analysis['sleepStages'] ?? {};
        _fullAnalysisData['dailyComparison'] = analysis['dailyComparison'] ?? {};
        final lc = analysis['lifestyleCorrelations']
            ?? analysis['lifestyle_correlations']
            ?? analysis['behavioral_correlations']
            ?? analysis['correlations']
            ?? analysis['lifestyleInsights']
            ?? [];
        _fullAnalysisData['lifestyleCorrelations'] = lc is List ? lc : [];
      }

      // Mark as complete and bump progress to 100%. Updating via
      // `_updateProgress` ensures the derived sub‑progress is computed for
      // the final step, resulting in a full progress bar.
      _updateProgress(100);
      setState(() {
        _showCompletion = true;
        _currentStep = "Cosmic analysis complete!";
        _isProcessing = false;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => SleepAnalysisResultPage(
            analysisResult: _fullAnalysisData,
            sleepLog: widget.sleepLog,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('Error during analysis: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorSnackbar(e.toString());
      }
    }
  }

  void _updateStep(int stepIndex, String stepMessage) {
    if (!mounted) return;
    setState(() {
      _activeStepIndex = stepIndex;
      _currentStep = stepMessage;
      _currentStepProgress = 0.0;
    });
  }

  void _updateProgress(double progress) {
    // Updates the overall progress and derives sub-progress for the current step.
    //
    // The incoming `progress` value is expressed as a percentage (0–100).
    // We leave `_progress` in the same units so that any labels or calculations
    // depending on it remain consistent. However, rather than trying to derive
    // sub-step progress based off of fixed 15‑point increments, we instead
    // compute the fractional part of the overall progress relative to the
    // currently active step. This allows the on‑screen progress bar to fill
    // according to the dot indicators.
    if (!mounted) return;
    setState(() {
      _progress = progress;
      final normalized = progress / 100.0;
      final stepCount = _steps.length;
      final position = normalized * stepCount;
      // `_activeStepIndex` is set via `_updateStep` at the beginning of each
      // section. The difference between the overall position and the current
      // step index yields the in‑step progress. Clamp between 0 and 1 so
      // values outside the current step (e.g. when moving to the next step)
      // don’t produce negative or >1 values.
      _currentStepProgress = (position - _activeStepIndex).clamp(0.0, 1.0);
    });
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cosmic analysis failed: $error'),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AILoadingAnalysisPage(sleepLog: widget.sleepLog),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isProcessing) return true;

    final now = DateTime.now();
    final shouldExit = _lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (shouldExit) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to cancel cosmic analysis'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C0E27), Color(0xFF1C1E3A)],
            ),
          ),
          child: Stack(
            children: [
              // Background elements
              _buildQuantumField(),
              _buildParticleOverlay(),

              if (_showCompletion) _buildCosmicPortal(),

              // Main content
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _buildMainContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantumField() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _QuantumFieldPainter(
          particles: _quantumParticles,
          time: _mainController.value,
          activeColor: _activeColor,
        ),
      ),
    );
  }

  Widget _buildParticleOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CircularParticle(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          numberOfParticles: 20,
          isRandomColor: false,
          particleColor: _activeColor.withOpacity(0.15),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    // Build the left side content with tighter spacing. We remove the
    // placeholder `SizedBox` that originally created a large gap before the
    // panel, and shrink the vertical spacing between elements so that the
    // panel sits directly beneath the title.
    final leftColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedOrb(),
        const SizedBox(height: 20),
        _buildTitleText(),
        const SizedBox(height: 12),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: leftColumn),
          const SizedBox(width: 18),
          // Place the panel directly under the title without extra top padding.
          Align(
            alignment: Alignment.topLeft,
            child: MiniPCPanel(
              panelWidth: 420,
              externalProgress: null,
              panelHeight: math.min(size.width * 0.40, size.height * 0.40), // 👈 now applied
              stepSubProgress: _currentStepProgress,
              externalLabel: _currentStep,
              showLabel: true,
              showPercent: true,
              steps: _steps,
              activeStepIndex: _activeStepIndex,
              title: 'Sleep Analysis Engine',
              description: 'Live status renders inside the screen',
              cameraSweep: true,
            ),
          ),
        ],
      );
    } else {
      // On narrow screens, avoid wrapping the content in a scroll view to keep the
      // page non‑scrollable. We stack the panel directly after the left column
      // with minimal vertical spacing.
      // Calculate a height for the panel that scales with both the width and
      // the available vertical space to avoid bottom overflow on smaller
      // devices. We choose the smaller value between 60% of the screen
      // width and 40% of the screen height. This dual constraint ensures
      // that on very tall or very narrow screens the panel does not exceed
      // a sensible portion of the viewport.
      final double panelHeight = math.max(size.width * 0.55, size.height * 0.40);
      return Column(
        children: [
          leftColumn,
          MiniPCPanel(
            panelWidth: 400,
            panelHeight: panelHeight,
            externalProgress: null,
            stepSubProgress: _currentStepProgress,
            externalLabel: _currentStep,
            showLabel: true,
            showPercent: true,
            steps: _steps,
            activeStepIndex: _activeStepIndex,
            title: 'Sleep Analysis Engine',
            description: 'Live status renders inside the screen',
            cameraSweep: true,
          ),
        ],
      );
    }
  }

  // --- PC Panel host (no duplicate progress bars elsewhere) ---
  Widget _buildAnimatedOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildCosmicOrb(),
        RotationTransition(
          turns: _mainController.drive(Tween(begin: 1.0, end: 1.0)),
          child: Lottie.asset(
            'assets/animations/excited.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildCosmicOrb() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _activeColor.withOpacity(0.4),
              _activeColor.withOpacity(0.05),
            ],
            stops: const [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: _activeColor.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [_activeColor, _adjustColorLightness(_activeColor, 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showCompletion
            ? const Text(
          'COSMIC ANALYSIS COMPLETE',
          key: ValueKey('complete'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
            fontFamily: AppFonts.ComfortaaBold,
          ),
        )
            : const Text(
          'COSMIC SLEEP ANALYSIS',
          key: ValueKey('loading'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
            fontFamily: AppFonts.ComfortaaBold,
          ),
        ),
      ),
    );
  }

  /// Status text (this replaces the malformed `Widget{}` from the old file)
  Widget _buildStatusText() {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: Text(
          _currentStep,
          key: ValueKey(_currentStep),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: _showCompletion ? _activeColor : Colors.white.withOpacity(0.9),
            fontFamily: AppFonts.ComfortaaLight,
            height: 1.4,
            fontWeight: _showCompletion ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCosmicPortal() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              _activeColor.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.1, 1.0],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (_, value, __) => Transform.scale(
              scale: value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _activeColor.withOpacity(0.8),
                      _activeColor.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _activeColor.withOpacity(0.5),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.nightlight_round,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantumFieldPainter extends CustomPainter {
  final List<vm.Vector3> particles;
  final double time;
  final Color activeColor;

  _QuantumFieldPainter({
    required this.particles,
    required this.time,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hsl = HSLColor.fromColor(activeColor);

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final angle = time * 0.5 + i * 0.02;
      final r = 0.35 * math.min(size.width, size.height);
      final pos = Offset(
        center.dx + r * p.x * math.cos(angle),
        center.dy + r * p.y * math.sin(angle),
      );

      final t = (math.sin(time * 2 + i) + 1) / 2;
      final dotColor = hsl.withLightness((0.45 + 0.25 * t).clamp(0.0, 1.0)).toColor().withOpacity(0.35);
      final paint = Paint()..color = dotColor;
      canvas.drawCircle(pos, 1.2 + 1.6 * t, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuantumFieldPainter oldDelegate) {
    return oldDelegate.particles != particles ||
        oldDelegate.time != time ||
        oldDelegate.activeColor != activeColor;
  }
}