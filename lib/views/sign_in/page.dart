import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  bool _obscurePassword = true;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  void _tryLogin() {
    if (_formKey.currentState?.validate() ?? false) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const svgOrigW = 547.0, svgOrigH = 428.0;
    final svgHeight = w * (svgOrigH / svgOrigW);

    final double titleFontSize = (w * AppSizes.titleFontFactor).clamp(
      AppSizes.titleFontMin,
      AppSizes.titleFontMax,
    );
    final double socialButtonHeight = (w * AppSizes.socialButtonHeightFactor)
        .clamp(AppSizes.socialButtonHeightMin, AppSizes.socialButtonHeightMax);
    final double socialButtonFontSize = (w * AppSizes.socialButtonFontFactor)
        .clamp(AppSizes.socialButtonFontMin, AppSizes.socialButtonFontMax);
    final double orFontSize = (w * AppSizes.orFontFactor)
        .clamp(AppSizes.orFontMin, AppSizes.orFontMax);
    final double inputFontSize = (w * AppSizes.inputFontFactor)
        .clamp(AppSizes.inputFontMin, AppSizes.inputFontMax);
    final double inputHeight = w < 320
        ? AppSizes.inputHeightXS
        : w < 400
        ? AppSizes.inputHeightS
        : w < 600
        ? AppSizes.inputHeightM
        : AppSizes.inputHeightL;
    final double loginButtonHeight = (w * AppSizes.loginButtonHeightFactor)
        .clamp(AppSizes.loginButtonHeightMin, AppSizes.loginButtonHeightMax);
    final double navigateIconSize = (w * AppSizes.navigateIconFactor)
        .clamp(AppSizes.navigateIconMin, AppSizes.navigateIconMax);
    final double forgotFontSize = (w * AppSizes.forgotFontFactor)
        .clamp(AppSizes.forgotFontMin, AppSizes.forgotFontMax);

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
            child: SvgPicture.asset(
              AppAssets.frameBackground,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.horizontalPadding),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: AppSizes.horizontalPadding,
                ),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSizes.topSpacing),
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
                      const SizedBox(height: AppSizes.topSpacing),

                      // ▶︎ Page Title
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
                      const SizedBox(height: AppSizes.sectionSpacing),
                      SocialButton(
                        assetPath: AppAssets.facebookLogo,
                        label: AppStrings.continueFacebook,
                        backgroundColor: AppColors.facebookBlue,
                        textColor: Colors.white,
                        height: socialButtonHeight,
                        fontSize: socialButtonFontSize,
                        outlined: false,
                        onPressed: () {
                          // TODO: implement Facebook login
                        },
                      ),
                      const SizedBox(height: AppSizes.elementSpacing),
                      SocialButton(
                        assetPath: AppAssets.googleLogo,
                        label: AppStrings.continueGoogle,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        height: socialButtonHeight,
                        fontSize: socialButtonFontSize,
                        outlined: true,
                        onPressed: () {
                          // TODO: implement Google login
                        },
                      ),
                      const SizedBox(height: AppSizes.sectionSpacing),
                      Text(
                        AppStrings.orLoginWithEmail,
                        style: TextStyle(
                          fontSize: orFontSize,
                          fontFamily: AppFonts.helveticaBold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: orFontSize * 0.05,
                          color: AppColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.sectionSpacing),
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
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return AppStrings.emailInvalidError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.elementSpacing),
                      CustomInputField(
                        label: AppStrings.passwordLabel,
                        hintText: AppStrings.passwordHint,
                        fontSize: inputFontSize,
                        height: inputHeight,
                        obscureText: _obscurePassword,
                        focusNode: _passwordFocusNode,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                          ),
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
                      const SizedBox(height: AppSizes.sectionSpacing),
                      SizedBox(
                        height: loginButtonHeight,
                        child: ElevatedButton(
                          onPressed: _tryLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(AppSizes.buttonRadius),
                            ),
                            textStyle: TextStyle(
                              fontFamily: AppFonts.helveticaRegular,
                              fontWeight: FontWeight.w400,
                              fontSize: socialButtonFontSize,
                            ),
                          ),
                          child: Text(
                            AppStrings.loginButton,
                            style: const TextStyle(letterSpacing: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.elementSpacing),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: implement forgot password
                          },
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
                      const SizedBox(height: AppSizes.sectionSpacing),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
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
                      const SizedBox(height: AppSizes.bottomSpacing),
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
