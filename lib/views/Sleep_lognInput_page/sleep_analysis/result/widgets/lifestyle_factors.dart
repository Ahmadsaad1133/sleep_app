import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../../constants/colors.dart';
import '../../models/sleeplog_model_page.dart';

// -----------------------------------------------------------------------------
// Global UI constants for lifestyle factors
//
// These constants mirror those defined in other UI files and help to
// standardise the palette and gradients across the app.  Duplicating them
// locally avoids the need for a central theme file and keeps this widget
// self‑contained.
const Color kBackgroundStart = Color(0xFF071B2C);
const Color kBackgroundEnd   = Color(0xFF101E3C);
const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [kBackgroundStart, kBackgroundEnd],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const LinearGradient kCardGradient = LinearGradient(
  colors: [Color(0xFF0E1B40), Color(0xFF172452)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient kAccentGradient = LinearGradient(
  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// lifestyle_factors_ii_2050.dart
// -----------------------------
// "II 2050" — upgraded futuristic redesign of LifestyleFactors.
// Key improvements vs previous version:
//  - Better performance (fewer rebuilds, RepaintBoundary, const where possible).
//  - Respect user "reduced motion" setting (accessibleNavigation).
//  - More pronounced "power core" (central animated node) with micro-particles.
//  - Cleaner separation between visuals and static card content.
//  - Extra semantic labels for assistive tech and keyboard focus.
//  - Slight polish (soft shadows, glass layers, subtle gradients, and adaptive layout).

class LifestyleFactors extends StatefulWidget {
  final SleepLog? lastSleepLog;

  const LifestyleFactors({super.key, required this.lastSleepLog});

  @override
  State<LifestyleFactors> createState() => _LifestyleFactorsState();
}

class _LifestyleFactorsState extends State<LifestyleFactors> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceOpacity;
  late final Animation<double> _entranceScale;

  late final AnimationController _orbitController; // repeating
  late final Animation<double> _orbitAnimation; // 0..1 repeating

  late final AnimationController _pulseController; // neon pulse
  late final Animation<double> _pulseAnimation;

  // pointer for tactile tilt
  Offset _pointer = Offset.zero;
  bool _hovering = false;

  final Random _random = Random(987654321);
  final List<_LifestyleFactor> _lifestyleFactors = [];

  bool get _hasData => widget.lastSleepLog != null;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _entranceOpacity = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _orbitController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _orbitAnimation = _orbitController.drive(Tween(begin: 0.0, end: 1.0));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Start when ready; however if the user prefers reduced motion we'll avoid heavy repeats.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mq = MediaQuery.maybeOf(context);
      final reduce = mq?.accessibleNavigation ?? false;
      _entranceController.forward().whenComplete(() {
        if (!reduce) {
          _orbitController.repeat();
          _pulseController.repeat(reverse: true);
        } else {
          _orbitController.animateTo(0.5);
          _pulseController.animateTo(0.5);
        }
      });
    });

    if (_hasData) _prepareFromLog(widget.lastSleepLog!);
  }

  void _prepareFromLog(SleepLog log) {
    // Build deterministic but slightly varied seeds for nicer visuals
    final base = _random.nextInt(9999);
    _lifestyleFactors.addAll([
      _LifestyleFactor(
        title: 'Caffeine',
        value: '${log.caffeineIntake} mg',
        icon: Icons.local_cafe,
        gradient: const LinearGradient(colors: [Color(0xFFFF7EB3), Color(0xFFFF758C)]),
        orbitSpeed: 1.0 + _random.nextDouble() * 2.0,
        seed: base + 11,
      ),
      _LifestyleFactor(
        title: 'Exercise',
        value: '${log.exerciseMinutes} mins',
        icon: Icons.directions_run,
        gradient: const LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
        orbitSpeed: 1.5 + _random.nextDouble() * 2.0,
        seed: base + 23,
      ),
      _LifestyleFactor(
        title: 'Screen Time',
        value: '${log.screenTimeBeforeBed} mins',
        icon: Icons.smartphone,
        gradient: const LinearGradient(colors: [Color(0xFFFFA62E), Color(0xFFFFD166)]),
        orbitSpeed: 2.0 + _random.nextDouble() * 1.5,
        seed: base + 37,
      ),
      _LifestyleFactor(
        title: 'Diet Notes',
        value: log.dietNotes.isNotEmpty ? log.dietNotes : 'No notes',
        icon: Icons.note_alt,
        gradient: const LinearGradient(colors: [Color(0xFF7F00FF), Color(0xFFE100FF)]),
        orbitSpeed: 1.8 + _random.nextDouble() * 1.7,
        seed: base + 43,
      ),
      _LifestyleFactor(
        title: 'Medications',
        value: log.medications.isNotEmpty ? log.medications : 'None',
        icon: Icons.medication,
        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        orbitSpeed: 1.2 + _random.nextDouble() * 2.3,
        seed: base + 61,
      ),
      _LifestyleFactor(
        title: 'Disturbances',
        value: log.disturbances.isNotEmpty ? log.disturbances.join(', ') : 'None',
        icon: Icons.nightlight_round,
        gradient: const LinearGradient(colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)]),
        orbitSpeed: 2.5 + _random.nextDouble() * 1.0,
        seed: base + 79,
      ),
    ]);
  }

  @override
  void didUpdateWidget(covariant LifestyleFactors oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastSleepLog != oldWidget.lastSleepLog && widget.lastSleepLog != null) {
      _lifestyleFactors.clear();
      _prepareFromLog(widget.lastSleepLog!);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // pointer helpers used for subtle tilt
  void _updatePointer(Offset localPos, Size size) {
    final center = size.center(Offset.zero);
    final normalized = (localPos - center) / (size.shortestSide / 2);
    setState(() => _pointer = Offset(normalized.dx.clamp(-1.0, 1.0), normalized.dy.clamp(-1.0, 1.0)));
  }

  void _resetPointer() {
    setState(() {
      _pointer = Offset.zero;
      _hovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) return const SizedBox();

    final mq = MediaQuery.of(context);
    final reduceMotion = mq.accessibleNavigation;

    return FadeTransition(
      opacity: _entranceOpacity,
      child: ScaleTransition(
        scale: _entranceScale,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;

          return MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => _resetPointer(),
            child: GestureDetector(
              onPanUpdate: (d) {
                final size = Size(width, 340.h);
                _updatePointer(d.localPosition, size);
              },
              onPanEnd: (_) => _resetPointer(),
              child: Semantics(
                container: true,
                label: 'Lifestyle Factors 2050 panel',
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 18.h),
                  decoration: BoxDecoration(
                    gradient: kCardGradient,
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16.r,
                        offset: Offset(0, 8.h),
                      ),
                      BoxShadow(
                        color: Color(0xFF2575FC).withOpacity(0.07),
                        blurRadius: 24.r,
                        spreadRadius: 4.r,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Shimmer(
                              duration: const Duration(seconds: 3),
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.cyan.shade300]),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(0.12),
                                      blurRadius: 12.r,
                                      spreadRadius: 1.r,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  Icons.auto_awesome_mosaic,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'L I F E S T R E A M  ·  I I  ·  2 0 5 0',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withOpacity(0.95),
                                  fontFamily: 'NunitoSansBold',
                                  letterSpacing: 2.5.w,
                                  fontSize: 16.sp,
                                  shadows: [Shadow(blurRadius: 10.r, color: Colors.cyan.withOpacity(0.18))],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _buildPowerCore(pulse: _pulseAnimation, reduceMotion: reduceMotion),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // grid of enhanced orbiters
                        GridView.builder(
                          itemCount: _lifestyleFactors.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (width > 720) ? 3 : 2,
                            crossAxisSpacing: 14.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.22,
                          ),
                          itemBuilder: (context, index) {
                            final factor = _lifestyleFactors[index];
                            return RepaintBoundary(
                              child: _CosmicFactorOrbiterII2050(
                                factor: factor,
                                orbitAnimation: _orbitAnimation,
                                pulse: _pulseAnimation,
                                pointer: _pointer,
                                hovering: _hovering,
                                reduceMotion: reduceMotion,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPowerCore({required Animation<double> pulse, required bool reduceMotion}) {
    // Small animated core that can sit in the header. Keeps animations simple and accessible.
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      child: Semantics(
        label: 'System power core status',
        child: AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final p = reduceMotion ? 0.5 : pulse.value;
            final size = 34.0 + (p * 8.0);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.white.withOpacity(0.25 + p * 0.25), Colors.transparent]),
                boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.12 + p * 0.06), blurRadius: 10 + p * 6)],
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Container(
                  width: 10 + p * 6,
                  height: 10 + p * 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.cyanAccent.withOpacity(0.9), Colors.blueAccent.withOpacity(0.9)]),
                    boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.18), blurRadius: 8)],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Orbiter widget: separates visuals from static content. Uses pointer and hovering for tilt.
class _CosmicFactorOrbiterII2050 extends StatelessWidget {
  final _LifestyleFactor factor;
  final Animation<double> orbitAnimation;
  final Animation<double> pulse;
  final Offset pointer;
  final bool hovering;
  final bool reduceMotion;

  const _CosmicFactorOrbiterII2050({
    Key? key,
    required this.factor,
    required this.orbitAnimation,
    required this.pulse,
    required this.pointer,
    required this.hovering,
    required this.reduceMotion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OrbiterBackgroundPainterII2050(
                  orbitAnimation: orbitAnimation,
                  pulse: pulse,
                  gradient: factor.gradient,
                  seed: factor.seed,
                  orbitSpeed: factor.orbitSpeed,
                ),
              ),
            ),

            // static card, but with a tiny tilt transform for depth
            AnimatedBuilder(
              animation: orbitAnimation,
              builder: (context, child) {
                // compute subtle tilt from pointer
                final tiltX = pointer.dy * -5.0; // degrees
                final tiltY = pointer.dx * 5.0; // degrees
                final depth = hovering ? 1.02 : 1.0;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(tiltX * pi / 180)
                  ..rotateY(tiltY * pi / 180)
                  ..scale(depth);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: _CosmicStaticCardII2050(factor: factor),
            ),
          ],
        ),
      ),
    );
  }
}

class _CosmicStaticCardII2050 extends StatelessWidget {
  final _LifestyleFactor factor;
  const _CosmicStaticCardII2050({Key? key, required this.factor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: factor.gradient.colors.first.withOpacity(0.18),
            blurRadius: 18.r,
            spreadRadius: 1.r,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.4, sigmaY: 2.4),
          child: Container(
            color: Colors.black.withOpacity(0.34),
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]),
                      ),
                      child: Icon(
                        factor.icon,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        factor.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'NunitoSansBold',
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: factor.gradient,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: factor.gradient.colors.last.withOpacity(0.15),
                            blurRadius: 8.r,
                            spreadRadius: 1.r,
                          )
                        ],
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  factor.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'NunitoSans',
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Improved painter with micro-particles, halo and scanlines. Keeps repaint list small.
class _OrbiterBackgroundPainterII2050 extends CustomPainter {
  final Animation<double> orbitAnimation; // 0..1
  final Animation<double> pulse; // 0..1
  final Gradient gradient;
  final int seed;
  final double orbitSpeed;

  late final List<Offset> _stars;
  late final List<double> _phases;

  _OrbiterBackgroundPainterII2050({
    required this.orbitAnimation,
    required this.pulse,
    required this.gradient,
    required this.seed,
    required this.orbitSpeed,
  }) : super(repaint: Listenable.merge([orbitAnimation, pulse])) {
    final rnd = Random(seed * 1597 + 13);
    _stars = List.generate(12, (i) => Offset(rnd.nextDouble(), rnd.nextDouble()));
    _phases = List.generate(_stars.length, (i) => rnd.nextDouble() * 2 * pi);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = orbitAnimation.value;
    final p = pulse.value;

    // shift for holographic radial
    final shiftX = sin(t * 2 * pi * orbitSpeed) * 0.10;
    final shiftY = cos(t * 2 * pi * orbitSpeed) * 0.06;

    final rect = Offset.zero & size;
    final shader = RadialGradient(
      center: Alignment(shiftX, shiftY),
      radius: 0.95,
      colors: [
        (gradient as LinearGradient).colors.first.withOpacity(0.20 * (0.5 + p * 0.8)),
        (gradient as LinearGradient).colors.last.withOpacity(0.04 * (0.5 + p * 0.8)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    final bgPaint = Paint()..shader = shader;
    canvas.drawRect(rect, bgPaint);

    // central ring
    final center = size.center(Offset.zero);
    final minSide = min(size.width, size.height);
    final ringRadius = minSide * 0.34;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 + p * 3.2
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        colors: [
          (gradient as LinearGradient).colors.first.withOpacity(0.95),
          (gradient as LinearGradient).colors.last.withOpacity(0.95),
          (gradient as LinearGradient).colors.first.withOpacity(0.95),
        ],
        stops: [0.0, 0.5, 1.0],
        transform: GradientRotation(t * 2 * pi * (0.5 + orbitSpeed * 0.08)),
      ).createShader(Rect.fromCircle(center: center, radius: ringRadius));

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.06 + p * 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, ringRadius + (6 * p), glowPaint);
    canvas.drawCircle(center, ringRadius, ringPaint);

    // orbital particles
    for (var i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final phase = _phases[i];
      final angle = t * 2 * pi * orbitSpeed * (1.0 + i * 0.02) + phase;
      final orbitR = ringRadius * (0.48 + (i % 4) * 0.07);
      final cx = center.dx + cos(angle) * orbitR + (s.dx - 0.5) * 8.0;
      final cy = center.dy + sin(angle) * orbitR + (s.dy - 0.5) * 6.0;
      final sizeFactor = (1.0 + sin(t * 2 * pi * (0.5 + i * 0.07) + phase) * 0.4);

      final starPaint = Paint()..color = Colors.white.withOpacity(0.40 - i * 0.02 + p * 0.10);
      canvas.drawCircle(Offset(cx, cy), 2.4 * (sizeFactor * 0.9), starPaint);

      final trail = Paint()
        ..color = (gradient as LinearGradient).colors.last.withOpacity(0.06 + p * 0.07)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(Offset(cx + cos(angle) * 6.0, cy + sin(angle) * 6.0), 3.8 * p, trail);
    }

    // micro-scanlines overlay
    final scanPaint = Paint()..color = Colors.white.withOpacity(0.008 + p * 0.01);
    final step = 6.0;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y + (p * 1.2)), Offset(size.width, y + (p * 1.2)), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbiterBackgroundPainterII2050 oldDelegate) {
    return oldDelegate.orbitAnimation != orbitAnimation || oldDelegate.pulse != pulse || oldDelegate.seed != seed || oldDelegate.orbitSpeed != orbitSpeed;
  }
}

class _LifestyleFactor {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final double orbitSpeed;
  final int seed;

  _LifestyleFactor({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.orbitSpeed,
    required this.seed,
  });
}
