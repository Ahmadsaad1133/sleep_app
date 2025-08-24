// creative_app_bar.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreativeAppBar extends StatefulWidget {
  final int sleepScore;
  final bool isAnalysisParsed;
  final TabController tabController;
  final double shrinkPercent;

  const CreativeAppBar({
    super.key,
    required this.sleepScore,
    required this.isAnalysisParsed,
    required this.tabController,
    this.shrinkPercent = 1.0,
  });

  @override
  State<CreativeAppBar> createState() => _CreativeAppBarState();
}

class _CreativeAppBarState extends State<CreativeAppBar>
    with TickerProviderStateMixin {
  late AnimationController _moonController;
  late AnimationController _cometController;
  late AnimationController _titleGlowController;
  late Animation<double> _moonAnimation;
  late Animation<double> _titleGlowAnimation;
  final List<Map<String, dynamic>> _constellationPoints = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // do not generate constellation here because we rely on screen dimensions
    // which may be available only after ScreenUtil is initialized. We'll
    // lazily generate in build() if needed.
  }

  void _initAnimations() {
    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _moonAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _moonController, curve: Curves.easeInOut));

    _cometController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _titleGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _titleGlowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleGlowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _generateConstellation(double width, double height) {
    _constellationPoints.clear();
    // use screen dimensions scaled with ScreenUtil (width/height provided by caller)
    final double usableWidth = width;
    final double topOffset = 20.h;
    final double usableHeight = (height * 0.35).clamp(120.h, 300.h);

    for (int i = 0; i < 20; i++) {
      _constellationPoints.add({
        'position': Offset(
          _random.nextDouble() * usableWidth,
          topOffset + _random.nextDouble() * usableHeight,
        ),
        'size': (1.5 + _random.nextDouble() * 3).r,
        'twinkleDelay': _random.nextDouble() * 2,
      });
    }
  }

  @override
  void dispose() {
    _moonController.dispose();
    _cometController.dispose();
    _titleGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: This widget assumes that ScreenUtil.init(...) was already
    // called higher in the widget tree (e.g. in the app's main).
    final double sp = widget.shrinkPercent.clamp(0.0, 1.0);

    // sizes using ScreenUtil helpers
    final double titleFont = (20 + 12 * sp).sp;
    final double subtitleFont = (12 + 4 * sp).sp;
    final double moonSize = (34 + 36 * sp).r;
    final double topPadding = (20 + 40 * sp).h;

    // Fully opaque when collapsed, gradual when expanded
    final double bigBoxOpacity = sp <= 0.15 ? 1.0 : (0.30 + 0.70 * sp);

    const double tabContainerHeight = 48.0;
    final double collapsedTabTopPad = 20.0.h;

    final screenWidth = MediaQuery.of(context).size.width.w;
    final screenHeight = MediaQuery.of(context).size.height.h;

    // generate constellation lazily if empty (now we have screen size)
    if (_constellationPoints.isEmpty) {
      _generateConstellation(screenWidth, screenHeight);
    }

    return AnimatedBuilder(
      animation: Listenable.merge(
        [_moonController, _cometController, _titleGlowController],
      ),
      builder: (context, child) {
        final moonPos = Curves.easeInOut.transform(_moonAnimation.value);
        final double tabTopPad = (1.0 - sp) * collapsedTabTopPad;

        final double dustOpacity = 0.05 + 0.12 * sp;
        final double starOpacity = 0.4 + 0.5 * sp;
        final double cometOpacity = max(0.5, 0.40 + 0.55 * sp);
        final double moonOpacity = 0.45 + 0.45 * sp;

        // Comet animation value t, cycles from 0 to 1
        final t = _cometController.value;
        final double cometMinSize = 36.0.r;
        final double cometMaxSize = 120.0.r;
        final double sunCollapsedSize = 68.0.r;

        final double sunThreshold = 0.15;
        final bool showSun = sp <= sunThreshold;

        final double cometSize = showSun
            ? sunCollapsedSize
            : cometMinSize + (cometMaxSize - cometMinSize) * sp;

        // FIXED COMET POSITIONING
        final double verticalPosition = 0.20 + 0.10 * (1 - sp);
        final double top =
            (screenHeight * verticalPosition) + 10.r * sin(2 * pi * t);

        final double left = -cometSize + (screenWidth + cometSize) * t;

        final glowIntensity = _titleGlowAnimation.value;

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.sleepScore > 85
                      ? const Color(0xFF1A237E).withOpacity(0.9 * bigBoxOpacity)
                      : const Color(0xFF0D1B2A).withOpacity(bigBoxOpacity),
                  widget.sleepScore > 85
                      ? const Color(0xFF4A148C).withOpacity(0.9 * bigBoxOpacity)
                      : const Color(0xFF1B263B).withOpacity(bigBoxOpacity),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade900.withOpacity(0.6 * bigBoxOpacity),
                  blurRadius: 30.r,
                  spreadRadius: 10.r,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // cosmic dust background (faded)
                Positioned.fill(
                  child: Opacity(
                    opacity: dustOpacity,
                    child: Image.asset(
                      'assets/cosmic_dust.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // stars
                ..._constellationPoints.map((star) {
                  final twinkle = (0.5 +
                      0.5 *
                          sin(DateTime.now().millisecondsSinceEpoch / 500 +
                              (star['twinkleDelay'] ?? 0.0)));
                  final double size = (star['size'] as double) * (0.8 + 0.2 * sp);
                  final Offset pos = star['position'] as Offset;
                  return Positioned(
                    left: pos.dx,
                    top: pos.dy,
                    child: Opacity(
                      opacity: starOpacity,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity((0.6 * twinkle)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100
                                  .withOpacity(0.25 * twinkle),
                              blurRadius: 5.r,
                              spreadRadius: 2.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // constellation connections
                Opacity(
                  opacity: 0.25 + 0.45 * sp,
                  child: CustomPaint(
                    painter:
                    _ConstellationConnectionsPainter(_constellationPoints),
                    size: Size(screenWidth, double.infinity),
                  ),
                ),

                // comet / sun / cube
                Positioned(
                  left: left,
                  top: top,
                  child: Opacity(
                    opacity: cometOpacity,
                    child: Transform.rotate(
                      angle: showSun ? 0.0 : (2 * pi * t),
                      child: showSun ? _buildSun(cometSize) : _buildCube(cometSize),
                    ),
                  ),
                ),

                // moon
                Positioned(
                  left: screenWidth * moonPos,
                  top: (12.h + 28.h * (1 - sp)) +
                      24.r * sin(moonPos * pi),
                  child: Opacity(
                    opacity: moonOpacity,
                    child: Container(
                      width: moonSize,
                      height: moonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.white, Color(0xFFFFE6B0)],
                          stops: [0.7, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber
                                .withOpacity(0.35 + 0.25 * sp),
                            blurRadius: 20.r * (0.6 + 0.4 * sp),
                            spreadRadius: 10.r * (0.6 + 0.4 * sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // main content (title, subtitle)
                Padding(
                  padding: EdgeInsets.only(
                      top: topPadding, left: 16.w, right: 16.w, bottom: 12.h),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 56.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: 0.85 + 0.15 * sp,
                              alignment: Alignment.topLeft,
                              child: AnimatedBuilder(
                                animation: _titleGlowController,
                                builder: (context, child) {
                                  return Text(
                                    'Dream Analysis',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSansBold',
                                      fontSize: titleFont,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 14.r * glowIntensity,
                                          color: Colors.blue.shade300
                                              .withOpacity(glowIntensity *
                                              (0.6 + 0.4 * sp)),
                                        ),
                                        Shadow(
                                          blurRadius: 18.r * glowIntensity,
                                          color: Colors.deepPurple
                                              .withOpacity(glowIntensity *
                                              (0.35 + 0.65 * sp)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Transform.scale(
                              scale: 0.9 + 0.1 * sp,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Your Personal Sleep Journey • ${DateFormat('MMMM d').format(DateTime.now())}',
                                style: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: subtitleFont,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // tabs (shown when analysis parsed)
                if (widget.isAnalysisParsed) ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: tabContainerHeight.h + tabTopPad,
                      padding: EdgeInsets.only(top: tabTopPad),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: Colors.black.withOpacity(0.18 * (0.6 + 0.4 * sp)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: TabBar(
                          controller: widget.tabController,
                          isScrollable: true,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding:
                          EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade600.withOpacity(0.5),
                                blurRadius: 8.r,
                                spreadRadius: 1.r,
                              ),
                            ],
                          ),
                          tabs: [
                            _buildCreativeTab(Icons.nights_stay, 'Overview'),
                            _buildCreativeTab(Icons.bed, 'Details'),
                            _buildCreativeTab(Icons.analytics, 'Metrics'), // NEW TAB
                            _buildCreativeTab(Icons.auto_awesome, 'Insights'),
                            _buildCreativeTab(Icons.article, 'Report'),
                            _buildCreativeTab(Icons.nightlight_round, 'Dreams'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSun(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.6,
            height: size * 1.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orange.withOpacity(0.18),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          ...List.generate(8, (i) {
            final angle = (pi / 4) * i;
            return Transform.rotate(
              angle: angle,
              child: Container(
                width: size * 1.2,
                height: size * 0.12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.orange.withOpacity(0.95),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(size * 0.06),
                ),
              ),
            );
          }),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.yellow.shade300, Colors.orange.shade700],
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.45),
                  blurRadius: 18.r,
                  spreadRadius: 8.r,
                ),
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.25),
                  blurRadius: 6.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCube(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade900],
        ),
        borderRadius: BorderRadius.circular(max(6.r, size * 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade800.withOpacity(0.35),
            blurRadius: 8.r,
            spreadRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeTab(IconData icon, String text) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer(
              duration: const Duration(seconds: 3),
              child: Icon(icon, size: 18.sp),
            ),
            SizedBox(width: 8.w),
            Text(text, style: TextStyle(fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }
}

class _ConstellationConnectionsPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;

  _ConstellationConnectionsPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final p1 = points[i]['position'] as Offset;
        final p2 = points[j]['position'] as Offset;
        final distance = (p1 - p2).distance;

        if (distance < 100) {
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}