import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/assets.dart';

/// A bold, modern 2025 DailyThoughtCard with gradient, animations, and neumorphic play button.
class DailyThoughtCard extends StatefulWidget {
  final VoidCallback? onPlay;
  const DailyThoughtCard({Key? key, this.onPlay}) : super(key: key);

  @override
  _DailyThoughtCardState createState() => _DailyThoughtCardState();
}

class _DailyThoughtCardState extends State<DailyThoughtCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= AppSizes.sm;

    return SlideTransition(
      position: _slideAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AspectRatio(
          aspectRatio: 374 / 120,
          child: Container(
            margin: const EdgeInsets.all(AppSizes.pageGapSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusHigh),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    AppAssets.dailyFrame1,
                    width: AppSizes.dailyFrame1Width,
                    height: AppSizes.dailyFrame1Height,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -20,
                  child: SvgPicture.asset(
                    AppAssets.dailyFrame2,
                    width: AppSizes.dailyFrame2Width,
                    height: AppSizes.dailyFrame2Height,
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: 120,
                  child: SvgPicture.asset(
                    AppAssets.dailyFrame3,
                    width: AppSizes.dailyFrame3Width,
                    height: AppSizes.dailyFrame3Height,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.dailyTextPaddingH,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0x99FFFFFF),
                                    Colors.white,
                                  ],
                                  stops: [0, 0.5, 1],
                                  begin: Alignment(-1, -0.3),
                                  end: Alignment(1, 0.3),
                                  tileMode: TileMode.mirror,
                                ).createShader(rect);
                              },
                              child: Text(
                                'Daily Thought',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontFamily: AppFonts.AirbnbCerealBook,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: AppSizes.cardLetterSpacing,
                                  fontSize: isSmallScreen ? 18 : 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.dailyTextGap),
                            Text(
                              'Tap play and energize your day with meditation',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 9 : AppSizes.cardSubtitleFontSize,
                                fontFamily: AppFonts.helveticaBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onPlay,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: AppSizes.dailyIconSize,
                          height: AppSizes.dailyIconSize,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(4, 4),
                                blurRadius: 8,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: const Offset(-4, -4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: AppSizes.musicPlayIconBaseSize * 0.6,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ],
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
