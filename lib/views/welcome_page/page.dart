import 'package:flutter/material.dart';
import 'package:first_flutter_app/constants/assets.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/constants/strings.dart';
import '/views/choose_topic/page.dart';
import 'get_started_button.dart';
import 'logo_row.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double getResponsiveSize(double baseSize) {
      if (screenWidth < 360) return baseSize * 0.8;
      if (screenWidth < 480) return baseSize * 0.9;
      if (screenWidth < 600) return baseSize;
      return baseSize * 1.1;
    }
    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.welcomeBackground), // was 'assets/images/WelcomeImage.png'
                fit: BoxFit.cover,
              ),
            ),
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.spacingLarge),
                  const LogoRow(),
                  const SizedBox(height: AppSizes.topSpacing2),
                  Text(
                    AppStrings.hiWelcome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaBold,
                      fontSize: getResponsiveSize(AppSizes.heading2Base),
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      height: 1.37,
                      letterSpacing: 0.10 * getResponsiveSize(AppSizes.headingLetterBase),
                    ),
                  ),
                  Text(
                    AppStrings.toSilentMoon,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaRegular,
                      fontSize: getResponsiveSize(AppSizes.heading2Base),
                      fontWeight: FontWeight.w100,
                      color: AppColors.white,
                      letterSpacing: 0.01 * getResponsiveSize(AppSizes.heading2LetterBase),
                    ),
                  ),
                  const SizedBox(height: AppSizes.bottomSpacing),
                  Text(
                    AppStrings.welcomeDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaBold,
                      fontSize: getResponsiveSize(AppSizes.bodyFontBase),
                      height: 1.69,
                      color: AppColors.lightGrayBackground,
                    ),
                  ),

                  const Spacer(),
                  GetStartedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChooseTopicPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
