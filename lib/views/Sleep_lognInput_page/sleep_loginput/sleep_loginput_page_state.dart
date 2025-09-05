import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/sleep_efficiency_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../core/utils/screen_utils.dart';
import '../sleep_analysis/loading/ai_loading_analysis_page.dart';
import '../sleep_analysis/models/sleeplog_model_page.dart';

import '../sleep_log_service/sleep_log_service.dart';
import 'widgets/mood_stress_section.dart';
import 'widgets/quality_section.dart';
import 'widgets/input_section.dart';//
import 'widgets/sleep_time_section.dart';
import 'widgets/enviroment_section.dart';
import 'widgets/disturbance_section.dart';
import 'widgets/sleep_stages_section.dart';

// --- Edge-to-edge helper: makes a child take full width, removing horizontal padding from ancestors.
Widget _edgeToEdge(BuildContext context, Widget child, {EdgeInsetsGeometry? verticalPadding}) {
  return MediaQuery.removePadding(
    context: context,
    removeLeft: true,
    removeRight: true,
    child: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: verticalPadding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    ),
  );
}

class SleepLogInputPage extends StatelessWidget {
  const SleepLogInputPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepLog.reset(),
      child: const _CosmicWeaverPage(),
    );
  }
}

class _CosmicWeaverPage extends StatefulWidget {
  const _CosmicWeaverPage({Key? key}) : super(key: key);

  @override
  State<_CosmicWeaverPage> createState() => _CosmicWeaverPageState();
}

class _CosmicWeaverPageState extends State<_CosmicWeaverPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  final List<vm.Vector3> _quantumParticles = [];
  final Random _quantumRandom = Random();
  final _focusNodes = List.generate(8, (_) => FocusNode());
  int _activeIndex = 0;
  bool _isWeavingComplete = false;
  late PageController _pageController;
  double _scrollOffset = 0.0;

  // Scroll indicator controllers and states
  final List<ScrollController> _scrollControllers = [];
  final List<bool> _showScrollHint = [];
  final List<bool> _hasUserScrolled = [];

  final List<DreamThread> _dreamThreads = [
    DreamThread(
      title: 'Time Portal',
      hint: 'When did you enter the dream realm?',
      icon: Icons.hourglass_top,
      color: const Color(0xFF6A67CE),
      content: const SleepTimeSection(),
    ),
    DreamThread(
      title: 'Quality Nebula',
      hint: 'How vivid was your dreamscape?',
      icon: Icons.auto_awesome,
      color: const Color(0xFF4FC1E9),
      content: const QualitySection(),
    ),
    DreamThread(
      title: 'Emotion Galaxy',
      hint: 'What emotions colored your dreams?',
      icon: Icons.psychology,
      color: const Color(0xFFA0D568),
      content: const MoodStressSection(),
    ),
    DreamThread(
      title: 'Depth Singularity',
      hint: 'How deep did you journey?',
      icon: Icons.waves,
      color: const Color(0xFFFFCE54),
      content: const SleepStagesSection(),
    ),
    DreamThread(
      title: 'Continuity Fabric',
      hint: 'Did the dreamworld hold together?',
      icon: Icons.account_tree,
      color: const Color(0xFFED5565),
      content: const SleepEfficiencySection(),

    ),
    DreamThread(
      title: 'Habit Comets',
      hint: 'What rituals preceded your journey?',
      icon: Icons.nightlight_round,
      color: const Color(0xFFAC92EC),
      content: const InputSection(),
    ),
    DreamThread(
      title: 'Environment Matrix',
      hint: 'Describe your physical vessel',
      icon: Icons.rocket_launch,
      color: const Color(0xFF48CFAD),
      content: Column(
        children: const [
          EnvironmentSection(),
          SizedBox(height: 24),
          DisturbanceSection(),
        ],
      ),
    ),
    // New Dream Journal Section
    DreamThread(
      title: 'Dream Journal',
      hint: 'Record your dreams for deeper analysis',
      icon: Icons.drive_file_rename_outline,
      color: const Color(0xFFFF6B6B),
      content: const DreamJournalSection(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initQuantumField();

    _pageController = PageController(viewportFraction: 0.8);
    _pageController.addListener(() {
      setState(() {
        _scrollOffset = _pageController.page ?? 0;
      });
    });

    // Initialize scroll controllers and hint states
    for (int i = 0; i < _dreamThreads.length; i++) {
      _scrollControllers.add(ScrollController());
      _showScrollHint.add(false);
      _hasUserScrolled.add(false);
    }

    // Schedule a check for overflow after initial layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkContentOverflow();
    });
  }

  void _initQuantumField() {
    _quantumParticles.clear();
    for (int i = 0; i < 200; i++) { // Reduced for performance
      _quantumParticles.add(vm.Vector3(
        _quantumRandom.nextDouble() * 2 - 1,
        _quantumRandom.nextDouble() * 2 - 1,
        _quantumRandom.nextDouble() * 2 - 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    for (var node in _focusNodes) node.dispose();
    for (var controller in _scrollControllers) controller.dispose();
    super.dispose();
  }

  void _activateThread(int index) {
    if (_isWeavingComplete) return;

    setState(() => _activeIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
    );
    FocusScope.of(context).requestFocus(_focusNodes[index]);
    _initQuantumField();

    // Check if we need to show scroll hint for this thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkContentOverflow();
    });
  }

  void _checkContentOverflow() {
    for (int i = 0; i < _scrollControllers.length; i++) {
      final controller = _scrollControllers[i];
      if (controller.hasClients) {
        final hasOverflow = controller.position.maxScrollExtent > 0;
        if (hasOverflow && !_hasUserScrolled[i]) {
          setState(() => _showScrollHint[i] = true);

          // Auto-hide after 3 seconds if not scrolled
          Timer(const Duration(seconds: 3), () {
            if (mounted && _showScrollHint[i] && !_hasUserScrolled[i]) {
              setState(() => _showScrollHint[i] = false);
            }
          });
        }
      }
    }
  }

  Future<void> _completeWeaving(SleepLog model) async {
    // Ensure duration is calculated
    model.durationMinutes = model.calculateDurationMinutes();

    // Improved validation with detailed feedback
    final validationError = model.validateWithDetails();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing: $validationError'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isWeavingComplete = true);

    try {
      final result = await SleepLogService.saveSleepLog(model);
      if (!result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Save failed: ${result.error}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _isWeavingComplete = false);
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(seconds: 1),
            pageBuilder: (_, __, ___) => AILoadingAnalysisPage(sleepLog: model),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Save error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isWeavingComplete = false);
    }
  }

  void _weaveNextThread(SleepLog model) {
    if (_isWeavingComplete) return;

    if (_activeIndex < _dreamThreads.length - 1) {
      _activateThread(_activeIndex + 1);
    } else {
      _completeWeaving(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      builder: (_, child) {
        final model = Provider.of<SleepLog>(context);
        final thread = _dreamThreads[_activeIndex];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildCosmicAppBar(),
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
                // Quantum Field Background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _QuantumFieldPainter(
                      particles: _quantumParticles,
                      time: _controller.value,
                      activeColor: thread.color,
                    ),
                  ),
                ),

                // Main Content Area
                Positioned(
                  top: 100.h,
                  left: 0,
                  right: 0,
                  bottom: 80.h,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _dreamThreads.length,
                    onPageChanged: (index) => _activateThread(index),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _build8DSection(
                        context,
                        _dreamThreads[index],
                        index: index,
                      );
                    },
                  ),
                ),

                // Navigation Indicators
                Positioned(
                  top: 80.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_dreamThreads.length, (index) {
                      return GestureDetector(
                        onTap: () => _activateThread(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: index == _activeIndex ? 20.w : 8.w,
                          height: 8.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: index == _activeIndex
                                ? _dreamThreads[index].color
                                : _dreamThreads[index].color.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Next/Analyze Button
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _isWeavingComplete
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        thread.color,
                      ),
                      strokeWidth: 3.w,
                    )
                        : _PulseButton(
                      controller: _pulseController,
                      color: thread.color,
                      isLast: _activeIndex == _dreamThreads.length - 1,
                      onPressed: () => _weaveNextThread(model),
                    ),
                  ),
                ),

                // Completion Portal Effect
                if (_isWeavingComplete) _buildCompletionPortal(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _build8DSection(BuildContext context, DreamThread item, {
    required int index,
  }) {
    final isActive = index == _activeIndex;
    final offset = _scrollOffset - index;
    final absOffset = offset.abs();

    // Calculate depth effect
    double depth = 1.0;
    double rotationY = 0.0;
    double scale = 1.0;
    double opacity = 1.0;
    double translateX = 0.0;

    if (!isActive) {
      depth = 0.8 - absOffset * 0.3;
      rotationY = offset > 0 ? -0.5 : 0.5;
      scale = 0.8;
      opacity = 0.7 - absOffset * 0.3;
      translateX = offset * 50.w;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..translate(translateX, 0.0, -100 * (1 - depth))
          ..scale(scale)
          ..rotateY(rotationY),
        alignment: Alignment.center,
        child: Opacity(
          opacity: opacity,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: item.color.withOpacity(0.8 - (1 - depth) * 0.5),
                width: 2.0 + (1 - depth) * 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.3 - (1 - depth) * 0.2),
                  blurRadius: 20 + (1 - depth) * 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  // Holographic effect for side widgets
                  if (!isActive) Positioned.fill(
                    child: CustomPaint(
                      painter: _HolographicEffectPainter(
                        color: item.color,
                        depth: depth,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(item.icon, color: item.color, size: 24.w),
                            SizedBox(width: 10.w),
                            Text(
                              item.title,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification &&
                                  index == _activeIndex) {
                                if (notification.metrics.pixels > 0 &&
                                    !_hasUserScrolled[index]) {
                                  setState(() {
                                    _hasUserScrolled[index] = true;
                                    _showScrollHint[index] = false;
                                  });
                                }
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _scrollControllers[index],
                              physics: const BouncingScrollPhysics(),
                              child: _edgeToEdge(context, item.content),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scroll indicator
                  if (isActive && _showScrollHint[index])
                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: _ScrollIndicator(color: item.color),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCosmicAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new,
            color: Colors.white70, size: 24.w),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'AI SLEEP ANALYSIS',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w300,
          letterSpacing: 4.w,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline,
              color: Colors.white70, size: 24.w),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCompletionPortal() {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
        builder: (_, value, __) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1 * value),
                  Colors.transparent,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: value,
                child: Container(
                  width: 300.w,
                  height: 300.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.8),
                        Colors.purple.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 100.w,
                        spreadRadius: 50.w,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.nightlight_round,
                    color: Colors.white,
                    size: 80.w,
                  ),
                ),
              ),
            ),
          );
        },
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
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final angle = time * 0.5 + i * 0.01;
      final dist = 0.3 + 0.7 * p.z.abs();
      final pos = Offset(
        center.dx + p.x * size.width * 0.4 * cos(angle),
        center.dy + p.y * size.height * 0.4 * sin(angle),
      );
      final sizeF = 0.5 + 0.5 * sin(time * 2 + i);
      final radius = 1.5 + 3 * sizeF * (1 - dist);
      final color = hsl.withLightness(0.2 + 0.8 * (1 - dist)).toColor();

      paint.color = color.withOpacity(0.7);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuantumFieldPainter old) => true;
}

class _HolographicEffectPainter extends CustomPainter {
  final Color color;
  final double depth;

  _HolographicEffectPainter({required this.color, required this.depth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) * 0.8;
    final intensity = depth * 0.5;

    // Draw holographic rings
    for (int i = 0; i < 3; i++) {
      final radius = maxRadius * (1 - i * 0.3) * depth;
      final opacity = 0.3 - i * 0.1;
      final paint = Paint()
        ..color = color.withOpacity(opacity * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (1 - depth) * 3;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw scan lines
    final linePaint = Paint()
      ..color = color.withOpacity(0.1 * intensity)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HolographicEffectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.depth != depth;
  }
}

class DreamThread {
  final String title;
  final String hint;
  final IconData icon;
  final Color color;
  final Widget content;

  const DreamThread({
    required this.title,
    required this.hint,
    required this.icon,
    required this.color,
    required this.content,
  });
}

class _PulseButton extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final bool isLast;
  final VoidCallback onPressed;

  const _PulseButton({
    required this.controller,
    required this.color,
    required this.isLast,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 1.0 + (controller.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              elevation: 8,
              shadowColor: color.withOpacity(0.5),
            ),
            icon: Icon(
              isLast ? Icons.nightlight_round : Icons.arrow_forward,
              size: 24.w,
            ),
            label: Text(
              isLast ? 'ANALYZE DREAM PATTERNS' : 'WEAVE NEXT THREAD',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScrollIndicator extends StatefulWidget {
  final Color color;

  const _ScrollIndicator({required this.color});

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Lottie.asset(
        'assets/animations/scroll.json',
        width: ScreenUtils.width(100),
        height: ScreenUtils.height(100),
        fit: BoxFit.contain,
      ),
    );
  }
}

// New Dream Journal Widget
class DreamJournalSection extends StatefulWidget {
  const DreamJournalSection({super.key});

  @override
  State<DreamJournalSection> createState() => _DreamJournalSectionState();
}

class _DreamJournalSectionState extends State<DreamJournalSection> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SleepLog>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record your dream details:',
          style: TextStyle(fontSize: 16.sp, color: Colors.white70),
        ),
        SizedBox(height: 16.h),
        TextField(
          onChanged: (value) => model.setDreamJournal(value),
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Describe people, emotions, symbols, and events...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Key dream elements:',
          style: TextStyle(fontSize: 16.sp, color: Colors.white70),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildDreamElementChip('Flying', model),
            _buildDreamElementChip('Falling', model),
            _buildDreamElementChip('Water', model),
            _buildDreamElementChip('Animals', model),
            _buildDreamElementChip('Chase', model),
            _buildDreamElementChip('Teeth', model),
            _buildDreamElementChip('Naked', model),
            _buildDreamElementChip('Death', model),
          ],
        ),
      ],
    );
  }

  Widget _buildDreamElementChip(String element, SleepLog model) {
    return FilterChip(
      label: Text(element),
      selected: model.dreamElements.contains(element),
      onSelected: (selected) {
        if (selected) {
          model.addDreamElement(element);
        } else {
          model.removeDreamElement(element);
        }
      },
      selectedColor: Colors.purple.withOpacity(0.3),
      checkmarkColor: Colors.white,
    );
  }
}