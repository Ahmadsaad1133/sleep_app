// lib/pages/page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/sizes.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';
import 'narrator_tabs.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(screenWidth);
    final topPadding = MediaQuery.of(context).padding.top;

    return DefaultTabController(
      length: AppSizes.tabCount,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: AppSizes.headerImageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SvgPicture.asset(
                      AppAssets.courseHeader,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: topPadding + AppSizes.headerIconPadding * scale,
                      left: AppSizes.headerIconPadding * scale,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          AppAssets.backButton,
                          width: AppSizes.headerIconSize * scale,
                          height: AppSizes.headerIconSize * scale,
                        ),
                      ),
                    ),
                    Positioned(
                      top: topPadding + AppSizes.headerIconPadding * scale,
                      right: AppSizes.headerIconPadding * scale,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: SvgPicture.asset(
                              AppAssets.heartButton,
                              width: AppSizes.headerIconSize * scale,
                              height: AppSizes.headerIconSize * scale,
                            ),
                          ),
                          SizedBox(width: AppSizes.headerIconSpacing * scale),
                          InkWell(
                            onTap: () {},
                            child: SvgPicture.asset(
                              AppAssets.downloadButton,
                              width: AppSizes.headerIconSize * scale,
                              height: AppSizes.headerIconSize * scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizes.contentSpacing * scale),
                    Text(AppStrings.courseTitle, style: AppTextStyles.title(scale)),
                    SizedBox(height: AppSizes.titleSpacing * scale),
                    Text(AppStrings.courseLabel, style: AppTextStyles.label(scale)),
                    SizedBox(height: AppSizes.labelSpacing * scale),
                    Text(AppStrings.courseDescription, style: AppTextStyles.description(scale)),
                    SizedBox(height: AppSizes.sectionSpacing * scale),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.heartIcon,
                          width: AppSizes.iconSmall * scale,
                          height: AppSizes.iconSmall * scale,
                        ),
                        SizedBox(width: AppSizes.iconTextSpacing * scale),
                        Text('24,234 Favorites', style: AppTextStyles.info(scale)),
                        SizedBox(width: AppSizes.infoSpacing * scale),
                        SvgPicture.asset(
                          AppAssets.headphoneIcon,
                          width: AppSizes.iconSmall * scale,
                          height: AppSizes.iconSmall * scale,
                        ),
                        SizedBox(width: AppSizes.iconTextSpacing * scale),
                        Text('34,234 Listening', style: AppTextStyles.info(scale)),
                      ],
                    ),
                    SizedBox(height: AppSizes.sectionSpacing * scale),
                    const NarratorTabs(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
