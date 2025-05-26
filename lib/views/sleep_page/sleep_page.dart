import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/views/sleep_shell/sleep_shell_page.dart';
class SleepPage extends StatefulWidget {
  final ValueNotifier<bool> onNavbarVisibilityChange;

  const SleepPage({
    Key? key,
    required this.onNavbarVisibilityChange,
  }) : super(key: key);

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  int _categoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double scale;
    if (w <= 300) {
      scale = 0.65;
    } else if (w <= 360) {
      scale = 0.8;
    } else if (w <= 414) {
      scale = 0.95;
    } else if (w <= 600) {
      scale = 1.1;
    } else if (w <= 900) {
      scale = 1.3;
    } else {
      scale = 1.5;
    }

    final padding = 24.0 * scale;
    final categories = [
      'All', 'My', 'Anxious', 'Sleep', 'Kids', 'Calm',
      'Peace', 'Clear', 'Balance', 'Empty', 'Zen', 'Still', 'Clarity',
    ];
    final icons = [
      'assets/images/all.svg',
      'assets/images/my.svg',
      'assets/images/anxious.svg',
      'assets/images/sleep.svg',
      'assets/images/kids.svg',
    ];

    double availableWidth = w - padding * 2;
    double neededWidth = 177 * 2 + 16;
    double containersScale = availableWidth < neededWidth
        ? availableWidth / neededWidth
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/images/sleepframe.png',
            width: w,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/sleepframe2.svg',
                width: 503.56, height: 275.23,
              ),
            ),
          ),
          Positioned(
            top: 25, left: 0, right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/sleepframe3.svg',
                width: 384, height: 139,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      children: [
                        Text(
                          'Sleep Stories',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28 * scale,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'HelveticaNeueBold',
                            color: const Color(0xFFE6E7F2),
                          ),
                        ),
                        SizedBox(height: 15 * scale),
                        Text(
                          'Soothing bedtime stories to help you fall\ninto a deep and natural sleep',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18 * scale,
                            height: 1.35,
                            fontFamily: 'HelveticaNeueRegular',
                            color: const Color(0xFFE6E7F2),
                          ),
                        ),
                        SizedBox(height: 30 * scale),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final label = entry.value;
                        final isActive = idx == _categoryIndex;
                        final isLast = idx == categories.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: idx == 0 ? padding : 0,
                            right: isLast ? padding : 16 * scale,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (idx == 3) {
                                widget.onNavbarVisibilityChange.value = true;
                                SleepShellPage.navigatorKey.currentState!
                                    .pushNamed('/sleep_music');
                              } else {
                                setState(() => _categoryIndex = idx);
                              }
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 70 * scale,
                                  height: 70 * scale,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF8E97FD)
                                        : const Color(0xFF586894),
                                    borderRadius: BorderRadius.circular(28 * scale),
                                  ),
                                  child: Center(
                                    child: idx < icons.length
                                        ? SvgPicture.asset(
                                      icons[idx],
                                      width: 28 * scale,
                                      height: 28 * scale,
                                      color: Colors.white,
                                    )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: isActive
                                        ? const Color(0xFFE6E7F2)
                                        : const Color(0xFF98A1BD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 30 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/sleepmoon.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 55 * scale),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'The Ocean Moon',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 36 * scale,
                                        color: const Color(0xFFFFE7BF),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'HelveticaNeueRegular',
                                      ),
                                    ),
                                    SizedBox(height: 8 * scale),
                                    Text(
                                      'Non-stop 8-hour mixes of our\nmost popular sleep audio',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        height: 1.35,
                                        color: Colors.white,
                                        fontFamily: 'HelveticaNeueRegular',
                                      ),
                                    ),
                                    SizedBox(height: 16 * scale),
                                    GestureDetector(
                                      onTap: () {
                                      },
                                      child: Container(
                                        width: 70 * scale,
                                        height: 35 * scale,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEBEAEC),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'START',
                                            style: TextStyle(
                                              fontSize: scale <= 0.8
                                                  ? 10
                                                  : scale >= 1.3
                                                  ? 14
                                                  : 12,
                                              color: const Color(0xFF3F414E),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'HelveticaNeueRegular',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.onNavbarVisibilityChange.value = false;
                                SleepShellPage.navigatorKey.currentState!
                                    .pushNamed('/night_island')
                                    .then((_) {
                                  widget.onNavbarVisibilityChange.value = true;
                                });
                              },
                              child: _buildLabeledCard(
                                'assets/images/happycloud.svg',
                                'Night Island',
                                scale,
                                containersScale,
                              ),
                            ),
                            SizedBox(width: 16 * containersScale),
                            _buildLabeledCard(
                              'assets/images/happybirds.svg',
                              'Sweet Sleep',
                              scale,
                              containersScale,
                            ),
                          ],
                        ),
                        SizedBox(height: 30 * scale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.onNavbarVisibilityChange.value = false;
                                SleepShellPage.navigatorKey.currentState!
                                    .pushNamed('/night_island')
                                    .then((_) {
                                  widget.onNavbarVisibilityChange.value = true;
                                });
                              },
                              child: _buildLabeledCard(
                                'assets/images/bowlmoon.svg',
                                'Night Island',
                                scale,
                                containersScale,
                              ),
                            ),
                            SizedBox(width: 16 * containersScale),
                            _buildLabeledCard(
                              'assets/images/pinkmoon.svg',
                              'Night Island',
                              scale,
                              containersScale,
                            ),
                          ],
                        ),
                        SizedBox(height: 30 * scale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledCard(
      String asset, String title, double scale, double containersScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * containersScale),
          child: Container(
            width: 177 * containersScale,
            height: 122 * containersScale,
            child: SvgPicture.asset(asset, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          title,
          style: TextStyle(
            fontSize: 18 * scale,
            height: 1.08,
            color: const Color(0xFFE6E7F2),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          '45 MIN   SLEEP MUSIC',
          style: TextStyle(
            fontSize: 11 * scale,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.55 * scale,
            color: const Color(0xFF98A1BD),
          ),
        ),
      ],
    );
  }
}
