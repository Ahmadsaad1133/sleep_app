import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
class SocialButton extends StatelessWidget {
  final String assetPath;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double fontSize;
  final bool outlined;
  final VoidCallback? onPressed;

  const SocialButton({
    Key? key,
    required this.assetPath,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.height,
    required this.fontSize,
    this.outlined = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: AppSizes.socialIconLeftPadding),
        Padding(
          padding: assetPath.contains('facebook')
              ? const EdgeInsets.only(left: 5)
              : EdgeInsets.zero,
          child: SvgPicture.asset(
            assetPath,
            width: AppSizes.socialIconSize,
            height: AppSizes.socialIconSize,
          ),
        ),
        const SizedBox(width: AppSizes.socialIconRightPadding),
        Expanded(
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
        const SizedBox(width: AppSizes.socialIconRightPadding),
      ],
    );

    final ButtonStyle buttonStyle = outlined
        ? OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      side: const BorderSide(color: AppColors.outlineGrey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
      padding: EdgeInsets.zero,
      textStyle: TextStyle(
        fontFamily: AppFonts.helveticaRegular,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
    )
        : ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
      padding: EdgeInsets.zero,
      elevation: 0,
      textStyle: TextStyle(
        fontFamily: AppFonts.helveticaRegular,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
    );

    return SizedBox(
      height: height,
      child: outlined
          ? OutlinedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }
}
