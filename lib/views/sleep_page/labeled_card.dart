import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/fonts.dart';
class LabeledCard extends StatelessWidget {
  final String assetPath;
  final String title;
  final String subtitle;
  final double scale;
  final double containersScale;
  final VoidCallback? onTap;
  const LabeledCard({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.scale,
    required this.containersScale,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppSizes.cardWidth * containersScale;
    final double cardHeight = AppSizes.cardHeight * containersScale;
    final double borderRadius = AppSizes.cardBorderRadius * containersScale;
    final double titleFontSize = AppSizes.cardTitleFontSize * scale;
    final double titleLineHeight = AppSizes.cardTitleLineHeight;
    final double subtitleFontSize = AppSizes.cardSubtitleFontSize * scale;
    final double letterSpacing = AppSizes.cardLetterSpacing * scale;
    final double textSpacingBelowImage = AppSizes.verticalSpacingXS * scale;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: textSpacingBelowImage),
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              height: titleLineHeight,
              fontFamily: AppFonts.helveticaRegular,
              color: AppColors.musicPlayerText,
            ),
          ),
          SizedBox(height: AppSizes.horizontalSpacingSmall * scale),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: letterSpacing,
              fontFamily: AppFonts.helveticaRegular,
              color: AppColors.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }
}
