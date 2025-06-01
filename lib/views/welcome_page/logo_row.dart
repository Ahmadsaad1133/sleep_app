import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/constants/strings.dart';
import 'package:first_flutter_app/constants/assets.dart';
class LogoRow extends StatelessWidget {
  const LogoRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double getResponsiveSize(double baseSize) {
      if (screenWidth < 360) return baseSize * 0.8;
      if (screenWidth < 480) return baseSize * 0.9;
      if (screenWidth < 600) return baseSize;
      return baseSize * 1.1;
    }
    final scaledFontSize = getResponsiveSize(AppSizes.logoFontBase);
    final letterSpacing = 0.24 * scaledFontSize;
    final svgDimension = getResponsiveSize(AppSizes.logoSvgBase);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.silent,
          style: TextStyle(
            fontFamily: AppFonts.helveticaBold,
            fontWeight: FontWeight.w700,
            fontSize: scaledFontSize,
            color: AppColors.white,
            letterSpacing: letterSpacing,
          ),
        ),
        SizedBox(width: getResponsiveSize(AppSizes.logoSpacingBase)),
        SvgPicture.asset(
          AppAssets.logoSvgPath,
          width: svgDimension,
          height: svgDimension,
        ),
        SizedBox(width: getResponsiveSize(AppSizes.logoSpacingBase)),
        Text(
          AppStrings.moon,
          style: TextStyle(
            fontFamily: AppFonts.helveticaBold,
            fontWeight: FontWeight.w700,
            fontSize: scaledFontSize,
            color: AppColors.white,
            letterSpacing: letterSpacing,
          ),
        ),
      ],
    );
  }
}
