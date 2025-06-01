import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/views/meditate_Page/page.dart';
import '/views/music_page/music_page.dart';
import '/views/profile_Page/page.dart';
import '/views/welcome_sleep/page.dart';
import '/widgets/navbar.dart';
import '/constants/sizes.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';
import '/views/home_page_7/info_card.dart';
import '/views/home_page_7/horizontal_item.dart';
import '/views/home_page_7/daily_thought_card.dart';
class HomePage7 extends StatefulWidget {
  const HomePage7({Key? key}) : super(key: key);

  @override
  State<HomePage7> createState() => _HomePage7State();
}

class _HomePage7State extends State<HomePage7> {
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeSleepPage()),
      );
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SafeArea(child: _buildBody()),
      const MeditatePage(),
      const SizedBox.shrink(),
      const MusicPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    final w = MediaQuery.of(context).size.width;
    const base = 414.0;
    final scale = (w / base).clamp(0.8, 1.2);
    double s(double v) => v * scale;

    final imageWidth = s(AppSizes.svgW_Med);
    final imageHeight = s(AppSizes.svgH_Med);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: s(AppSizes.bodySidePadding)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: s(AppSizes.sectionVerticalGap)),
          _buildHeader(s),
          Padding(
            padding: EdgeInsets.only(top: s(30)), // 20px top padding
            child: Text(
              AppStrings.homeHeaderText2,
              style: TextStyle(
                fontSize: s(24),
                fontFamily: AppFonts.helveticaBold,
                fontWeight: AppFonts.light,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: s(8)),
          Text(
            AppStrings.homeHeaderDiscription,
            style: TextStyle(
              fontSize: s(18),
              fontFamily: AppFonts.helveticaRegular,
              fontWeight: AppFonts.light,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),

          SizedBox(height: s(AppSizes.sectionVerticalGap)),

          Row(
            children: [
              InfoCard(
                backgroundColor: AppColors.basicsBg,
                imageAsset: AppAssets.appleIllustration,
                title: AppStrings.basicsTitle,
                subtitle: AppStrings.courseLabel2,
                isCourse: true,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
              SizedBox(width: s(AppSizes.cardSpacing)),
              InfoCard(
                backgroundColor: AppColors.relaxationBg,
                imageAsset: AppAssets.womanIllustration,
                title: AppStrings.relaxationTitle,
                subtitle: AppStrings.musicLabel,
                isCourse: false,
                titleColor: AppColors.relaxationTitleColor,
                subtitleColor: AppColors.relaxationSubtitleColor,
                timeTextColor: AppColors.timeTextBlack,
                buttonBgColor: AppColors.startBtnBgInverse,
                buttonTextColor: AppColors.startBtnTextInverse,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
            ],
          ),

          SizedBox(height: s(20)),
          const DailyThoughtCard(),
          SizedBox(height: s(20)),

          Text(
            AppStrings.recommendedForYou,
            style: TextStyle(
              fontSize: s(24),
              fontFamily: AppFonts.helveticaRegular,
              fontWeight: AppFonts.light,
              color: AppColors.bodyPrimary,
            ),
          ),
          SizedBox(height: s(15)),

          SizedBox(
            height: s(200),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (_, i) => HorizontalItem(i),
            ),
          ),
          SizedBox(height: s(AppSizes.sectionVerticalGap)),
        ],
      ),
    );
  }

  Widget _buildHeader(double Function(double) s) {
    final logoSize = s(AppSizes.headerIconSize * 0.8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.homeSilent,
          style: TextStyle(
            fontSize: s(16),
            fontFamily: AppFonts.helveticaBold,
            fontWeight: AppFonts.light,
            letterSpacing: 3.84 * s(1),
            color: AppColors.bodyPrimary,
          ),
        ),
        SizedBox(width: s(AppSizes.iconTextSpacing)),
        SvgPicture.asset(
          AppAssets.homeIcon,
          width: logoSize,
          height: logoSize,
        ),
        SizedBox(width: s(AppSizes.iconTextSpacing)),
        Text(
          AppStrings.homeMoon,
          style: TextStyle(
            fontSize: s(16),
            fontFamily: AppFonts.helveticaBold,
            fontWeight: AppFonts.light,
            letterSpacing: 3.84 * s(1),
            color: AppColors.bodyPrimary,
          ),
        ),
      ],
    );
  }
}
