import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/sizes.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
import '/constants/strings.dart';
import '/constants/assets.dart';
class DailyThoughtCard extends StatelessWidget {
  const DailyThoughtCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const baseWidth = 414.0;
    final scale = (width / baseWidth).clamp(0.8, 1.2);
    double s(double v) => v * scale;

    return Center(
      child: AspectRatio(
        aspectRatio: 374 / 95,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(s(AppSizes.cardRadius)),
          child: Container(
            color: AppColors.dailyThoughtBg,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    AppAssets.dailyFrame1,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SvgPicture.asset(
                    AppAssets.dailyFrame2,
                    width: s(184),
                    height: s(69),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: width * 0.37,
                  child: SvgPicture.asset(
                    AppAssets.dailyFrame3,
                    width: s(64),
                    height: s(58),
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.dailyThoughtTitle,
                            style: TextStyle(
                              fontSize: s(18),
                              fontFamily: AppFonts.helveticaBold,
                              fontWeight: AppFonts.bold,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: s(5)),
                          Text(
                            AppStrings.dailyThoughtSub,
                            style: TextStyle(
                              fontSize: s(11),
                              fontFamily: AppFonts.helveticaRegular,
                              fontWeight: AppFonts.light,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(right: s(30)),
                        width: s(40),
                        height: s(40),
                        decoration: const BoxDecoration(
                          color: AppColors.dailyIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: s(24),
                          color: AppColors.dailyIconColor,
                        ),
                      ),
                    ],
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
