import 'dart:math';
import 'package:first_flutter_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/views/course_details/course_details_page.dart';
import '/views/meditate_Page/meditate_page.dart';

class HomePage7 extends StatefulWidget {
  const HomePage7({Key? key}) : super(key: key);

  @override
  State<HomePage7> createState() => _HomePage7State();
}

class _HomePage7State extends State<HomePage7> {
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- scaling helpers ---
    final screenWidth = MediaQuery.of(context).size.width;
    const double baseWidth = 414;
    final double rawScale = screenWidth / baseWidth;
    final double scale = rawScale.clamp(0.8, 1.2);

    double getFontSize(double baseSize) => baseSize * scale;
    double getSize(double baseSize) => baseSize * scale;

    // --- reusable card builder ---
    Widget buildCard({
      required Color backgroundColor,
      required String imageAsset,
      required String title,
      required String subtitle,
      required bool isCourse,
      Color titleColor = const Color(0xFFFFECCC),
      Color subtitleColor = const Color(0xFFF7E8D0),
      Color timeTextColor = const Color(0xFFEBEAEC),
      Color buttonBgColor = Colors.white,
      Color buttonTextColor = const Color(0xFF3F414E),
      double? imageWidth,
      double? imageHeight,
    }) {
      final double buttonWidth = screenWidth < 360
          ? getSize(70)
          : screenWidth > 600
          ? getSize(110)
          : getSize(90);
      final double buttonHeight = getSize(35);

      return Container(
        width: (screenWidth - getSize(20 * 2 + 12)) / 2,
        height: getSize(210),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(getSize(10)),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(getSize(10)),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SvgPicture.asset(
                  imageAsset,
                  width: imageWidth ?? getSize(120),
                  height: imageHeight ?? getSize(105),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: getSize(120),
                left: getSize(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: getFontSize(18),
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: getSize(5)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: getFontSize(11),
                        fontWeight: FontWeight.w400,
                        height: 1.08,
                        letterSpacing: 0.05 * getFontSize(11),
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: getSize(16),
                left: getSize(16),
                right: getSize(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3-10 MIN',
                      style: TextStyle(
                        fontSize: getFontSize(11),
                        fontWeight: FontWeight.w400,
                        height: 1.08,
                        letterSpacing: 0.05 * getFontSize(11),
                        color: timeTextColor,
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: isCourse
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CourseDetailsPage(),
                            ),
                          );
                        }
                            : null,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'start',
                            style: TextStyle(
                              fontSize: getFontSize(10),
                              fontWeight: FontWeight.w400,
                              height: 1.08,
                              letterSpacing: 0.05 * getFontSize(10),
                              color: buttonTextColor,
                            ),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(buttonBgColor),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(getSize(25)),
                            ),
                          ),
                          elevation: MaterialStateProperty.all(0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- horizontal list item builder ---
    Widget buildHorizontalItem(int index) {
      final svgAsset = index == 0
          ? 'assets/images/container1.svg'
          : 'assets/images/container2.svg';
      final title = index == 0 ? 'Focus' : 'Happiness';
      final subtitle = 'MEDITATION   3-10 MIN';

      return ClipRRect(
        borderRadius: BorderRadius.circular(getSize(8)),
        child: Container(
          width: getSize(162),
          height: getSize(161),
          margin: EdgeInsets.only(right: getSize(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                svgAsset,
                width: getSize(162),
                height: getSize(113),
                fit: BoxFit.cover,
              ),
              SizedBox(height: getSize(8)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getSize(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: getFontSize(18),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HelveticaNeueBold',
                        color: const Color(0xFF3F414E),
                      ),
                    ),
                    SizedBox(height: getSize(6)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: getFontSize(11),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeueRegular',
                        letterSpacing: 0.05 * getFontSize(11),
                        color: const Color(0xFFA1A4B2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- the “home” screen widget inlined ---
    final Widget homeScreen = SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getSize(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getSize(50)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Silent',
                    style: TextStyle(
                      fontSize: getFontSize(16),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3.84 * scale,
                    ),
                  ),
                  SizedBox(width: getSize(8)),
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: getSize(30),
                    height: getSize(30),
                  ),
                  SizedBox(width: getSize(8)),
                  Text(
                    'Moon',
                    style: TextStyle(
                      fontSize: getFontSize(16),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3.84 * scale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: getSize(30)),
              Text(
                'Good Morning, Afsar',
                style: TextStyle(
                  fontSize: getFontSize(28),
                  fontFamily: 'HelveticaNeueBold',
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3F414E),
                ),
              ),
              SizedBox(height: getSize(10)),
              Text(
                'We wish you have a good day',
                style: TextStyle(
                  fontSize: getFontSize(24),
                  fontFamily: 'HelveticaNeueRegular',
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
              SizedBox(height: getSize(20)),
              Row(
                children: [
                  buildCard(
                    backgroundColor: const Color(0xFF8E97FD),
                    imageAsset: 'assets/images/apple.svg',
                    title: 'Basics',
                    subtitle: 'COURSE',
                    isCourse: true,
                  ),
                  SizedBox(width: getSize(12)),
                  buildCard(
                    backgroundColor: const Color(0xFFFFC97E),
                    imageAsset: 'assets/images/woman.svg',
                    title: 'Relaxation',
                    subtitle: 'MUSIC',
                    isCourse: false,
                    titleColor: Colors.black,
                    subtitleColor: Colors.black,
                    timeTextColor: Colors.black,
                    buttonBgColor: Colors.black,
                    buttonTextColor: Colors.white,
                    imageWidth: 199,
                    imageHeight: 200,
                  ),
                ],
              ),
              SizedBox(height: getSize(20)),
              // Daily Thought
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(getSize(10)),
                  child: Container(
                    width: getSize(374),
                    height: getSize(95),
                    color: const Color(0xFF333242),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: SvgPicture.asset(
                            'assets/images/dailyframe1.svg',
                            width: getSize(98),
                            height: getSize(95),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: SvgPicture.asset(
                            'assets/images/dailyframe2.svg',
                            width: getSize(184),
                            height: getSize(69),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: getSize(155),
                          child: SvgPicture.asset(
                            'assets/images/dailyframe3.svg',
                            width: getSize(64),
                            height: getSize(58),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding:
                          EdgeInsets.only(left: getSize(25), right: getSize(16)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Thought',
                                style: TextStyle(
                                  fontSize: getFontSize(18),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'HelveticaNeueBold',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: getSize(5)),
                              Text(
                                'MEDITATION 3-10 MIN',
                                style: TextStyle(
                                  fontSize: getFontSize(11),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeueRegular',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: getSize(30)),
                            child: Container(
                              width: getSize(40),
                              height: getSize(40),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                  size: getSize(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: getSize(20)),
              Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: getFontSize(24),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF3F414E),
                  fontFamily: 'HelveticaNeueRegular',
                ),
              ),
              SizedBox(height: getSize(15)),
              SizedBox(
                height: getSize(200),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  padding: EdgeInsets.only(right: getSize(20)),
                  itemBuilder: (context, index) => buildHorizontalItem(index),
                ),
              ),
              SizedBox(height: getSize(40)),
            ],
          ),
        ),
      ),
    );

    // --- all pages for the navbar ---
    final pages = [
      homeScreen,
      const MeditatePage(),
      // add more pages here if you have more tabs
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: CustomNavbar(
          selectedIndex: _selectedIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }
}
