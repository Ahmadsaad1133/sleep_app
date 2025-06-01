import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../reminders/page.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/strings.dart';
import '/constants/fonts.dart';
import 'topic_card.dart';

class ChooseTopicPage extends StatelessWidget {
  const ChooseTopicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(screenWidth);
    final allTopicCards = <Widget>[
      TopicCard(
        scale: scale,
        backgroundColor: AppColors.reduceStress,
        svgAsset: AppStrings.widget1,
        svgWidth: AppSizes.svgW_Med * scale,
        svgHeight: AppSizes.svgH_Large * scale,
        noPaddingTop: true,
        customLabel: Text(
          AppStrings.reduceStress,
          style: AppTextStyles.cardCustomLabel(scale).copyWith(
            color: AppColors.onPrimaryLight,
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderPage()),
        ),
      ),
      TopicCard(
        scale: scale,
        backgroundColor: AppColors.improvePerformance,
        extraTopWidgets: [
          SvgPicture.asset(
            AppStrings.widget2,
            width: AppSizes.svgW_Widget2 * scale,
            height: AppSizes.svgH_XSmall * scale,
            fit: BoxFit.contain,
          ),
        ],
        customLabel: Text(
          AppStrings.improvePerformance,
          style: AppTextStyles.cardCustomLabel(scale).copyWith(
            color: AppColors.onPrimaryLight,
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderPage()),
        ),
      ),
      TopicCard(
        scale: scale,
        backgroundColor: AppColors.increaseHappiness,
        extraTopWidgets: [
          SvgPicture.asset(
            AppStrings.widget3,
            width: AppSizes.svgW_Large * scale,
            height: AppSizes.svgH_Small * scale,
            fit: BoxFit.contain,
          ),
        ],
        customLabel: Text(
          AppStrings.increaseHappiness,
          style: AppTextStyles.cardCustomLabel(scale).copyWith(
            color: AppColors.onLightBg,
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderPage()),
        ),
      ),
      TopicCard(
        scale: scale,
        backgroundColor: AppColors.reduceAnxiety,
        extraTopWidgets: [
          SvgPicture.asset(
            AppStrings.widget4,
            width: AppSizes.svgW_Widget4 * scale,
            height: AppSizes.svgH_Med * scale,
            fit: BoxFit.contain,
          ),
        ],
        customLabel: Text(
          AppStrings.reduceAnxiety,
          style: AppTextStyles.cardDefaultLabel(scale).copyWith(
            color: AppColors.onLightBg,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderPage()),
        ),
      ),
      TopicCard(
        scale: scale,
        backgroundColor: AppColors.personalGrowth,
        extraTopWidgets: [
          SvgPicture.asset(
            AppStrings.widget5,
            width: AppSizes.svgW_Large * scale,
            height: AppSizes.svgH_Widget5 * scale,
            fit: BoxFit.contain,
          ),
        ],
        customLabel: Text(
          AppStrings.personalGrowth,
          style: AppTextStyles.cardDefaultLabel(scale),
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderPage()),
        ),
      ),
      TopicCard(
        scale: scale,
        backgroundColor: AppColors.betterSleep,
        extraTopWidgets: [
          SvgPicture.asset(
            AppStrings.widget6,
            width: AppSizes.svgW_Large * scale,
            height: AppSizes.svgH_XSmall * scale,
            fit: BoxFit.contain,
          ),
        ],
        customLabel: Text(
          AppStrings.betterSleep,
          style: AppTextStyles.cardCustomLabel(scale).copyWith(
            color: AppColors.onDarkBg,
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderPage()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: AppSizes.topFrameOffset * scale),
              child: SvgPicture.asset(
                AppStrings.bgFrame,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH * scale,
                vertical: AppSizes.pagePaddingV * scale,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.titleLine1,
                      style: AppTextStyles.heading(scale),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.titleGap * scale),
                    Text(
                      AppStrings.titleLine2,
                      style: AppTextStyles.subheading(scale).copyWith(letterSpacing: 2),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSizes.subtitleGap * scale),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.chooseTopicHint,
                        style: AppTextStyles.sectionLabel(scale),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: AppSizes.sectionGap * scale),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSizes.cardSpacing * scale,
                      mainAxisSpacing: AppSizes.cardSpacing * scale,
                      childAspectRatio: 0.8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: allTopicCards,
                    ),
                    SizedBox(height: AppSizes.pagePaddingV * scale),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
