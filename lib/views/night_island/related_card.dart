import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RelatedMusicCard extends StatelessWidget {
  final String assetName;
  final String title;
  final double scale;
  final double cardWidth;

  const RelatedMusicCard({
    Key? key,
    required this.assetName,
    required this.title,
    required this.scale,
    required this.cardWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * scale),
          child: Container(
            width: cardWidth,
            height: 122 * scale,
            child: SvgPicture.asset(
              assetName,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'HelveticaNeueBold',
            fontSize: 18 * scale,
            height: 1.08,
            color: const Color(0xFFE6E7F2),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          '45 MIN   SLEEP MUSIC',
          style: TextStyle(
            fontSize: 11 * scale,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.55 * scale,
            color: const Color(0xFF98A1BD),
          ),
        ),
      ],
    );
  }
}
