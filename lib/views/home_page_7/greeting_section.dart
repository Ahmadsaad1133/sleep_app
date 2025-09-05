import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/fonts.dart';
class GreetingSection extends StatelessWidget {
  final double Function(double) scale;

  const GreetingSection({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: scale(200),
      child: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/travelbackground.json',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              repeat: true,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Good morning…',
                  style: TextStyle(
                    fontSize: scale(30),
                    fontFamily: AppFonts.helveticaBold,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: scale(8)),
                Text(
                  'We wish you…',
                  style: TextStyle(
                    fontSize: scale(18),
                    fontFamily: AppFonts.helveticaRegular,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}