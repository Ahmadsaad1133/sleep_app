import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375 * 0.8;
    final tabWidth = screenWidth / 2;
    final sideInset = (tabWidth - 46 * scale) / 2;
    final topPadding = MediaQuery.of(context).padding.top;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 288,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  SvgPicture.asset(
                    'assets/images/sun.svg',
                    width: double.infinity,
                    height: 288,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
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
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPadding + 16,
                    right: 16,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: SvgPicture.asset(
                            'assets/images/heart.svg',
                            width: 55 * scale,
                            height: 55 * scale,
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        InkWell(
                          onTap: () {},
                          child: SvgPicture.asset(
                            'assets/images/download.svg',
                            width: 55 * scale,
                            height: 55 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                left: 20 * scale,
                top: 10 * scale,
                right: 20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Happy Morning',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeueBold',
                      fontSize: 34 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Text(
                    'COURSE',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      height: 1.08,
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
                        '24.234 Favorites',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.08,
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
                        '34.234 Listening',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.08,
                          letterSpacing: 0.7 * scale,
                          color: const Color(0xFFA1A4B2),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30 * scale),
                  Text(
                    'Pick a Narrator',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                      color: const Color(0xFF3F414E),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  TabBar(
                    indicatorPadding: EdgeInsets.zero,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: const Color(0xFF6C63FF),
                        width: 3 * scale,
                      ),
                      insets: EdgeInsets.fromLTRB(
                        sideInset,
                        0,
                        sideInset,
                        0,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: const Color(0xFF6C63FF),
                    unselectedLabelColor: const Color(0xFFB0B0B0),
                    tabs: [
                      Tab(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10 * scale),
                          child: Text(
                            'MALE VOICE',
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w400,
                              height: 1.08,
                              letterSpacing: 0.8 * scale,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'FEMALE VOICE',
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w400,
                              height: 1.08,
                              letterSpacing: 0.8 * scale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  VoiceList(),
                  VoiceList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceList extends StatelessWidget {
  const VoiceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375 * 0.8;

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 16 * scale,
        horizontal: 20 * scale,
      ),
      children: const [
        ListItem(title: 'Focus Attention', minutes: 10),
        ListItem(title: 'Body Scan', minutes: 5),
        ListItem(title: 'Making Happiness', minutes: 3),
      ],
    );
  }
}

class ListItem extends StatelessWidget {
  final String title;
  final int minutes;
  const ListItem({
    Key? key,
    required this.title,
    required this.minutes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375 * 0.8;

    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Row(
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1 * scale,
              ),
            ),
            child: Icon(
              Icons.play_arrow,
              size: 24 * scale,
              color: const Color(0xFF6C63FF),
            ),
          ),
          SizedBox(width: 16 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3F414E),
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                '$minutes MIN',
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
