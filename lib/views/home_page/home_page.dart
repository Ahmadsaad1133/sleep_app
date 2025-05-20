import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../sign_in/sign_in_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double baseWidth = 414;
    double rawScale = screenWidth / baseWidth;
    final double scale = pow(rawScale, 2).clamp(0.0, 1.0).toDouble();

    double getFontSize(double baseSize) => baseSize * scale;
    double getSize(double baseSize) => baseSize * scale;

    void _goToSignIn() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 400,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/images/Frame.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: getSize(50)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Silent',
                              style: TextStyle(
                                fontSize: getFontSize(16),
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 3.84 * scale,
                              ),
                            ),
                            SizedBox(width: getSize(8)),
                            SvgPicture.asset(
                              'assets/images/logo.svg',
                              width: 30 * scale,
                              height: 30 * scale,
                            ),
                            SizedBox(width: getSize(8)),
                            Text(
                              'Moon',
                              style: TextStyle(
                                fontSize: getFontSize(16),
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 3.84 * scale,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SvgPicture.asset(
                          'assets/images/Image1.svg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: getSize(20)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getSize(20)),
                child: Column(
                  children: [
                    Text(
                      'We are what we do',
                      style: TextStyle(
                        fontSize: getFontSize(30),
                        fontFamily: 'HelveticaNeue',
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getSize(20)),
                    Text(
                      'Thousands of people are using Silent Moon for smalls meditation',
                      style: TextStyle(
                        fontSize: getFontSize(16),
                        fontFamily: 'HelveticaNeue',
                        fontWeight: FontWeight.w700,
                        height: 1.65,
                        color: const Color(0xFFA1A4B2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getSize(40)),
                    SizedBox(
                      width: double.infinity,
                      height: 63 * scale,
                      child: ElevatedButton(
                        onPressed: _goToSignIn,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color(0xFF8E97FD)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38 * scale),
                            ),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: getFontSize(16),
                            fontFamily: 'AirbnbCereal',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: getSize(20)),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'ALREADY HAVE AN ACCOUNT? ',
                        style: TextStyle(
                          fontSize: getFontSize(14),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700,
                          height: 1.08,
                          letterSpacing: 0.7 * scale,
                          color: const Color(0xFFA1A4B2),
                        ),
                        children: [
                          TextSpan(
                            text: 'LOG IN',
                            style: TextStyle(
                              fontSize: getFontSize(14),
                              fontFamily: 'HelveticaNeue',
                              fontWeight: FontWeight.w700,
                              height: 1.08,
                              letterSpacing: 0.7 * scale,
                              color: const Color(0xFF8E97FD),
                            ),
                            recognizer: TapGestureRecognizer()..onTap = _goToSignIn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



