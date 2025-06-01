import 'package:flutter/material.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/constants/strings.dart';
class GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GetStartedButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double getResponsiveSize(double baseSize) {
      if (screenWidth < 360) return baseSize * 0.8;
      if (screenWidth < 480) return baseSize * 0.9;
      if (screenWidth < 600) return baseSize;
      return baseSize * 1.1;
    }
    final double buttonFont = getResponsiveSize(AppSizes.buttonFontBase);
    final buttonWidth = screenWidth > AppSizes.buttonWidthThreshold
        ? AppSizes.buttonWidthMax
        : double.infinity;
    final buttonHeight = getResponsiveSize(AppSizes.buttonHeightBase);
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.getStarted.toUpperCase(),
          style: TextStyle(
            fontFamily: AppFonts.helveticaRegular,
            fontWeight: FontWeight.w700,
            letterSpacing: AppSizes.buttonLetterSpacing,
            fontSize: buttonFont,
          ),
        ),
      ),
    );
  }
}
