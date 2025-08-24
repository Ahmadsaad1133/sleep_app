import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/assets.dart';
import '../../constants/fonts.dart';
import '../bedtime_page/bedtime_story_page.dart';

class BedtimePromoCard extends StatelessWidget {
  final double Function(double) scale;

  const BedtimePromoCard({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BedtimeStoryPage())
      ),
      child: SizedBox(
        width: scale(260),
        child: Stack(children: [
          Positioned.fill(
              child: SvgPicture.asset(
                  AppAssets.fullMoon,
                  fit: BoxFit.cover,
                  width: scale(45),
                  height: scale(45)
              )
          ),
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.purple.shade600.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24)
                  )
              )
          ),
          Container(
            padding: EdgeInsets.all(scale(16)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.book, size: scale(32), color: Colors.white),
              SizedBox(height: scale(8)),
              const Text(
                  'AI Bedtime Stories',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.helveticaBold
                  )
              ),
              SizedBox(height: scale(4)),
              const Text(
                  'Personalized AI-generated tales to help you drift off.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70,
                      fontFamily: AppFonts.AirbnbCerealBook
                  )
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}