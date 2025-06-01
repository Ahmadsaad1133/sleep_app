import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/assets.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/strings.dart';
import '/constants/fonts.dart';
import '/views/music_player/music_player_page.dart';
import '/views/sleep_music/music_card.dart';

class SleepMusicPage extends StatefulWidget {
  final ValueNotifier<bool> onNavbarVisibilityChange;

  const SleepMusicPage({
    Key? key,
    required this.onNavbarVisibilityChange,
  }) : super(key: key);

  @override
  _SleepMusicPageState createState() => _SleepMusicPageState();
}

class _SleepMusicPageState extends State<SleepMusicPage> {
  @override
  void initState() {
    super.initState();
    widget.onNavbarVisibilityChange.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = AppSizes.contentScale(screenWidth);
    final double cardScale = scale * 1.10;

    void _navigateToPlayer({required bool hideNavbar}) {
      if (hideNavbar) widget.onNavbarVisibilityChange.value = false;
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (_) => MusicPlayerPage(
            onNavbarVisibilityChange: widget.onNavbarVisibilityChange,
          ),
        ),
      )
          .then((_) {
        widget.onNavbarVisibilityChange.value = true;
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH * scale,
            vertical: AppSizes.pagePaddingV * scale * 0.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: AppSizes.musicPageTopBarPadding * scale),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        AppAssets.navigateLeft,
                        width: AppSizes.musicPageIconSize,
                        height: AppSizes.musicPageIconSize,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppStrings.sleepMusicTitle,
                          style: AppTextStyles.pageTitle(scale),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.musicPageIconSize),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.musicBetweenTitleAndCards * scale),
              for (int i = 0; i < 4; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (i == 1)
                      MusicCard(
                        asset: AppAssets.bowlMoon,
                        title: AppStrings.goodNight,
                        subtitle: AppStrings.sleepMusicDuration,
                        cardScale: cardScale,
                        useBackground: true,
                        onTap: null,
                      )
                    else if (i == 2)
                      MusicCard(
                        asset: AppAssets.happyBirds,
                        title: AppStrings.sweetSleep,
                        subtitle: AppStrings.sleepMusicDuration,
                        cardScale: cardScale,
                        useBackground: false,
                        onTap: null,
                      )
                    else
                      MusicCard(
                        asset: AppAssets.happyCloud,
                        title: AppStrings.nightIsland,
                        subtitle: AppStrings.sleepMusicDuration,
                        cardScale: cardScale,
                        useBackground: false,
                        onTap: () => _navigateToPlayer(hideNavbar: true),
                      ),
                    if (i == 1)
                      MusicCard(
                        asset: AppAssets.happyCloud2,
                        title: AppStrings.moonClouds,
                        subtitle: AppStrings.sleepMusicDuration,
                        cardScale: cardScale,
                        useBackground: false,
                        onTap: null,
                      )
                    else if (i == 2)
                      MusicCard(
                        asset: AppAssets.happyCloud,
                        title: AppStrings.nightIsland,
                        subtitle: AppStrings.sleepMusicDuration,
                        cardScale: cardScale,
                        useBackground: false,
                        onTap: () => _navigateToPlayer(hideNavbar: true),
                      )
                    else
                      MusicCard(
                        asset: AppAssets.happyBirds,
                        title: AppStrings.sweetSleep,
                        subtitle: AppStrings.sleepMusicDuration,
                        cardScale: cardScale,
                        useBackground: false,
                        onTap: null,
                      ),
                  ],
                ),
                SizedBox(height: AppSizes.musicBetweenRowsGap * scale),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
