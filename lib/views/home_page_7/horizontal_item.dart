import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/colors.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';
class HorizontalItem extends StatelessWidget {
  final int index;
  const HorizontalItem(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const baseWidth = 414.0;
    final scale = (width / baseWidth).clamp(0.8, 1.2);
    double s(double v) => v * scale;

    final svg = index == 0 ? AppAssets.container1 : AppAssets.container2;
    final title =
    index == 0 ? AppStrings.Focus : AppStrings.happinessLabel;

    return Container(
      width: s(162),
      margin: EdgeInsets.only(right: s(AppSizes.cardSpacing)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(svg, width: s(162), height: s(113), fit: BoxFit.cover),
          SizedBox(height: s(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: s(18),
                    fontFamily: AppFonts.helveticaBold,
                    fontWeight: AppFonts.bold,
                    color: AppColors.bodyPrimary,
                  ),
                ),
                SizedBox(height: s(6)),
                Text(
                  AppStrings.meditationDuration,
                  style: TextStyle(
                    fontSize: s(11),
                    fontFamily: AppFonts.helveticaRegular,
                    fontWeight: AppFonts.light,
                    letterSpacing: 0.05 * s(11),
                    color: AppColors.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
