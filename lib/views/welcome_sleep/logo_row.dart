import 'package:flutter/material.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/strings.dart';
import 'package:first_flutter_app/constants/sizes.dart';
class LogoRow extends StatelessWidget {
  final double scale;
  const LogoRow({Key? key, required this.scale}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            AppStrings.welcomeToSleep,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.helveticaBold,
              fontSize: 22 * scale,
              color: AppColors.white,
              letterSpacing: 0.3,
              height: 1.37,
            ),
          ),
          SizedBox(height: AppSizes.titleGap * scale),
          SizedBox(
            width: 317 * scale,
            child: Text(
              AppStrings.welcomeToSleepDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.helveticaRegular,
                fontSize: 15 * scale,
                height: 1.69,
                color: AppColors.onDarkBg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
