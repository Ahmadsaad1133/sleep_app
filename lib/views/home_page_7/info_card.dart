import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/views/course_details/page.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/colors.dart';
import '/constants/strings.dart';
class InfoCard extends StatelessWidget {
  final Color backgroundColor;
  final String imageAsset;
  final String title;
  final String subtitle;
  final bool isCourse;
  final Color titleColor;
  final Color subtitleColor;
  final Color timeTextColor;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final double? imageWidth;
  final double? imageHeight;

  const InfoCard({
    Key? key,
    required this.backgroundColor,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.isCourse,
    this.titleColor = AppColors.onPrimaryLight,
    this.subtitleColor = AppColors.onPrimaryLight,
    this.timeTextColor = AppColors.timeTextDefault,
    this.buttonBgColor = AppColors.startBtnBgDefault,
    this.buttonTextColor = AppColors.startBtnTextDefault,
    this.imageWidth,
    this.imageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const base = 414.0;
    final scale = (w / base).clamp(0.8, 1.2);
    double s(double v) => v * scale;

    final cardW = (w - s(AppSizes.bodySidePadding * 2 + AppSizes.cardSpacing)) / 2;
    final cardH = s(AppSizes.cardH_Med);

    return SizedBox(
      width: cardW,
      height: cardH,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s(AppSizes.cardRadius)),
        child: Stack(
          children: [
            Container(color: backgroundColor),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: imageWidth ?? s(AppSizes.svgW_Med),
                height: imageHeight ?? s(AppSizes.svgH_Med),
                alignment: Alignment.topRight,
                child: SvgPicture.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned(
              top: s(120),
              left: s(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: s(18),
                      fontFamily: AppFonts.helveticaBold,
                      fontWeight: AppFonts.bold,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: s(5)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: s(11),
                      fontFamily: AppFonts.helveticaBold,
                      fontWeight: AppFonts.light,
                      letterSpacing: 0.05 * s(11),
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: s(16),
              left: s(16),
              right: s(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.meditationDuration2,
                    style: TextStyle(
                      fontSize: s(11),
                      fontFamily: AppFonts.helveticaRegular,
                      fontWeight: AppFonts.light,
                      letterSpacing: 0.05 * s(11),
                      color: timeTextColor,
                    ),
                  ),
                  SizedBox(
                    width: s(90),
                    height: s(35),
                    child: ElevatedButton(
                      onPressed: isCourse
                          ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CourseDetailsPage(),
                        ),
                      )
                          : null,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(buttonBgColor),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              s(AppSizes.cardRadius * 2),
                            ),
                          ),
                        ),
                        elevation: MaterialStateProperty.all(0),
                      ),
                      child: Text(
                        AppStrings.startButton,
                        style: TextStyle(
                          fontSize: s(10),
                          fontFamily: AppFonts.helveticaRegular,
                          fontWeight: AppFonts.light,
                          letterSpacing: 0.05 * s(10),
                          color: buttonTextColor,
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
    );
  }
}
