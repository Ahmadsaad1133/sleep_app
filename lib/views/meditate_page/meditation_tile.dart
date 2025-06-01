import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MeditationTile extends StatelessWidget {
  final String imageAsset;
  final String title;
  final double scale;

  const MeditationTile({
    required this.imageAsset,
    required this.title,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.of(context).size.width - 48 * scale - 16 * scale) / 2;
    final height = 210 * scale;
    final overlayHeight = 51.81 * scale;
    final overlayTop = height - overlayHeight;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10 * scale)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 * scale),
        child: Stack(
          children: [
            SvgPicture.asset(
              imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: overlayTop,
              left: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * scale),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 180.15 * scale,
                    height: overlayHeight,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.21),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 14 * scale,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HelveticaNeueBold',
                          height: 1.08,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
