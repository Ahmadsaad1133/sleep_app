import 'package:flutter/material.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/strings.dart';
import 'package:first_flutter_app/constants/sizes.dart';
class GetStartedButton extends StatelessWidget {
  final double scale;
  final VoidCallback onPressed;
  const GetStartedButton({
    Key? key,
    required this.scale,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonWidth = screenWidth * 0.9;
    final double buttonHeight = AppSizes.signUpButtonHeight * scale;
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.getStarted2,
          style: TextStyle(
            fontFamily: AppFonts.helveticaBold,
            fontSize: 16 * scale,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
