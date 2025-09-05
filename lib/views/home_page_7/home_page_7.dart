import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../Sleep_lognInput_page/sleep_alerts_history_page.dart';
import '../Sleep_lognInput_page/sleep_loginput/sleep_loginput_page_state.dart';
import '../bedtime_page/bedtime_story_page.dart';
import '../groq_service/groq_service.dart';
import '/widgets/navbar.dart';
import '/constants/sizes.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';

import 'notification_button.dart';
import 'home_page_header.dart';
import 'greeting_section.dart';
import 'analysis_promo_card.dart';
import 'bedtime_promo_card.dart';
import 'modern_meditation_card.dart';

class HomePage7 extends StatefulWidget {
  static const routeName = '/home';
  const HomePage7({Key? key}) : super(key: key);

  @override
  State<HomePage7> createState() => _HomePage7State();
}

class _HomePage7State extends State<HomePage7> {
  int _selectedIndex = 0;
  String? aiMessage;
  bool isLoading = true, hasError = false;

  late final PageController _promoController;
  late final PageController _infoController;
  late final PageController _meditationController;

  @override
  void initState() {
    super.initState();
    _promoController = PageController(viewportFraction: .7);
    _infoController = PageController(viewportFraction: .6);
    _meditationController = PageController(viewportFraction: .9);
    _fetchSleepMessage();
  }

  Future<void> _fetchSleepMessage() async {
    try {
      final msg = await GroqService.fetchSleepMessage();
      if (!mounted) return;
      setState(() {
        aiMessage = msg.trim();
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    _infoController.dispose();
    _meditationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: HomePageHeader(scale: (v) => v),
        actions: const [NotificationButton()],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(child: _buildBody()),
          const SizedBox.shrink(),
        ],
      ),
      // <- new unique bottom navbar added here
      bottomNavigationBar: UniqueNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 414).clamp(0.8, 1.2);
    double s(double v) => v * scale;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: s(AppSizes.bodySidePadding)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreetingSection(scale: s),
          SizedBox(height: s(80)),
          _buildDiscoverSection(s),
          SizedBox(height: s(12)),
          _buildPromoCarousel(s),
          SizedBox(height: s(20)),
          SizedBox(height: s(AppSizes.sectionVerticalGap)),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection(double Function(double) s) {
    return Padding(//
      padding: EdgeInsets.only(left: s(4)),
      child: Text(
        'Discover Sleep Tools',
        style: TextStyle(
          fontSize: s(24),
          fontFamily: AppFonts.helveticaBold,
          fontWeight: FontWeight.w600,
          color: Colors.white,//
        ),
      ),
    );
  }


  Widget _buildRecommendedSection(double Function(double) s) {
    return Text(
      AppStrings.recommendedForYou,
      style: TextStyle(
        fontSize: s(24),
        fontFamily: AppFonts.AirbnbCerealBook,
        fontWeight: FontWeight.w300,
        color: AppColors.bodyPrimary,
      ),
    );
  }

  Widget _buildPromoCarousel(double Function(double) s) {
    final cards = [
      AnalysisPromoCard(scale: s),
      BedtimePromoCard(scale: s),
    ];

    return SizedBox(
      height: s(180),
      child: PageView.builder(
        controller: _promoController,
        itemCount: cards.length,
        clipBehavior: Clip.none,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, i) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s(7.5)),  // ← half of 15 px
              child: SizedBox(
                width: s(260),
                child: cards[i],
              ),
            ),
          );
        },
      ),
    );
  }

}

// Moved InfoCardModel to the bottom of the file
class InfoCardModel {
  final String imageAsset;
  final String title;
  final String subtitle;
  final bool isCourse;
  final Color backgroundColor;

  InfoCardModel({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.isCourse,
    required this.backgroundColor,
  });

  factory InfoCardModel.fromFirestore(Map<String, dynamic> data) {
    return InfoCardModel(
      imageAsset: data['imageAsset'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      isCourse: data['isCourse'] ?? false,
      backgroundColor: _parseColor(data['backgroundColor']),
    );
  }

  // Helper function to parse color string from Firestore
  static Color _parseColor(String? hexColor) {
    try {
      if (hexColor != null && hexColor.startsWith('0x')) {
        return Color(int.parse(hexColor));
      }
    } catch (_) {}
    return Colors.grey; // Default color if parsing fails
  }
}


// =====================
// UniqueNavBar widget — minimal "2025" floating style (solid, no transparency)
// =====================

class UniqueNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const UniqueNavBar({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final horizontalMargin = width * 0.06;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalMargin, 12, horizontalMargin, 16),
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: 100, // extra room so the floating button doesn't clip and labels fit
            child: Stack(
              alignment: Alignment.center,
              children: [
                // background slab anchored to the bottom with internal top padding
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.only(top: 26), // space for the floating button
                    decoration: BoxDecoration(
                      color: Colors.white, // solid background (no transparency)
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    // place label(s) inside the slab so they are never occluded by the floating button
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // single centered label for now
                      ],
                    ),
                  ),
                ),

                // Center circular elevated home button — positioned to visually float above the slab
                Positioned(
                  top: 6,
                  child: _CenterNavButton(
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavButton({Key? key, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sleep-app friendly design: soft gradient, crescent-bed icon, halo glow
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutQuad,
        width: isSelected ? 78 : 72,
        height: isSelected ? 78 : 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.85),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.26),
              blurRadius: isSelected ? 26 : 20,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.8),
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // soft halo behind the icon
                Positioned(
                  child: Container(
                    width: isSelected ? 44 : 40,
                    height: isSelected ? 44 : 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(isSelected ? 0.06 : 0.04),
                    ),
                  ),
                ),

                // main icon: bedtime glyph (crescent + star) for sleep apps
                Icon(
                  Icons.bedtime_rounded,
                  size: isSelected ? 36 : 32,
                  color: Colors.white,
                ),

                // small sparkle to the top-right for personality
                Positioned(
                  right: isSelected ? 14 : 13,
                  top: isSelected ? 12 : 13,
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.9,
                    child: Icon(
                      Icons.star_rounded,
                      size: isSelected ? 10 : 9,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
