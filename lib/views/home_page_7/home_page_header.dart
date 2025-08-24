import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/sizes.dart';
import '../../constants/strings.dart';


class HomePageHeader extends StatelessWidget {
  final double Function(double) scale;

  const HomePageHeader({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.homeSilent,
            style: TextStyle(
                fontSize: scale(16),
                fontFamily: AppFonts.helveticaBold,
                fontWeight: FontWeight.w300,
                letterSpacing: 3.84 * scale(1),
                color: AppColors.bodyPrimary
            )
        ),
        SizedBox(width: scale(AppSizes.iconTextSpacing)),
        SvgPicture.asset(
            AppAssets.homeIcon,
            width: scale(AppSizes.headerIconSize),
            height: scale(AppSizes.headerIconSize)
        ),
        SizedBox(width: scale(AppSizes.iconTextSpacing)),
        Text(AppStrings.homeMoon,
            style: TextStyle(
                fontSize: scale(16),
                fontFamily: AppFonts.helveticaBold,
                fontWeight: FontWeight.w300,
                letterSpacing: 3.84 * scale(1),
                color: AppColors.bodyPrimary
            )
        ),
      ],
    );
  }
}