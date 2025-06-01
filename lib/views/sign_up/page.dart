import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/strings.dart';
import '/constants/fonts.dart';
import '/constants/assets.dart';
import '../sign_up/social_button.dart';
import '../sign_up/custom_input_field.dart';
import '/views/welcome_page/page.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController =
  TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedPolicy = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _confirmEmailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _confirmEmailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }
  void _onFocusChange() => setState(() {});
  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _confirmEmailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }
  void _submitForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      if (!_acceptedPolicy) {
        // Show an error if the checkbox wasn’t checked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.validationAcceptPolicy),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final svgHeight = w * (AppSizes.svgOrigH / AppSizes.svgOrigW);
    final double titleFontSize = (w * 0.06).clamp(18.0, 28.0);
    final double buttonHeight = (w * 0.15).clamp(48.0, 72.0);
    final double buttonFontSize = (w * 0.025).clamp(10.0, 14.0);
    final double orFontSize = (w * 0.03).clamp(10.0, 14.0);
    final double inputTextFontSize = (w * 0.04).clamp(12.0, 16.0);
    final double policyFontSize = (w * 0.035).clamp(10.0, 14.0);
    final double inputHeight = w < 320
        ? 28
        : w < 400
        ? 34
        : w < 600
        ? 44
        : 60;

    final double loginButtonHeight = (w * 0.16).clamp(48.0, 63.0);
    final double navIconSize =
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
              padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.horizontalPadding),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                physics: const BouncingScrollPhysics(),
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
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.createAccountTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontFamily: AppFonts.helveticaBold,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 28),

                      SocialButton(
                        iconPath: AppAssets.facebookIcon,
                        label: AppStrings.continueFacebook,
                        backgroundColor: AppColors.facebookBlue,
                        textColor: Colors.white,
                        height: buttonHeight,
                        fontSize: buttonFontSize,
                        outlined: false,
                        onPressed: () {
                          // TODO: Facebook login logic
                        },
                      ),
                      const SizedBox(height: 15),
                      SocialButton(
                        iconPath: AppAssets.googleIcon,
                        label: AppStrings.continueGoogle,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        height: buttonHeight,
                        fontSize: buttonFontSize,
                        outlined: true,
                        onPressed: () {
                          // TODO: Google login logic
                        },
                      ),
                      const SizedBox(height: 28),
                      Text(
                        AppStrings.orSignUpWithEmail,
                        style: TextStyle(
                          fontSize: orFontSize,
                          fontFamily: AppFonts.helveticaBold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: orFontSize * 0.05,
                          color: AppColors.textGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      CustomInputField(
                        hintText: AppStrings.hintEmail,
                        fontSize: inputTextFontSize,
                        height: inputHeight,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.validationEmailRequired;
                          }
                          if (!_isValidEmail(value.trim())) {
                            return AppStrings.validationEmailInvalid;
                          }
                          return null;
                        },
                        focusNode: _emailFocusNode,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        hintText: AppStrings.hintConfirmEmail,
                        fontSize: inputTextFontSize,
                        height: inputHeight,
                        controller: _confirmEmailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.validationConfirmEmailRequired;
                          }
                          if (value.trim() != _emailController.text.trim()) {
                            return AppStrings.validationEmailsDontMatch;
                          }
                          return null;
                        },
                        focusNode: _confirmEmailFocusNode,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        hintText: AppStrings.hintPassword,
                        fontSize: inputTextFontSize,
                        height: inputHeight,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.validationPasswordRequired;
                          }
                          if (value.length < 6) {
                            return AppStrings.validationPasswordTooShort;
                          }
                          return null;
                        },
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
                        focusNode: _passwordFocusNode,
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
                                      fontFamily: AppFonts.helveticaRegular,
                                      letterSpacing: 1,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppStrings.privacyPolicyLink,
                                    style: TextStyle(
                                      fontSize: policyFontSize,
                                      fontFamily: AppFonts.helveticaRegular,
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
                            onChanged: (val) =>
                                setState(() => _acceptedPolicy = val ?? false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: loginButtonHeight,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadiusHigh,
                              ),
                            ),
                          ),
                          child: Text(
                            AppStrings.getStarted,
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              color: Colors.white,
                              fontFamily: AppFonts.helveticaRegular,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
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
