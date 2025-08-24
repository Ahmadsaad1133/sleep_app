// lib/views/sign_in/page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../routes.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/strings.dart';
import '/constants/fonts.dart';
import '/constants/assets.dart';
import 'social_button.dart';
import 'custom_input_field.dart';
import '/views/sign_up/page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null && mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      String message = AppStrings.loginErrorGeneric;
      if (e.code == 'user-not-found') {
        message = AppStrings.loginErrorUserNotFound;
      } else if (e.code == 'wrong-password') {
        message = AppStrings.loginErrorWrongPassword;
      } else if (e.code == 'invalid-email') {
        message = AppStrings.emailInvalidError;
      } else if (e.code == 'user-disabled') {
        message = 'Account disabled';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Try later';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.loginErrorGeneric}\n${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    const svgOrigW = 547.0, svgOrigH = 428.0;
    final svgHeight = w * (svgOrigH / svgOrigW);
    final topSpacing = (h * 0.05).clamp(AppSizes.topSpacing, AppSizes.topSpacing2);
    final sectionSpacing = (h * 0.03).clamp(AppSizes.sectionSpacing2, AppSizes.sectionGap);
    final elementSpacing = (h * 0.02).clamp(AppSizes.pageGapSmall, AppSizes.elementSpacing);
    final bottomSpacing = (h * 0.04).clamp(AppSizes.bottomSpacing, AppSizes.pageGapMedium);
    final titleFontSize = (w * AppSizes.titleFontFactor).clamp(AppSizes.titleFontMin, AppSizes.titleFontMax);
    final socialButtonHeight = (w * AppSizes.socialButtonHeightFactor).clamp(AppSizes.socialButtonHeightMin, AppSizes.socialButtonHeightMax);
    final socialButtonFontSize = (w * AppSizes.socialButtonFontFactor).clamp(AppSizes.socialButtonFontMin, AppSizes.socialButtonFontMax);
    final orFontSize = (w * AppSizes.orFontFactor).clamp(AppSizes.orFontMin, AppSizes.orFontMax);
    final inputFontSize = (w * AppSizes.inputFontFactor).clamp(AppSizes.inputFontMin, AppSizes.inputFontMax);
    final inputHeight = w < AppSizes.xs
        ? AppSizes.inputHeightXS
        : w < AppSizes.sm
        ? AppSizes.inputHeightS
        : w < AppSizes.md
        ? AppSizes.inputHeightM
        : AppSizes.inputHeightL;
    final loginButtonHeight = (w * AppSizes.loginButtonHeightFactor).clamp(AppSizes.loginButtonHeightMin, AppSizes.loginButtonHeightMax);
    final navigateIconSize = (w * AppSizes.navigateIconFactor).clamp(AppSizes.navigateIconMin, AppSizes.navigateIconMax);
    final forgotFontSize = (w * AppSizes.forgotFontFactor).clamp(AppSizes.forgotFontMin, AppSizes.forgotFontMax);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: svgHeight,
            child: SvgPicture.asset(AppAssets.frameBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.horizontalPadding),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomSpacing),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: topSpacing),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(
                              AppAssets.navigateBack,
                              width: navigateIconSize,
                              height: navigateIconSize,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),

                      SizedBox(height: topSpacing),
                      Text(
                        AppStrings.welcomeBack,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontFamily: AppFonts.helveticaBold,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: AppColors.textDark,
                        ),
                      ),

                      SizedBox(height: sectionSpacing),

                      SocialButton(
                        assetPath: AppAssets.facebookLogo,
                        label: AppStrings.continueFacebook,
                        backgroundColor: AppColors.facebookBlue,
                        textColor: Colors.white,
                        height: socialButtonHeight,
                        fontSize: socialButtonFontSize,
                        outlined: false,
                        onPressed: () {/* TODO */},
                      ),

                      SizedBox(height: elementSpacing),

                      SocialButton(
                        assetPath: AppAssets.googleLogo,
                        label: AppStrings.continueGoogle,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        height: socialButtonHeight,
                        fontSize: socialButtonFontSize,
                        outlined: true,
                        onPressed: () {/* TODO */},
                      ),

                      SizedBox(height: sectionSpacing),
                      Text(
                        AppStrings.orLoginWithEmail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: orFontSize,
                          fontFamily: AppFonts.helveticaBold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: orFontSize * 0.05,
                          color: AppColors.textGrey,
                        ),
                      ),

                      SizedBox(height: sectionSpacing),

                      CustomInputField(
                        label: AppStrings.emailLabel,
                        hintText: AppStrings.emailHint,
                        fontSize: inputFontSize,
                        height: inputHeight,
                        focusNode: _emailFocusNode,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.emailEmptyError;
                          }
                          final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!regex.hasMatch(value.trim())) {
                            return AppStrings.emailInvalidError;
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: elementSpacing),

                      CustomInputField(
                        label: AppStrings.passwordLabel,
                        hintText: AppStrings.passwordHint,
                        fontSize: inputFontSize,
                        height: inputHeight,
                        obscureText: _obscurePassword,
                        focusNode: _passwordFocusNode,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.passwordEmptyError;
                          }
                          if (value.trim().length < AppSizes.passwordMinLength) {
                            return AppStrings.passwordShortError;
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sectionSpacing),

                      SizedBox(
                        height: loginButtonHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _tryLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                            ),
                            textStyle: TextStyle(
                              fontFamily: AppFonts.helveticaRegular,
                              fontWeight: FontWeight.w400,
                              fontSize: socialButtonFontSize,
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            AppStrings.loginButton,
                            style: const TextStyle(letterSpacing: 1),
                          ),
                        ),
                      ),

                      SizedBox(height: elementSpacing),

                      Center(
                        child: TextButton(
                          onPressed: () {/* TODO */},
                          child: Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              fontFamily: AppFonts.helveticaRegular,
                              fontSize: forgotFontSize,
                              fontWeight: FontWeight.w400,
                              height: 1.08,
                              letterSpacing: forgotFontSize * 0.05,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: sectionSpacing),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpPage()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.dontHaveAccount,
                              style: TextStyle(
                                fontFamily: AppFonts.helveticaRegular,
                                fontSize: AppSizes.signupPromptFontSize,
                                color: AppColors.textGrey,
                              ),
                              children: [
                                TextSpan(
                                  text: AppStrings.signUp,
                                  style: TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppSizes.signupPromptFontSize,
                                    fontFamily: AppFonts.helveticaRegular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: bottomSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}