import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/views/sleep_page/sleep_page.dart';

class WelcomeSleepPage extends StatelessWidget {
  const WelcomeSleepPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375).clamp(0.8, 1.2);
    final buttonWidth = screenWidth * 0.9;
    final buttonHeight = 63 * scale;
    final buttonRadius = BorderRadius.circular(buttonHeight / 2);

    return Scaffold(
      backgroundColor: const Color(0xFF03174C),
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/sleepframe.svg',
              fit: BoxFit.cover,
            ),
          ),

          // Cloud SVG
          Positioned(
            top: 71 * scale,
            left: -9 * scale,
            width: 50 * scale,
            height: 24 * scale,
            child: SvgPicture.asset(
              'assets/images/cloud.svg',
              fit: BoxFit.fill,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 50 * scale),

                // Centered text with no right padding
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome to Sleep',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'HelveticaNeueBold',
                          fontSize: 22 * scale,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.37,
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      SizedBox(
                        width: 317 * scale,
                        child: Text(
                          'Explore the new king of sleep. It uses sound\n'
                              'and visualization to create perfect conditions\n'
                              'for refreshing sleep.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'HelveticaNeueRegular',
                            fontSize: 15 * scale,
                            height: 1.69,
                            color: const Color(0xFFEBEAEC),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Birds SVG
                SvgPicture.asset(
                  'assets/images/birds.svg',
                  width: 340 * scale,
                  height: 200 * scale,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                // Get Started Button
                Padding(
                  padding: EdgeInsets.only(bottom: 20 * scale),
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SleepPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E97FD),
                        shape: RoundedRectangleBorder(
                          borderRadius: buttonRadius,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeueBold',
                          fontSize: 16 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
