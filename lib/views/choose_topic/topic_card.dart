// lib/widgets/topic_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';

class TopicCard extends StatelessWidget {
  final double scale;
  final Color backgroundColor;
  final String? svgAsset;
  final double? svgWidth;
  final double? svgHeight;
  final bool noPaddingTop;
  final List<Widget>? extraTopWidgets;
  final String? label;
  final Widget? customLabel;
  final VoidCallback? onTap;

  const TopicCard({
    Key? key,
    required this.scale,
    required this.backgroundColor,
    this.svgAsset,
    this.svgWidth,
    this.svgHeight,
    this.noPaddingTop = false,
    this.extraTopWidgets,
    this.label,
    this.customLabel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = AppSizes.cardW * scale;
    final double height = AppSizes.cardH_Large * scale;
    final BorderRadius borderRadius =
    BorderRadius.circular(AppSizes.cardRadius * scale);

    return Material(
      color: backgroundColor,
      elevation: 4.0,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.cardPadH * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!noPaddingTop)
                SizedBox(height: AppSizes.cardPadTop * scale),

              if (svgAsset != null)
                Center(
                  child: SvgPicture.asset(
                    svgAsset!,
                    width: svgWidth,
                    height: svgHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              if (extraTopWidgets != null)
                ...extraTopWidgets!.map(
                      (w) => Padding(
                    padding: EdgeInsets.only(top: AppSizes.cardPadTop * scale),
                    child: w,
                  ),
                ),
              const Spacer(),
              if (customLabel != null)
                Padding(
                  padding:
                  EdgeInsets.only(bottom: AppSizes.cardPadBottom * scale),
                  child: DefaultTextStyle(
                    style: AppTextStyles.cardDefaultLabel(scale),
                    child: customLabel!,
                  ),
                )
              else if (label != null)
                Padding(
                  padding:
                  EdgeInsets.only(bottom: AppSizes.cardPadBottom * scale),
                  child: Text(
                    label!,
                    style: AppTextStyles.cardDefaultLabel(scale),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
