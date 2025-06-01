import 'package:flutter/material.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/colors.dart';

class VoiceList extends StatelessWidget {
  const VoiceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(screenWidth);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.voiceListVerticalPadding * scale,
        horizontal: AppSizes.voiceListHorizontalPadding * scale,
      ),
      child: Column(
        children: const [
          ListItem(title: 'Focus Attention', minutes: 10),
          ListItem(title: 'Body Scan', minutes: 5),
          ListItem(title: 'Making Happiness', minutes: 3),
        ],
      ),
    );
  }
}
class ListItem extends StatelessWidget {
  final String title;
  final int minutes;

  const ListItem({Key? key, required this.title, required this.minutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = AppSizes.contentScale(screenWidth);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.listItemSpacing * scale),
      child: Row(
        children: [
          Container(
            width: AppSizes.listIconOuterSize * scale,
            height: AppSizes.listIconOuterSize * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderGray,
                width: AppSizes.listIconBorderWidth * scale,
              ),
            ),
            child: Icon(
              Icons.play_arrow,
              size: AppSizes.listIconInnerSize * scale,
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(width: AppSizes.listItemTextSpacing * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.listTitle(scale)),
              SizedBox(height: AppSizes.listItemLabelSpacing * scale),
              Text('\${minutes} MIN', style: AppTextStyles.listSubtitle(scale)),
            ],
          ),
        ],
      ),
    );
  }
}