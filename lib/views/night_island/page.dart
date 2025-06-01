import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'related_card.dart';
import '/constants/assets.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
import '/constants/sizes.dart';
import '/constants/strings.dart';
class NightIslandPage extends StatefulWidget {
  final ValueNotifier<bool> onNavbarVisibilityChange;
  const NightIslandPage({Key? key, required this.onNavbarVisibilityChange}) : super(key: key);
  @override
  _NightIslandPageState createState() => _NightIslandPageState();
}
class _NightIslandPageState extends State<NightIslandPage> {
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
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(screenWidth) * AppSizes.imageSizeFactor;
    final topPadding = MediaQuery.of(context).padding.top;
    final horizontalPadding = AppSizes.pagePaddingH * scale;

    return Scaffold(
      backgroundColor: AppColors.musicPlayerBg,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSizes.pagePaddingV * scale,
        ).copyWith(bottom: AppSizes.btnHeight * scale),
        child: SizedBox(
          width: AppSizes.headerImageWidth * scale,
          height: AppSizes.signUpButtonHeight * scale,
          child: ElevatedButton(
            onPressed: () {
              // TODO: handle button tap
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius * scale),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              AppStrings.startButton.toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.helveticaBold,
                fontSize: 14 * scale,
                color: AppColors.white,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth,
              height: AppSizes.headerImageHeight + AppSizes.headerIconPadding,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSizes.cardRadius),
                      bottomRight: Radius.circular(AppSizes.cardRadius),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.courseHeader2,
                      width: double.infinity,
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Positioned(
                    top: topPadding + AppSizes.headerIconSpacing,
                    left: AppSizes.headerIconPadding,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        AppAssets.backButton,
                        width: AppSizes.musicPageIconSize * scale,
                        height: AppSizes.musicPageIconSize * scale,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPadding + AppSizes.headerIconSpacing,
                    right: AppSizes.headerIconPadding,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.heartButton,
                          width: AppSizes.musicPageIconSize * scale,
                          height: AppSizes.musicPageIconSize * scale,
                        ),
                        SizedBox(width: AppSizes.musicPageIconSpacing * scale),
                        SvgPicture.asset(
                          AppAssets.downloadButton,
                          width: AppSizes.musicPageIconSize * scale,
                          height: AppSizes.musicPageIconSize * scale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizes.contentGapLarge * scale),
                  Text(
                    AppStrings.nightIslandTitle,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaBold,
                      fontSize: 34 * scale,
                      fontWeight: AppFonts.bold,
                      height: 1.08,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: AppSizes.titleGap * scale),
                  Text(
                    AppStrings.sleepMusicLabel,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaRegular,
                      fontSize: 14 * scale,
                      fontWeight: AppFonts.light,
                      letterSpacing: 0.7 * scale,
                      color: AppColors.textGray,
                    ),
                  ),
                  SizedBox(height: AppSizes.subtitleGap * scale),
                  Text(
                    'Ease the mind into a restful night’s sleep with\nthese deep, ambient tones.',
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaRegular,
                      fontSize: 14 * scale,
                      fontWeight: AppFonts.light,
                      height: 1.45,
                      letterSpacing: 0.7 * scale,
                      color: AppColors.textGray,
                    ),
                  ),
                  SizedBox(height: AppSizes.sectionGap * scale),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.heartIcon,
                        width: AppSizes.iconSmall * scale,
                        height: AppSizes.iconSmall * scale,
                      ),
                      SizedBox(width: AppSizes.iconTextSpacing * scale),
                      Text(
                        '24,234 Favorites',
                        style: TextStyle(
                          fontFamily: AppFonts.helveticaRegular,
                          fontSize: 14 * scale,
                          fontWeight: AppFonts.light,
                          letterSpacing: 0.7 * scale,
                          color: AppColors.textGray,
                        ),
                      ),
                      SizedBox(width: AppSizes.imageSidePadding * scale),
                      SvgPicture.asset(
                        AppAssets.headphoneIcon,
                        width: AppSizes.iconSmall * scale,
                        height: AppSizes.iconSmall * scale,
                      ),
                      SizedBox(width: AppSizes.iconTextSpacing * scale),
                      Text(
                        '34,234 Listening',
                        style: TextStyle(
                          fontFamily: AppFonts.helveticaRegular,
                          fontSize: 14 * scale,
                          fontWeight: AppFonts.light,
                          letterSpacing: 0.7 * scale,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.sectionGap * scale),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  SizedBox(height: AppSizes.sectionGap * scale),
                  Text(
                    AppStrings.recommendedForYou,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaBold,
                      fontSize: 24 * scale,
                      height: 1.08,
                      color: AppColors.musicPlayerText,
                    ),
                  ),
                  SizedBox(height: AppSizes.contentSpacing * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RelatedMusicCard(
                        assetName: AppAssets.bowlMoon,
                        title: AppStrings.nightIslandTitle,
                        scale: scale,
                        cardWidth: (screenWidth - 2 * horizontalPadding - AppSizes.cardSpacing * scale) / 2,
                      ),
                      RelatedMusicCard(
                        assetName: AppAssets.happybirds,
                        title: 'Sweet Sleep',
                        scale: scale,
                        cardWidth: (screenWidth - 2 * horizontalPadding - AppSizes.cardSpacing * scale) / 2,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.pageGapLarge * scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
