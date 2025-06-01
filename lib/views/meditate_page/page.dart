import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/views/music_v2/page.dart';
import '/views/meditate_page/category_chip.dart';
import '/views/meditate_page/meditation_tile.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
class MeditatePage extends StatefulWidget {
  const MeditatePage({Key? key}) : super(key: key);

  @override
  State<MeditatePage> createState() => _MeditatePageState();
}

class _MeditatePageState extends State<MeditatePage> {
  int _categoryIndex = 0;

  void _onCategoryTapped(int index) {
    if (index == _categoryIndex) return;
    setState(() => _categoryIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            double scale;
            if (w <= 300) {
              scale = 0.65;
            } else if (w <= 360) {
              scale = 0.8;
            } else if (w <= 414) {
              scale = 0.95;
            } else if (w <= 600) {
              scale = 1.1;
            } else if (w <= 900) {
              scale = 1.3;
            } else {
              scale = 1.5;
            }
            final padding = 24.0 * scale;

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50 * scale),
                  Center(
                    child: Text(
                      AppStrings.meditateTitle,
                      style: TextStyle(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HelveticaNeueBold',
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Center(
                    child: Text(
                      AppStrings.meditateDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        fontFamily: 'HelveticaNeueRegular',
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  Padding(
                    padding: EdgeInsets.only(left: padding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppStrings.meditateCategories
                            .asMap()
                            .entries
                            .map((entry) {
                          final idx = entry.key;
                          final label = entry.value;
                          return CategoryChip(
                            label: label,
                            iconAsset: idx < AppStrings.meditateIcons.length
                                ? AppStrings.meditateIcons[idx]
                                : null,
                            isActive: idx == _categoryIndex,
                            scale: scale,
                            onTap: () => _onCategoryTapped(idx),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10 * scale),
                      child: Container(
                        width: w - padding * 2,
                        height: 95 * scale,
                        color: AppColors.meditationCardBg,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: SvgPicture.asset(
                                AppStrings.dailyCalmBgLeft,
                                width: 98 * scale,
                                height: 95 * scale,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: SvgPicture.asset(
                                AppStrings.dailyCalmBgTopRight,
                                width: 184 * scale,
                                height: 69 * scale,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 155 * scale,
                              child: SvgPicture.asset(
                                AppStrings.dailyCalmAccent,
                                width: 64 * scale,
                                height: 25 * scale,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 25 * scale,
                                right: 16 * scale,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.dailyCalmTitle,
                                    style: TextStyle(
                                      fontSize: 18 * scale,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'HelveticaNeueBold',
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5 * scale),
                                  Text(
                                    AppStrings.dailyCalmSubtitle,
                                    style: TextStyle(
                                      fontSize: 11 * scale,
                                      fontFamily: 'HelveticaNeueRegular',
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 30 * scale),
                                child: Container(
                                  width: 44 * scale,
                                  height: 44 * scale,
                                  decoration: BoxDecoration(
                                    color: AppColors.playButtonBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: AppColors.playIconColor,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MusicV2Page()),
                            );
                          },
                          child: MeditationTile(
                            imageAsset: AppStrings.calmTileIcon,
                            title: AppStrings.tile1Title,
                            scale: scale,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MusicV2Page()),
                            );
                          },
                          child: MeditationTile(
                            imageAsset: AppStrings.anxietyTileIcon,
                            title: AppStrings.tile2Title,
                            scale: scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
