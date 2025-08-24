import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../groq_service/groq_service.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/colors.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';
import 'package:first_flutter_app/views/chat_page/chat_page.dart';
import 'package:first_flutter_app/views/sign_in/page.dart';
import 'package:first_flutter_app/views/sign_up/page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String? aiMessage;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    debugPrint('HomePage.initState: Calling GroqService.fetchSleepMessage()');
    GroqService.fetchSleepMessage().then((value) {
      if (mounted) {
        setState(() {
          aiMessage = value.trim();
          isLoading = false;
        });
      }
    }).catchError((error) {
      debugPrint('HomePage: GroqService error → $error');
      if (mounted) {
        setState(() {
          errorMessage = 'Could not load affirmation.';
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  void _goToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void _goToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final scale = AppSizes.contentScale(screenW);
    double sz(double v) => v * scale;
    final horizontalPadding = sz(AppSizes.pagePaddingH);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenH * 0.03),
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
                  SizedBox(height: screenH * 0.02),
                  Image.asset(
                    AppAssets.homeheader,
                    width: double.infinity,
                    height: sz(AppSizes.homeHeaderHeight),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenH * 0.02),
                  Text(
                    AppStrings.weAreWhatWeDo,
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontWeight: AppFonts.bold,
                      fontSize: 28 * scale,
                      color: AppColors.bodyPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenH * 0.01),
                  Text(
                    AppStrings.homeDescription,
                    style: TextStyle(
                      fontFamily: AppFonts.helveticaRegular,
                      fontWeight: AppFonts.light,
                      fontSize: 16 * scale,
                      letterSpacing: 1.5,
                      color: AppColors.bodySecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenH * 0.015),
                  if (isLoading)
                    SizedBox(
                      height: sz(16),
                      width: sz(16),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        fontFamily: AppFonts.helveticaRegular,
                        fontWeight: AppFonts.light,
                        fontSize: 14 * scale,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else if (aiMessage != null)
                      Text(
                        aiMessage!,
                        style: TextStyle(
                          fontFamily: 'AirbnbCerealBook',
                          fontWeight: AppFonts.light,
                          fontSize: 14 * scale,
                          fontStyle: FontStyle.italic,
                          color: AppColors.bodySecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: sz(AppSizes.signUpButtonHeight),
                    child: ElevatedButton(
                      onPressed: () => _goToSignUp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background3,
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
                  SizedBox(height: screenH * 0.02),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: AppStrings.alreadyHaveAccount,
                      style: TextStyle(
                        fontFamily: AppFonts.helveticaRegular,
                        fontWeight: AppFonts.light,
                        letterSpacing: 1.5,
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
                            letterSpacing: 1.5,
                            color: AppColors.primaryPurple,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _goToSignIn(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenH * 0.02),
                ],
              ),
            ),

            // ── Flipping AI Icon ──
            Positioned(
              top: screenH * 0.015,
              right: horizontalPadding,
              child: GestureDetector(
                onTap: () => _goToChat(context),
                child: Column(
                  children: [
                    SizedBox(
                      width: sz(40),
                      height: sz(40),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_controller.value * 2 * pi),
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.smart_toy,
                          size: sz(30),
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    SizedBox(height: sz(4)),
                    Text(
                      'Talk with our sleep coach',
                      style: TextStyle(
                        fontFamily: AppFonts.AirbnbCerealBook,
                        fontWeight: AppFonts.medium,
                        fontSize: 9 * scale,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
