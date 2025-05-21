import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/views/choose_topic/choose_topic_page.dart'; // Make sure this path is correct

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

    double getButtonFontSize() => getResponsiveSize(14.0);

    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            position: DecorationPosition.background,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/WelcomeImage.png'),
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
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Silent',
                          style: TextStyle(
                            fontFamily: 'AirbnbCereal',
                            fontWeight: FontWeight.w700,
                            fontSize: getResponsiveSize(16.0),
                            color: Colors.white,
                            letterSpacing: 0.24 * getResponsiveSize(16.0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/images/logo2.svg',
                          width: getResponsiveSize(30.0),
                          height: getResponsiveSize(30.0),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Moon',
                          style: TextStyle(
                            fontFamily: 'AirbnbCereal',
                            fontWeight: FontWeight.w700,
                            fontSize: getResponsiveSize(16.0),
                            color: Colors.white,
                            letterSpacing: 0.24 * getResponsiveSize(16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Hi Afsar, Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HelveticaNeueBold',
                      fontSize: getResponsiveSize(30.0),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFECCC),
                      height: 1.37,
                      letterSpacing: 0.01 * getResponsiveSize(30.0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'to Silent Moon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HelveticaNeueRegular',
                      fontSize: getResponsiveSize(30.0),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFFFECCC),
                      letterSpacing: 0.01 * getResponsiveSize(30.0),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: screenWidth > 390 ? 374 : double.infinity,
                    height: getResponsiveSize(63.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChooseTopicPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontWeight: FontWeight.w700,
                          fontSize: getButtonFontSize(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
