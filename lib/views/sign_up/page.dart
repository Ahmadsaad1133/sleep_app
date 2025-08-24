import 'package:first_flutter_app/views/home_page_7/home_Page_7.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/strings.dart';
import '/constants/fonts.dart';
import '/constants/assets.dart';
import '../sign_in/social_button.dart';
import '../sign_in/custom_input_field.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedPolicy = false;
  bool _isLoading = false;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
    _confirmPasswordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.validationAcceptPolicy)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage7()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = AppStrings.signupErrorGeneric;
      if (e.code == 'weak-password') {
        message = AppStrings.weakPasswordError;
      } else if (e.code == 'email-already-in-use') {
        message = AppStrings.emailInUseError;
      } else if (e.code == 'invalid-email') {
        message = AppStrings.emailInvalidError;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.signupErrorGeneric}\n${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final svgHeight = w * (AppSizes.svgOrigH / AppSizes.svgOrigW);
    final titleFontSize = (w * 0.06).clamp(18.0, 28.0);
    final buttonHeight = (w * 0.15).clamp(48.0, 72.0);
    final buttonFontSize = (w * 0.025).clamp(10.0, 14.0);
    final orFontSize = (w * 0.03).clamp(10.0, 14.0);
    final inputFontSize = (w * 0.04).clamp(12.0, 16.0);
    final policyFontSize = (w * 0.035).clamp(10.0, 14.0);
    final inputHeight =
    w < 320 ? 28.0 : w < 400 ? 34.0 : w < 600 ? 44.0 : 60.0;
    final loginBtnHeight = (w * 0.16).clamp(48.0, 63.0);
    final navIconSize =
    w.clamp(AppSizes.navIconMinSize, AppSizes.navIconMaxSize);

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
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.horizontalPadding),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(
                              AppAssets.navigateLeftIcon,
                              width: navIconSize,
                              height: navIconSize,
                            ),
                          ),
                          Flexible(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppStrings.createAccountTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontFamily: 'AirbnbCereal',
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 0,
                            child: SvgPicture.asset(
                              AppAssets.navigateLeftIcon,
                              width: navIconSize,
                              height: navIconSize,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SocialButton(
                        assetPath: AppAssets.facebookIcon, // Changed from iconPath to assetPath
                        label: AppStrings.continueFacebook,
                        backgroundColor: AppColors.facebookBlue,
                        textColor: Colors.white,
                        height: buttonHeight,
                        fontSize: buttonFontSize,
                        outlined: false,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 15),
                      SocialButton(
                        assetPath: AppAssets.googleIcon, // Changed from iconPath to assetPath
                        label: AppStrings.continueGoogle,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        height: buttonHeight,
                        fontSize: buttonFontSize,
                        outlined: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 28),
                      Text(
                        AppStrings.orSignUpWithEmail,
                        style: TextStyle(
                          fontSize: orFontSize,
                          fontFamily: 'AirbnbCereal',
                          fontWeight: FontWeight.w700,
                          letterSpacing: orFontSize * 0.10,
                          color: AppColors.textGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      CustomInputField(
                        label: AppStrings.emailLabel, // Added required label
                        hintText: AppStrings.hintEmail,
                        fontSize: inputFontSize,
                        height: inputHeight,
                        controller: _emailController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return AppStrings.validationEmailRequired;
                          }
                          final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!regex.hasMatch(val.trim())) {
                            return AppStrings.validationEmailInvalid;
                          }
                          return null;
                        },
                        focusNode: _emailFocusNode,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        label: AppStrings.passwordLabel, // Added required label
                        hintText: AppStrings.hintPassword,
                        fontSize: inputFontSize,
                        height: inputHeight,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return AppStrings.validationPasswordRequired;
                          }
                          if (val.length < 6) {
                            return AppStrings.validationPasswordTooShort;
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                        focusNode: _passwordFocusNode,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        label: AppStrings.confirmPasswordLabel, // Added required label
                        hintText: AppStrings.confirmPasswordHint,
                        fontSize: inputFontSize,
                        height: inputHeight,
                        obscureText: _obscureConfirmPassword,
                        controller: _confirmPasswordController,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return AppStrings.confirmPasswordRequired;
                          }
                          if (val != _passwordController.text) {
                            return AppStrings.passwordsDoNotMatch;
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        focusNode: _confirmPasswordFocusNode,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppStrings.privacyPolicyPrefix,
                                    style: TextStyle(
                                      fontSize: policyFontSize,
                                      fontFamily: 'AirbnbCereal',
                                      letterSpacing: 1,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppStrings.privacyPolicyLink,
                                    style: TextStyle(
                                      fontSize: policyFontSize,
                                      fontFamily: 'AirbnbCereal',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Checkbox(
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            checkColor: Colors.white,
                            activeColor: AppColors.accent,
                            side: BorderSide(color: AppColors.textGray),
                            value: _acceptedPolicy,
                            onChanged: (v) =>
                                setState(() => _acceptedPolicy = v ?? false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: loginBtnHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadiusHigh),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            AppStrings.signUpButton,
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontFamily: 'AirbnbCereal',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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