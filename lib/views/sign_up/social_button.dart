import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/assets.dart';
class SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double fontSize;
  final bool outlined;
  final VoidCallback onPressed;
  const SocialButton({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.height,
    required this.fontSize,
    required this.outlined,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: AppSizes.horizontalPadding),
        Padding(
          padding: iconPath == AppAssets.facebookIcon
              ? const EdgeInsets.only(left: 5, right: 13)
              : EdgeInsets.zero,
          child: SvgPicture.asset(iconPath, width: 24, height: 24),
        ),
        const SizedBox(width: AppSizes.horizontalPadding),
        Expanded(
          child: Padding(
            padding: iconPath == AppAssets.googleIcon
                ? const EdgeInsets.only(right: 8)
                : EdgeInsets.zero,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: AppFonts.helveticaRegular,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.horizontalPadding),
      ],
    );

    return SizedBox(
      height: height,
      child: outlined
          ? OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: const BorderSide(color: AppColors.googleBorder),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(AppSizes.borderRadiusHigh),
          ),
          padding: EdgeInsets.zero,
        ),
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(AppSizes.borderRadiusHigh),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: buttonChild,
      ),
    );
  }
}
