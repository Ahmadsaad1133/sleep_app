import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SleepMusicPage extends StatefulWidget {
  final ValueNotifier<bool> onNavbarVisibilityChange;

  const SleepMusicPage({
    Key? key,
    required this.onNavbarVisibilityChange,
  }) : super(key: key);

  @override
  _SleepMusicPageState createState() => _SleepMusicPageState();
}

class _SleepMusicPageState extends State<SleepMusicPage> {
  @override
  void initState() {
    super.initState();
    widget.onNavbarVisibilityChange.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    double scale;
    if (w <= 300) {
      scale = 0.6;
    } else if (w <= 360) {
      scale = 0.75;
    } else if (w <= 414) {
      scale = 0.9;
    } else if (w <= 600) {
      scale = 1.05;
    } else if (w <= 900) {
      scale = 1.25;
    } else {
      scale = 1.45;
    }

    final cardScale = scale * 1.10;

    Widget buildCard(String asset, String title1, String title2) {
      return SizedBox(
        width: 177 * cardScale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 177 * cardScale,
              height: 122 * cardScale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * cardScale),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10 * cardScale),
                child: SvgPicture.asset(
                  asset,
                  width: 177 * cardScale,
                  height: 122 * cardScale,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8 * cardScale),
            Text(
              title1,
              style: TextStyle(
                fontSize: 18 * cardScale,
                height: 1.08,
                color: const Color(0xFFE6E7F2),
                fontFamily: 'HelveticaNeueBold',
              ),
            ),
            SizedBox(height: 4 * cardScale),
            Text(
              title2,
              style: TextStyle(
                fontSize: 11 * cardScale,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.55 * cardScale,
                color: const Color(0xFF98A1BD),
                fontFamily: 'HelveticaNeueRegular',
              ),
            ),
          ],
        ),
      );
    }

    Widget buildCardWithBackground(
        String backgroundAsset,
        String title1,
        String title2,
        ) {
      return SizedBox(
        width: 177 * cardScale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 177 * cardScale,
              height: 122 * cardScale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * cardScale),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10 * cardScale),
                child: SvgPicture.asset(
                  backgroundAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8 * cardScale),
            Text(
              title1,
              style: TextStyle(
                fontSize: 18 * cardScale,
                height: 1.08,
                color: const Color(0xFFE6E7F2),
                fontFamily: 'HelveticaNeueBold',
              ),
            ),
            SizedBox(height: 4 * cardScale),
            Text(
              title2,
              style: TextStyle(
                fontSize: 11 * cardScale,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.55 * cardScale,
                color: const Color(0xFF98A1BD),
                fontFamily: 'HelveticaNeueRegular',
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF03174C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/images/NavigateLeft.svg',
                        width: 55,
                        height: 55,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Sleep Music',
                          style: TextStyle(
                            fontSize: 24 * scale,
                            fontFamily: 'HelveticaNeueBold',
                            height: 1.08,
                            color: const Color(0xFFE6E7F2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 55),
                  ],
                ),
              ),
              SizedBox(height: 50 * scale),
              for (int i = 0; i < 4; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (i == 1)
                      buildCardWithBackground(
                        'assets/images/bowlmoon.svg',
                        'Good Night',
                        '45 MIN   SLEEP MUSIC',
                      )
                    else if (i == 2)
                      buildCard(
                        'assets/images/happybirds.svg',
                        'Sweet Sleep',
                        '45 MIN   SLEEP MUSIC',
                      )
                    else
                      buildCard(
                        'assets/images/happycloud.svg',
                        'Night Island',
                        '45 MIN   SLEEP MUSIC',
                      ),
                    if (i == 1)
                      buildCard(
                        'assets/images/happycloud2.svg',
                        'Moon Clouds',
                        '45 MIN   SLEEP MUSIC',
                      )
                    else if (i == 2)
                      buildCard(
                        'assets/images/happycloud.svg',
                        'Night Island',
                        '45 MIN   SLEEP MUSIC',
                      )
                    else
                      buildCard(
                        'assets/images/happybirds.svg',
                        'Sweet Sleep',
                        '45 MIN   SLEEP MUSIC',
                      ),
                  ],
                ),
                SizedBox(height: 30 * scale),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
