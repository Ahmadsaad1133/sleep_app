import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/strings.dart';
class MusicCard extends StatelessWidget {
  final String asset;
  final String title;
  final String subtitle;
  final double cardScale;
  final bool useBackground;
  final VoidCallback? onTap;
  const MusicCard({
    Key? key,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.cardScale,
    this.useBackground = false,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double width = AppSizes.cardBaseWidth * cardScale;
    final double height = AppSizes.cardBaseHeight * cardScale;
    final double radius = AppSizes.cardRadius * cardScale;

    final Widget svgWidget = SvgPicture.asset(
      asset,
      fit: BoxFit.cover,
      width: useBackground ? null : width,
      height: useBackground ? null : height,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: useBackground ? null : Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: svgWidget,
              ),
            ),
            SizedBox(height: AppSizes.cardPadTop * cardScale),
            Text(
              title,
              style: AppTextStyles.cardTitle(cardScale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.cardSubtitleGap * cardScale),
            Text(
              subtitle,
              style: AppTextStyles.cardSubtitle(cardScale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
