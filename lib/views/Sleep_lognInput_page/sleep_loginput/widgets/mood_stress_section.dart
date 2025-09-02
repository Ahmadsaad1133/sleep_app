// lib/widgets/mood_stress_section.dart
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/section_title.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/step_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../../../../core/utils/screen_utils.dart';
import '../../../../services/haptic_service.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';
import 'package:lottie/lottie.dart';

class MoodStressSection extends StatelessWidget {
  const MoodStressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StepWrapper(
      title: 'Mood & Stress',
      child: Container(
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [Color(0x301A237E), Color(0x000A0E21)],
            ),
            borderRadius: BorderRadius.circular(ScreenUtils.scale(30)),
            border: Border.all(
              color: Colors.blueAccent,
              width: ScreenUtils.scale(1.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth > 600
                  ? const _WideLayout()
                  : const _NarrowLayout();
            },
          ),
        ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: MoodCarousel3D()),
        VerticalDivider(
          color: Colors.blueGrey,
          thickness: 1,
          width: 1,
          indent: 20,
          endIndent: 20,
        ),
        Expanded(child: StressSelector()),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: MoodCarousel3D(),
        ),
        Divider(
          color: Colors.blueGrey,
          thickness: 1,
          indent: 30,
          endIndent: 30,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: StressSelector(),
        ),
      ],
    );
  }
}

class MoodCarousel3D extends StatefulWidget {
  const MoodCarousel3D({super.key});

  @override
  _MoodCarousel3DState createState() => _MoodCarousel3DState();
}

class _MoodCarousel3DState extends State<MoodCarousel3D> {
  final List<Map<String, dynamic>> moods = const [
    {
      'emoji': '😴',
      'label': 'Exhausted',
      'color': Colors.blueGrey,
      'animation': 'assets/animations/Sleeping.json',
    },
    {
      'emoji': '😔',
      'label': 'Down',
      'color': Colors.indigo,
      'animation': 'assets/animations/morty.json',
    },
    {
      'emoji': '🙂',
      'label': 'Neutral',
      'color': Colors.teal,
      'animation': 'assets/animations/normal.json',
    },
    {
      'emoji': '😊',
      'label': 'Happy',
      'color': Colors.lightGreen,
      'animation': 'assets/animations/happy.json',
    },
    {
      'emoji': '😃',
      'label': 'Excited',
      'color': Colors.amber,
      'animation': 'assets/animations/excited.json',
    },
  ];

  final PageController _pageController = PageController(
    viewportFraction: 0.3,
    initialPage: 2,
  );

  double _currentPage = 2.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page!);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepLog>(
      builder: (context, model, _) {
        final activeMoodIndex = _currentPage.round();
        return Column(
          children: [
            _buildMainEmoji(activeMoodIndex),
            SizedBox(height: ScreenUtils.height(10)),
            _buildCarousel(model),
            SizedBox(height: ScreenUtils.height(15)),
            _buildIndicator(activeMoodIndex),
            SizedBox(height: ScreenUtils.height(10)),
            _buildMoodLabel(activeMoodIndex),
          ],
        );
      },
    );
  }

  Widget _buildMainEmoji(int activeIndex) {
    final mood = moods[activeIndex];
    return Container(
      height: ScreenUtils.height(200),
      margin: const EdgeInsets.only(bottom: 10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.5, end: 1.0).animate(animation),
            child: ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(activeIndex),
          padding: ScreenUtils.paddingAll(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                mood['color'].withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.1, 0.9],
            ),
          ),
          child: mood.containsKey('animation')
              ? Lottie.asset(
            mood['animation'],
            width: ScreenUtils.width(200),
            height: ScreenUtils.height(200),
          )
              : Text(
            mood['emoji'],
            style: TextStyle(fontSize: ScreenUtils.textScale(44)),
          ),
        ),

      ),
    );
  }

  Widget _buildCarousel(SleepLog model) {
    return SizedBox(
      height: ScreenUtils.height(100),
      child: PageView.builder(
        controller: _pageController,
        itemCount: moods.length,
        onPageChanged: (index) {
          model.setMood(moods[index]['emoji']);
          HapticService.lightImpact();
        },
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final difference = (index - _currentPage).abs();
          final scale = difference < 1 ? 1 - (difference * 0.3) : 0.7;
          final rotation = (index - _currentPage) *
              (difference < 1 ? 25 : 35);
          final opacity = difference < 1
              ? (1 - (difference * 0.5)).clamp(0.5, 1.0)
              : 0.6 - (difference * 0.2);
          final zTranslation =
          difference < 1 ? 60 - (difference * 60) : -60.0;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _animateToPage(index);
                HapticService.selectionClick();
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translate(0.0, 0.0, zTranslation)
                  ..rotateY(vector.radians(rotation))
                  ..scale(scale, scale),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          moods[index]['color'].withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.9],
                      ),
                    ),
                    child: Text(
                      moods[index]['emoji'],
                      style: TextStyle(
                          fontSize: ScreenUtils.textScale(44)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator(int activeIndex) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(moods.length, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: i == activeIndex
                ? ScreenUtils.width(20)
                : ScreenUtils.width(8),
            height: ScreenUtils.height(8),
            margin:
            EdgeInsets.symmetric(horizontal: ScreenUtils.width(4)),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(ScreenUtils.scale(10)),
              color: i == activeIndex
                  ? moods[activeIndex]['color']
                  : Colors.blueGrey,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMoodLabel(int activeIndex) {
    return Text(
      moods[activeIndex]['label'],
      style: TextStyle(
        color: Colors.blueGrey[100],
        fontSize: ScreenUtils.textScale(18),
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
    );
  }
}

class StressSelector extends StatelessWidget {
  const StressSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepLog>(
      builder: (context, model, _) {
        final int stressLevel = model.stressLevel.clamp(1, 10);
        final stressColor = _getStressColor(stressLevel);

        return Container(
          padding: ScreenUtils.symmetric(h: 25, v: 20),
          child: Column(
            children: [
              Text(
                'STRESS LEVEL',
                style: TextStyle(
                  color: Colors.blueGrey[200],
                  fontSize: ScreenUtils.textScale(16),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: ScreenUtils.height(15)),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: ScreenUtils.width(120),
                    height: ScreenUtils.height(100),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          stressColor.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.9],
                      ),
                    ),
                  ),
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: stressLevel > 7 ? 1.1 : 1.0,
                    curve: Curves.easeOutBack,
                    child: Text(
                      stressLevel.toString(),
                      style: TextStyle(
                        fontSize: stressLevel > 7
                            ? ScreenUtils.textScale(44)
                            : ScreenUtils.textScale(40),
                        fontWeight: FontWeight.bold,
                        color: stressColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: ScreenUtils.height(10),
                    child: Text(
                      _getStressDescription(stressLevel),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: stressColor,
                        fontSize: ScreenUtils.textScale(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtils.height(20)),
              _buildStressSlider(model, stressColor, stressLevel),
              SizedBox(height: ScreenUtils.height(10)),
              _buildStressLabels(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStressSlider(
      SleepLog model, Color activeColor, int stressLevel) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: ScreenUtils.height(8),
        thumbShape: const _CustomThumbShape(),
        overlayShape:
        const RoundSliderOverlayShape(overlayRadius: 20),
        activeTrackColor: activeColor,
        inactiveTrackColor: Colors.blueGrey,
        thumbColor: activeColor,
        overlayColor: activeColor.withOpacity(0.2),
        trackShape: _GradientRectSliderTrackShape(),
      ),
      child: Slider(
        value: stressLevel.toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        onChanged: (value) {
          model.setStressLevel(value.toInt());
          HapticService.mediumImpact();
        },
      ),
    );
  }

  Widget _buildStressLabels() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Low', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
        Text('Medium',
            style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
        Text('High', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
      ],
    );
  }

  Color _getStressColor(int level) {
    return HSVColor.fromAHSV(1.0, (level / 10) * 120, 0.8, 1.0).toColor();
  }

  String _getStressDescription(int level) {
    if (level <= 2) return 'Very Relaxed';
    if (level <= 4) return 'Calm';
    if (level <= 6) return 'Moderate';
    if (level <= 8) return 'Stressed';
    return 'Very Stressed';
  }
}

class _GradientRectSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 2,
        Offset? secondaryOffset,
      }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
      secondaryOffset: secondaryOffset,
    );

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.greenAccent,
          Colors.orangeAccent,
          Colors.orange,
          Colors.redAccent,
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(trackRect)
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        trackRect,
        Radius.circular(trackRect.height / 2),
      ),
      paint,
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double radius;

  const _CustomThumbShape({this.radius = 12.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(radius * 2, radius * 2);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()
        ..color = sliderTheme.thumbColor!.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );
  }
}
