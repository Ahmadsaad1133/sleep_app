import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/strings.dart';
import '/constants/colors.dart';
import 'player_controls.dart';

class MusicPlayerPage extends StatefulWidget {
  final ValueNotifier<bool> onNavbarVisibilityChange;

  const MusicPlayerPage({
    Key? key,
    required this.onNavbarVisibilityChange,
  }) : super(key: key);

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  bool isPlaying = false;
  double position = 0.0;
  final double duration = 45.0;

  @override
  void initState() {
    super.initState();
    widget.onNavbarVisibilityChange.value = false;
  }

  @override
  void dispose() {
    widget.onNavbarVisibilityChange.value = true;
    super.dispose();
  }

  void seek(double toMinutes) {
    setState(() => position = toMinutes.clamp(0.0, duration));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.width / 375.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.musicPlayerBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            right: 0,
            width: 227,
            height: 312,
            child: SvgPicture.asset(
              AppStrings.nightFrameTop,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            width: 191,
            height: 173,
            child: SvgPicture.asset(
              AppStrings.nightFrameBottom,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40 * scale,
            left: 20 * scale,
            right: 20 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: 55 * scale,
                    height: 55 * scale,
                    child: Center(
                      child: SvgPicture.asset(
                        AppStrings.backIconLarge,
                        width: 55 * scale,
                        height: 55 * scale,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: SvgPicture.asset(
                        AppStrings.heartIcon,
                        width: 55 * scale,
                        height: 55 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Opacity(
                      opacity: 0.5,
                      child: SvgPicture.asset(
                        AppStrings.downloadIcon2,
                        width: 55 * scale,
                        height: 55 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: size.height * 0.5 - 40 * scale,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppStrings.nightIslandTitle,
                  style: TextStyle(
                    fontSize: 34 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    color: AppColors.musicPlayerText,
                    fontFamily: 'HelveticaNeueBold',
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  AppStrings.sleepMusicLabel,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                    color: AppColors.musicPlayerText,
                    fontFamily: 'HelveticaNeueRegular',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: size.height * 0.62,
            left: 20 * scale,
            right: 20 * scale,
            child: MusicPlayerControls(
              isPlaying: isPlaying,
              position: position,
              duration: duration,
              onPlayPause: (value) => setState(() => isPlaying = value),
              onSeek: (value) => setState(() => position = value),
              onRewind: () => seek(position - 0.25),
              onForward: () => seek(position + 0.25),
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }
}
