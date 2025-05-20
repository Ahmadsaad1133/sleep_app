import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // Optionally handle focus changes
    setState(() {});
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    const svgOrigW = 547.0;
    const svgOrigH = 428.0;
    final svgHeight = w * (svgOrigH / svgOrigW);

    double titleFontSize = (w * 0.06).clamp(18.0, 28.0);
    double buttonHeight = (w * 0.15).clamp(48.0, 72.0);
    double buttonFontSize = (w * 0.025).clamp(10.0, 14.0);
    double orFontSize = (w * 0.03).clamp(10.0, 14.0);
    double inputTextFontSize = (w * 0.04).clamp(12.0, 16.0);
    double forgotFontSize = (w * 0.035).clamp(12.0, 14.0);
    double inputHeight = w < 320 ? 28 : w < 400 ? 34 : w < 600 ? 44 : 60;
    double loginButtonHeight = (w * 0.16).clamp(48.0, 63.0);
    const hp = 20.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: svgHeight,
            child: SvgPicture.asset(
              'assets/images/Frame4.svg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            'assets/images/NavigateLeft.svg',
                            width: 55,
                            height: 55,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSocialButton(
                      asset: 'assets/images/Facebook.svg',
                      label: 'CONTINUE WITH FACEBOOK',
                      backgroundColor: const Color(0xFF7583CA),
                      textColor: Colors.white,
                      height: buttonHeight,
                      fontSize: buttonFontSize,
                      outlined: false,
                    ),
                    const SizedBox(height: 20),
                    _buildSocialButton(
                      asset: 'assets/images/Google.svg',
                      label: 'CONTINUE WITH GOOGLE',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      height: buttonHeight,
                      fontSize: buttonFontSize,
                      outlined: true,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'OR LOG IN WITH EMAIL',
                      style: TextStyle(
                        fontSize: orFontSize,
                        fontFamily: 'HelveticaNeue',
                        fontWeight: FontWeight.w700,
                        letterSpacing: orFontSize * 0.05,
                        color: const Color(0xFFA1A4B2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      hint: 'Email address',
                      fontSize: inputTextFontSize,
                      height: inputHeight,
                      focusNode: _emailFocusNode,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      hint: 'Password',
                      fontSize: inputTextFontSize,
                      height: inputHeight,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      focusNode: _passwordFocusNode,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: loginButtonHeight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B6FEC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          ),
                        ),
                        child: Text(
                          'LOG IN',
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            color: Colors.white,
                            fontFamily: 'HelveticaNeue',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: forgotFontSize,
                            fontFamily: 'HelveticaNeue',
                            color: const Color(0xFF3F414E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              fontFamily: 'HelveticaNeue',
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: const Color(0xFF7B6FEC),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required double height,
    required double fontSize,
    required bool outlined,
  }) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        Padding(
          padding: asset.contains('Facebook')
              ? const EdgeInsets.only(left: 5, right: 13)
              : EdgeInsets.zero,
          child: SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: asset.contains('Google')
                ? const EdgeInsets.only(right: 8)
                : EdgeInsets.zero,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'HelveticaNeue',
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: const BorderSide(color: Color(0xFFEBEAEC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
          padding: EdgeInsets.zero,
        ),
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required double fontSize,
    required double height,
    bool obscureText = false,
    Widget? suffixIcon,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'HelveticaNeue',
          fontSize: fontSize,
          color: const Color(0xFFA1A4B2),
        ),
        filled: true,
        fillColor: const Color(0xFFF2F3F7),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: (height - fontSize) / 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        fontFamily: 'HelveticaNeue',
        fontSize: fontSize,
        color: Colors.black,
      ),
    );
  }
}
