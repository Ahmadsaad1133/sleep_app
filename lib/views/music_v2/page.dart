import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/sizes.dart';
import '/constants/assets.dart';
import '/constants/strings.dart';
import 'widget.dart';

class MusicV2Page extends StatefulWidget {
  const MusicV2Page({Key? key}) : super(key: key);

  @override
  _MusicV2PageState createState() => _MusicV2PageState();
}

class _MusicV2PageState extends State<MusicV2Page> {
  bool isPlaying = false;
  double position = 0.0;
  final double duration = 45.0;

  void seek(double toMinutes) {
    setState(() {
      position = toMinutes.clamp(0.0, duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenWidth / AppSizes.baseWidth;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            width: screenWidth * 0.40,
            height: screenWidth * 0.40,
            child: SvgPicture.asset(AppAssets.backframe1),
          ),
          Positioned(
            top: 0,
            right: 0,
            width: screenWidth * 0.50,
            height: screenHeight * 0.50,
            child: SvgPicture.asset(
              AppAssets.backframe2,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            width: screenWidth * 0.55,
            height: screenHeight * 0.50,
            child: SvgPicture.asset(
              AppAssets.backframe3,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: screenWidth * 0.40,
              height: screenWidth * 0.45,
              child: SvgPicture.asset(
                AppAssets.backframe4,
                fit: BoxFit.fill,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: AppSizes.musicPageTopBarPadding * scale,
            left: AppSizes.musicPageSideBarPadding * scale,
            right: AppSizes.musicPageSideBarPadding * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    AppAssets.removeIcon,
                    width: AppSizes.musicPageIconSize * scale,
                    height: AppSizes.musicPageIconSize * scale,
                  ),
                ),
                Row(
                  children: [
                    Opacity(
                      opacity: AppSizes.musicPageIconOpacity,
                      child: SvgPicture.asset(
                        AppAssets.heartIcon2,
                        width: AppSizes.musicPageIconSize * scale,
                        height: AppSizes.musicPageIconSize * scale,
                      ),
                    ),
                    SizedBox(width: AppSizes.musicPageIconSpacing * scale),
                    Opacity(
                      opacity: AppSizes.musicPageIconOpacity,
                      child: SvgPicture.asset(
                        AppAssets.downloadIcon,
                        width: AppSizes.musicPageIconSize * scale,
                        height: AppSizes.musicPageIconSize * scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.musicPageContentHorizontalPadding * scale,
              ),
              child: MusicV2Widget(
                isPlaying: isPlaying,
                position: position,
                duration: duration,
                onPrevious: () => seek(position - 0.25),
                onPlayPause: () => setState(() => isPlaying = !isPlaying),
                onNext: () => seek(position + 0.25),
                onSeek: (v) => setState(() => position = v),
                title: AppStrings.musicDefaultTitle,
                subtitle: AppStrings.musicDefaultSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
