import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NightIslandPage extends StatelessWidget {
  const NightIslandPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375 * 0.8;
    final topPadding = MediaQuery.of(context).padding.top;
    final double horizontalPadding = 20 * scale;

    Widget buildLabeledCard(String assetName, String title, {double? cardWidth}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * scale),
            child: Container(
              width: cardWidth ?? 177 * scale,
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

    return Scaffold(
      backgroundColor: const Color(0xFF03174C),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 20 * scale,
        ),
        child: SizedBox(
          width: 374 * scale,
          height: 63 * scale,
          child: ElevatedButton(
            onPressed: () {
              // TODO: handle button tap
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E97FD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38 * scale),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'PLAY',
              style: TextStyle(
                fontFamily: 'HelveticaNeueBold',
                fontSize: 14,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 414,
                height: 288,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/happycloud.svg',
                        width: 414,
                        height: 288,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: topPadding + 16,
                      left: 16,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          'assets/images/NavigateLeft.svg',
                          width: 55 * scale,
                          height: 55 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: topPadding + 16,
                      right: 16,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/heart.svg',
                            width: 55 * scale,
                            height: 55 * scale,
                          ),
                          SizedBox(width: 16 * scale),
                          SvgPicture.asset(
                            'assets/images/download.svg',
                            width: 55 * scale,
                            height: 55 * scale,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30 * scale),
                  Text(
                    'Night Island',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeueBold',
                      fontSize: 34 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Text(
                    'SLEEP MUSIC',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.7 * scale,
                      color: const Color(0xFFA1A4B2),
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Text(
                    'Ease the mind into a restful night’s sleep with\nthese deep, ambient tones.',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w300,
                      height: 1.45,
                      letterSpacing: 0.7 * scale,
                      color: const Color(0xFFA1A4B2),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/heartIcon.svg',
                        width: 19 * scale,
                        height: 16 * scale,
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        '24,234 Favorites',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.7 * scale,
                          color: const Color(0xFFA1A4B2),
                        ),
                      ),
                      SizedBox(width: 24 * scale),
                      SvgPicture.asset(
                        'assets/images/headphoneIcon.svg',
                        width: 19 * scale,
                        height: 16 * scale,
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        '34,234 Listening',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.7 * scale,
                          color: const Color(0xFFA1A4B2),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40 * scale),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 0 * scale),
                    height: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  SizedBox(height: 40 * scale),
                  Text(
                    'Related',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeueBold',
                      fontSize: 24 * scale,
                      height: 1.08,
                      color: const Color(0xFFE6E7F2),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildLabeledCard(
                        'assets/images/happycloud.svg',
                        'Night Island',
                        cardWidth: (screenWidth - 2 * horizontalPadding - 20 * scale) / 2,
                      ),
                      buildLabeledCard(
                        'assets/images/happybirds.svg',
                        'Sweet Sleep',
                        cardWidth: (screenWidth - 2 * horizontalPadding - 20 * scale) / 2,
                      ),
                    ],
                  ),
                  SizedBox(height: 40 * scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
