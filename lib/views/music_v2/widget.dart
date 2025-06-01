import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/sizes.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';

class MusicV2Widget extends StatelessWidget {
  final bool isPlaying;
  final double position;
  final double duration;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final ValueChanged<double> onSeek;
  final String title;
  final String subtitle;

  const MusicV2Widget({
    Key? key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onSeek,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  String _formatTime(double minutes) {
    final totalSeconds = (minutes * 60).toInt();
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Widget _svgButton(String asset, VoidCallback onTap, double scale) {
    final size = AppSizes.musicSvgButtonSize * scale;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(asset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / AppSizes.baseWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: AppSizes.musicTitleTopPadding),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                  color: AppColors.textPrimary,
                  fontFamily: AppFonts.helveticaBold,
                ),
              ),
              SizedBox(height: AppSizes.musicBetweenTitleAndSubtitle),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.helveticaRegular,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppSizes.musicBetweenTextAndControls),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _svgButton(AppAssets.prevButton, onPrevious, scale),
            GestureDetector(
              onTap: onPlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: AppSizes.musicControlOuterWidth * scale,
                    height: AppSizes.musicControlOuterHeight * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.controlBorder,
                        width: AppSizes.musicControlBorderWidth * scale,
                      ),
                    ),
                  ),
                  Container(
                    width: AppSizes.musicControlInnerDiameter * scale,
                    height: AppSizes.musicControlInnerDiameter * scale,
                    decoration: BoxDecoration(
                      color: AppColors.controlInner,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: AppSizes.musicPlayIconBaseSize * 0.6 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _svgButton(AppAssets.nextButton, onNext, scale),
          ],
        ),
        SizedBox(height: AppSizes.musicBetweenControlsAndSlider),
        Slider(
          min: 0,
          max: duration,
          value: position,
          onChanged: onSeek,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(position),
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.08,
                  color: AppColors.textPrimary,
                  fontFamily: AppFonts.helveticaRegular,
                ),
              ),
              Text(
                _formatTime(duration),
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.08,
                  color: AppColors.textPrimary,
                  fontFamily: AppFonts.helveticaRegular,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
