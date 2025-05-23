import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/views/home_page_7/home_page_7.dart';

class MeditatePage extends StatefulWidget {
  const MeditatePage({Key? key}) : super(key: key);

  @override
  State<MeditatePage> createState() => _MeditatePageState();
}

class _MeditatePageState extends State<MeditatePage> {
  int _navIndex = 1;
  int _categoryIndex = 0;

  final List<String> _categories = [
    'All', 'My', 'Anxious', 'Sleep', 'Kids',
    'Calm', 'Peace', 'Clear', 'Balance',
    'Empty', 'Zen', 'Still', 'Clarity',
  ];

  final List<String> _icons = [
    'assets/images/all.svg',
    'assets/images/my.svg',
    'assets/images/anxious.svg',
    'assets/images/sleep.svg',
    'assets/images/kids.svg',
  ];

  void _onNavTapped(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage7()),
      );
    }
  }

  void _onCategoryTapped(int index) {
    if (index == _categoryIndex) return;
    setState(() => _categoryIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;

          double scale;
          if (w <= 300) {
            scale = 0.65;
          } else if (w <= 360) {
            scale = 0.8;
          } else if (w <= 414) {
            scale = 0.95;
          } else if (w <= 600) {
            scale = 1.1;
          } else if (w <= 900) {
            scale = 1.3;
          } else {
            scale = 1.5;
          }

          final horizontalPadding = 24.0 * scale;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50 * scale),
                  Center(
                    child: Text(
                      'Meditate',
                      style: TextStyle(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HelveticaNeueBold',
                        color: const Color(0xFF3F414E),
                      ),
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Center(
                    child: Text(
                      'we can learn how to recognize when our minds\nare doing their normal everyday acrobatics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        fontFamily: 'HelveticaNeueRegular',
                        color: const Color(0xFFA0A3B1),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final label = entry.value;
                              final isActive = idx == _categoryIndex;
                              return GestureDetector(
                                onTap: () => _onCategoryTapped(idx),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16 * scale),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 70 * scale,
                                        height: 70 * scale,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFF8E97FD)
                                              : const Color(0xFFA0A3B1),
                                          borderRadius: BorderRadius.circular(28 * scale),
                                        ),
                                        child: Center(
                                          child: idx < _icons.length
                                              ? SvgPicture.asset(
                                            _icons[idx],
                                            width: 28 * scale,
                                            height: 28 * scale,
                                            color: Colors.white,
                                          )
                                              : null,
                                        ),
                                      ),
                                      SizedBox(height: 8 * scale),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 18 * scale,
                                          fontFamily: 'HelveticaNeueRegular',
                                          fontWeight: FontWeight.w400,
                                          color: isActive
                                              ? const Color(0xFF3F414E)
                                              : const Color(0xFFA0A3B1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 30 * scale),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10 * scale),
                            child: Container(
                              width: w - horizontalPadding * 2,
                              height: 95 * scale,
                              color: const Color(0xFFFEE6C6),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: SvgPicture.asset(
                                      'assets/images/frame105.svg',
                                      width: 98 * scale,
                                      height: 95 * scale,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: SvgPicture.asset(
                                      'assets/images/frame107.svg',
                                      width: 184 * scale,
                                      height: 69 * scale,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 155 * scale,
                                    child: SvgPicture.asset(
                                      'assets/images/frame106.svg',
                                      width: 64 * scale,
                                      height: 25 * scale,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 25 * scale, right: 16 * scale),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Calm',
                                          style: TextStyle(
                                            fontSize: 18 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontFamily: 'HelveticaNeueBold',
                                          ),
                                        ),
                                        SizedBox(height: 5 * scale),
                                        Text(
                                          'APR 30  PAUSE PRACTICE',
                                          style: TextStyle(
                                            fontSize: 11 * scale,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                            fontFamily: 'HelveticaNeueRegular',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 30 * scale),
                                      child: Container(
                                        width: 44 * scale,
                                        height: 44 * scale,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3F414E),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Color(0xFFF0F1F2),
                                            size: 26,
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
                        SizedBox(height: 30 * scale),

                        // Two cards row with both texts inside and aligned top
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: (w - horizontalPadding * 2 - 16 * scale) / 2,
                              height: 210 * scale,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10 * scale),
                                child: Stack(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/calm.svg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      bottom: 12 * scale,
                                      left: 12 * scale,
                                      child: Text(
                                        '7 Days of Calm',
                                        style: TextStyle(
                                          fontSize: 18 * scale,
                                          fontFamily: 'HelveticaNeueBold',
                                          fontWeight: FontWeight.w700,
                                          height: 1.08,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: (w - horizontalPadding * 2 - 16 * scale) / 2,
                              height: 167 * scale,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10 * scale),
                                child: Stack(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/anxiet.svg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      bottom: 12 * scale,
                                      left: 12 * scale,
                                      child: Text(
                                        'Anxiet Release',
                                        style: TextStyle(
                                          fontSize: 18 * scale,
                                          fontFamily: 'HelveticaNeueBold',
                                          fontWeight: FontWeight.w700,
                                          height: 1.08,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30 * scale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          double scale;
          if (w <= 300) {
            scale = 0.7;
          } else if (w <= 360) {
            scale = 0.85;
          } else if (w <= 414) {
            scale = 1.0;
          } else if (w <= 600) {
            scale = 1.2;
          } else if (w <= 900) {
            scale = 1.4;
          } else {
            scale = 1.6;
          }

          final navBarHeight = 112 * scale;

          return Container(
            height: navBarHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem('assets/images/homeIcon.svg', 'Home', 0, scale),
                _buildNavItem('assets/images/sleepIcon.svg', 'Meditate', 1, scale),
                _buildNavItem('assets/images/meditateIcon.svg', 'Sleep', 2, scale),
                _buildNavItem('assets/images/musicIcon.svg', 'Music', 3, scale),
                _buildNavItem('assets/images/profileIcon.svg', 'Profile', 4, scale),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(String asset, String label, int index, double scale) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46 * scale,
            height: 46 * scale,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8E97FD) : Colors.transparent,
              borderRadius: BorderRadius.circular(18 * scale),
            ),
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: (isSelected ? 23 : 21) * scale,
                height: 22 * scale,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * scale,
              fontFamily: 'HelveticaNeueRegular',
              fontWeight: FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF8E97FD)
                  : const Color(0xFFA0A3B1),
            ),
          ),
        ],
      ),
    );
  }
}

