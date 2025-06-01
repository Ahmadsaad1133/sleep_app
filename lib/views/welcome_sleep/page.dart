import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/assets.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/views/sleep_shell/page.dart';
import 'logo_row.dart';
import 'get_started_button.dart';
class WelcomeSleepPage extends StatelessWidget {
  const WelcomeSleepPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = (screenWidth / AppSizes.baseWidth).clamp(0.8, 1.2);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              AppAssets.sleepFrame2,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 71 * scale,
            left: -9 * scale,
            child: SvgPicture.asset(
              'assets/images/cloud.svg',
              width: AppSizes.logoFontBase * scale,
              height: AppSizes.logoFontBase * scale,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 50 * scale),
                LogoRow(scale: scale),

                const Spacer(),
                SvgPicture.asset(
                  'assets/images/birds.svg',
                  width: 340 * scale,
                  height: 200 * scale,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 20 * scale),
                  child: GetStartedButton(
                    scale: scale,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const SleepShellPage(),
                        ),
                      );
                    },
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
