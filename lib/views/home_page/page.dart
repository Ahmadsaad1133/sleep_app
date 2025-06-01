import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../sign_in/page.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/colors.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _goToSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(w);
    double sz(double v) => v * scale;

    final horizontalPadding = sz(AppSizes.pagePaddingH);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.homeSilent,
                                  style: TextStyle(
                                    fontFamily: AppFonts.helveticaRegular,
                                    fontWeight: AppFonts.light,
                                    fontSize: sz(18),
                                    color: AppColors.bodyPrimary,
                                  ),
                                ),
                                SizedBox(width: sz(AppSizes.iconTextSpacing)),
                                SvgPicture.asset(
                                  AppAssets.homeIcon,
                                  width: sz(AppSizes.iconMedium),
                                  height: sz(AppSizes.iconMedium),
                                ),
                                SizedBox(width: sz(AppSizes.iconTextSpacing)),
                                Text(
                                  AppStrings.homeMoon,
                                  style: TextStyle(
                                    fontFamily: AppFonts.helveticaRegular,
                                    fontWeight: AppFonts.light,
                                    fontSize: sz(18),
                                    color: AppColors.bodyPrimary,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: sz(AppSizes.contentTopPadding)),
                            SvgPicture.asset(
                              AppAssets.homeheader,
                              width: double.infinity,
                              height: sz(AppSizes.homeHeaderHeight),
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: sz(AppSizes.contentTopPadding)),
                            Text(
                              AppStrings.weAreWhatWeDo,
                              style: TextStyle(
                                fontFamily: AppFonts.helveticaBold,
                                fontWeight: AppFonts.bold,
                                fontSize: 28 * scale,
                                color: AppColors.bodyPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: sz(AppSizes.contentGapLarge)),
                            Text(
                              AppStrings.homeDescription,
                              style: TextStyle(
                                fontFamily: AppFonts.helveticaRegular,
                                fontWeight: AppFonts.light,
                                fontSize: 16 * scale,
                                color: AppColors.bodySecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: sz(AppSizes.contentGapLarge)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: sz(AppSizes.signUpButtonHeight),
                              child: ElevatedButton(
                                onPressed: () => _goToSignIn(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.buttonCornerRadius),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.signUpButton,
                                  style: TextStyle(
                                    fontFamily: AppFonts.helveticaBold,
                                    fontWeight: AppFonts.bold,
                                    fontSize: 16 * scale,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: sz(AppSizes.contentGapLarge)),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: AppStrings.alreadyHaveAccount,
                                style: TextStyle(
                                  fontFamily: AppFonts.helveticaRegular,
                                  fontWeight: AppFonts.light,
                                  fontSize: 14 * scale,
                                  color: AppColors.bodySecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppStrings.logIn,
                                    style: TextStyle(
                                      fontFamily: AppFonts.helveticaRegular,
                                      fontWeight: AppFonts.medium,
                                      fontSize: 14 * scale,
                                      color: AppColors.primaryPurple,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _goToSignIn(context),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: sz(AppSizes.pagePaddingV)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
