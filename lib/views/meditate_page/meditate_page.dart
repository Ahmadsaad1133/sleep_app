// lib/views/meditate_page/meditate_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/views/home_page_7/home_page_7.dart';
import '/views/music_v2/music_v2_page.dart';

class MeditatePage extends StatefulWidget {
  const MeditatePage({Key? key}) : super(key: key);

  @override
  State<MeditatePage> createState() => _MeditatePageState();
}

class _MeditatePageState extends State<MeditatePage> {
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

  void _onCategoryTapped(int index) {
    if (index == _categoryIndex) return;
    setState(() => _categoryIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
            final padding = 24.0 * scale;

            return SingleChildScrollView(
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
                    padding: EdgeInsets.only(left: padding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final label = entry.value;
                          final isActive = idx == _categoryIndex;
                          return Padding(
                            padding: EdgeInsets.only(right: 16 * scale),
                            child: GestureDetector(
                              onTap: () => _onCategoryTapped(idx),
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
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 18 * scale,
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
                  ),

                  SizedBox(height: 30 * scale),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10 * scale),
                      child: Container(
                        width: w - padding * 2,
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
                              padding: EdgeInsets.only(
                                left: 25 * scale,
                                right: 16 * scale,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Calm',
                                    style: TextStyle(
                                      fontSize: 18 * scale,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'HelveticaNeueBold',
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5 * scale),
                                  Text(
                                    'APR 30  PAUSE PRACTICE',
                                    style: TextStyle(
                                      fontSize: 11 * scale,
                                      fontFamily: 'HelveticaNeueRegular',
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MusicV2Page()),
                            );
                          },
                          child: _MeditationTile(
                            imageAsset: 'assets/images/calm.svg',
                            title: '7 Days of Calm',
                            scale: scale,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MusicV2Page()),
                            );
                          },
                          child: _MeditationTile(
                            imageAsset: 'assets/images/anxiet.svg',
                            title: 'Anxiety Release',
                            scale: scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MeditationTile extends StatelessWidget {
  final String imageAsset;
  final String title;
  final double scale;

  const _MeditationTile({
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
