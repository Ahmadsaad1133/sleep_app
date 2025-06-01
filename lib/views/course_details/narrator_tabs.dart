import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/sizes.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
import 'voice_list.dart';

class NarratorTabs extends StatelessWidget {
  const NarratorTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(screenWidth);
    final tabWidth = screenWidth / AppSizes.tabCount;
    final sideInset = (tabWidth - AppSizes.tabIndicatorWidth * scale) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick a Narrator', style: AppTextStyles.sectionHeader(scale)),
        SizedBox(height: AppSizes.sectionSpacing * scale),
        TabBar(
          indicatorPadding: EdgeInsets.zero,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.primaryPurple,
              width: AppSizes.tabIndicatorThickness * scale,
            ),
            insets: EdgeInsets.fromLTRB(sideInset, 0, sideInset, 0),
          ),
          labelColor: AppColors.primaryPurple,
          unselectedLabelColor: AppColors.textGray,
          tabs: [
            Tab(child: Align(alignment: Alignment.centerLeft, child: Text('MALE VOICE', style: AppTextStyles.tabLabel(scale)))),
            Tab(child: Center(child: Text('FEMALE VOICE', style: AppTextStyles.tabLabel(scale)))),
          ],
        ),
        SizedBox(height: AppSizes.tabViewSpacing * scale),
        Container(
          height: AppSizes.tabViewHeight * scale,
          child: const TabBarView(children: [VoiceList(), VoiceList()]),
        ),
      ],
    );
  }
}