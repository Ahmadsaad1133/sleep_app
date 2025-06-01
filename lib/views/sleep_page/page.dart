import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/views/sleep_shell/page.dart';
import 'package:first_flutter_app/constants/strings.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/assets.dart';
import 'package:first_flutter_app/views/sleep_page/category_chip.dart';
import 'package:first_flutter_app/views/sleep_page/labeled_card.dart';
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
    final double w = MediaQuery.of(context).size.width;
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
    final double hPadding = AppSizes.baseHorizontalPadding * scale;
    final double vPadding = AppSizes.baseVerticalPadding * scale;
    final List<String> categories = AppStrings.categories;
    final List<String> icons = [
      AppAssets.iconAll,
      AppAssets.iconMy,
      AppAssets.iconAnxious,
      AppAssets.iconSleep,
      AppAssets.iconKids,
    ];
    double availableWidth = w - (AppSizes.sleepPageHorizontalPadding * scale) * 2;
    double neededWidth = AppSizes.cardWidth * 2 + AppSizes.horizontalSpacingMedium;
    double containersScale = availableWidth < neededWidth
        ? (availableWidth / neededWidth)
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SvgPicture.asset(
            AppAssets.sleepFrame1,
            width: w,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                AppAssets.sleepFrame2,
                width: AppSizes.backgroundFrame2Width,
                height: AppSizes.backgroundFrame2Height,
              ),
            ),
          ),
          Positioned(
            top: AppSizes.backgroundFrameHeightOffset,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                AppAssets.sleepFrame3,
                width: AppSizes.backgroundFrame3Width,
                height: AppSizes.backgroundFrame3Height,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: vPadding),
              child: Column(
                children: [
                  SizedBox(height: AppSizes.verticalSpacingLarge * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.sleepStoriesTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.sleepTitleFontSize * scale,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.helveticaBold,
                            color: AppColors.musicPlayerText,
                          ),
                        ),
                        SizedBox(height: AppSizes.verticalSpacingSmall * scale),
                        Text(
                          AppStrings.sleepStoriesSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.sleepSubtitleFontSize * scale,
                            height: AppSizes.sleepLineHeight,
                            fontFamily: AppFonts.helveticaRegular,
                            color: AppColors.musicPlayerText,
                          ),
                        ),
                        SizedBox(height: AppSizes.verticalSpacingMedium * scale),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.asMap().entries.map((entry) {
                        final int idx = entry.key;
                        final String label = entry.value;
                        final bool isActive = (idx == _categoryIndex);
                        final bool isLast = (idx == categories.length - 1);
                        final String? iconPath = (idx < icons.length) ? icons[idx] : null;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: (idx == 0) ? hPadding : 0,
                            right: isLast
                                ? hPadding
                                : (AppSizes.horizontalSpacingMedium * scale),
                          ),
                          child: CategoryChip(
                            label: label,
                            iconPath: iconPath,
                            isActive: isActive,
                            scale: scale,
                            onTap: () {
                              if (idx == 3) {
                                widget.onNavbarVisibilityChange.value = true;
                                SleepShellPage.navigatorKey.currentState!
                                    .pushNamed('/sleep_music');
                              } else {
                                setState(() {
                                  _categoryIndex = idx;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingMedium * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Container(
                      width: double.infinity,
                      height: AppSizes.featuredContainerHeight * scale,
                      decoration: BoxDecoration(
                        color: AppColors.featuredOverlayWhite20,
                        borderRadius:
                        BorderRadius.circular(AppSizes.featuredBorderRadius),
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(AppSizes.featuredBorderRadius),
                        child: Stack(
                          children: [
                            Image.asset(
                              AppAssets.sleepMoon,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: AppSizes.featuredImageTopPadding * scale),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.featuredTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        AppSizes.featuredTitleFontSize * scale,
                                        color: AppColors.featuredTitleColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppFonts.helveticaRegular,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                        AppSizes.verticalSpacingXS * scale),
                                    Text(
                                      AppStrings.featuredSubtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        AppSizes.featuredSubtitleFontSize *
                                            scale,
                                        height: AppSizes.featuredTextLineHeight,
                                        color: AppColors.white,
                                        fontFamily: AppFonts.helveticaRegular,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                        AppSizes.verticalSpacingMedium * scale),
                                    GestureDetector(
                                      onTap: () {
                                      },
                                      child: Container(
                                        width:
                                        AppSizes.featuredButtonWidth * scale,
                                        height:
                                        AppSizes.featuredButtonHeight * scale,
                                        decoration: BoxDecoration(
                                          color: AppColors.startBtnBgDefault,
                                          borderRadius: BorderRadius.circular(
                                              AppSizes
                                                  .featuredButtonBorderRadius),
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppStrings.featuredButtonText,
                                            style: TextStyle(
                                              fontSize: (scale <= 0.8)
                                                  ? AppSizes
                                                  .featuredButtonFontSizeSmall
                                                  : (scale >= 1.3)
                                                  ? AppSizes
                                                  .featuredButtonFontSizeLarge
                                                  : AppSizes
                                                  .featuredButtonFontSizeMedium,
                                              color:
                                              AppColors.startBtnTextDefault,
                                              fontWeight: FontWeight.w600,
                                              fontFamily:
                                              AppFonts.helveticaRegular,
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

                  SizedBox(height: AppSizes.verticalSpacingMedium * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LabeledCard(
                              assetPath: AppAssets.cardHappyCloud,
                              title: AppStrings.cardTitleNightIsland,
                              subtitle: AppStrings.cardSubtitleMusic,
                              scale: scale,
                              containersScale: containersScale,
                              onTap: () {
                                widget.onNavbarVisibilityChange.value = false;
                                SleepShellPage.navigatorKey.currentState!
                                    .pushNamed('/night_island')
                                    .then((_) {
                                  widget.onNavbarVisibilityChange.value = true;
                                });
                              },
                            ),
                            SizedBox(
                                width: AppSizes.horizontalSpacingMedium *
                                    containersScale),
                            LabeledCard(
                              assetPath: AppAssets.cardHappyBirds,
                              title: AppStrings.cardTitleSweetSleep,
                              subtitle: AppStrings.cardSubtitleMusic,
                              scale: scale,
                              containersScale: containersScale,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.verticalSpacingMedium * scale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LabeledCard(
                              assetPath: AppAssets.cardBowlMoon,
                              title: AppStrings.cardTitleNightIsland,
                              subtitle: AppStrings.cardSubtitleMusic,
                              scale: scale,
                              containersScale: containersScale,
                              onTap: () {
                                widget.onNavbarVisibilityChange.value = false;
                                SleepShellPage.navigatorKey.currentState!
                                    .pushNamed('/night_island')
                                    .then((_) {
                                  widget.onNavbarVisibilityChange.value = true;
                                });
                              },
                            ),
                            SizedBox(
                                width: AppSizes.horizontalSpacingMedium *
                                    containersScale),
                            LabeledCard(
                              assetPath: AppAssets.cardPinkMoon,
                              title: AppStrings.cardTitleNightIsland,
                              subtitle: AppStrings.cardSubtitleMusic,
                              scale: scale,
                              containersScale: containersScale,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.verticalSpacingMedium * scale),
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
}
