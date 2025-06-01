import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '/views/home_page_7/home_Page_7.dart';
import 'time_picker_card.dart';
import 'day_button.dart';
import '../../constants/sizes.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/strings.dart';
import 'particle_background.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DateTime _selectedTime = DateTime.now();
  final List<String> _days = ['SU', 'M', 'T', 'W', 'TH', 'F', 'S'];
  final Set<String> _selectedDays = {};
  bool _noThanksHovered = false;

  final ScrollController _scrollController = ScrollController();
  bool _showBottomBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      if (!_showBottomBar) {
        setState(() => _showBottomBar = true);
      }
    } else if (direction == ScrollDirection.forward) {
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
      }
    }
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: AppColors.background,
            child: const ParticleBackground(numberOfParticles: 120),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.bodyPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final scale = AppSizes.contentScale(screenWidth);
                final textScale = (scale < 1 ? scale * 0.8 : scale);
                final horizontalPad = AppSizes.pagePaddingH * scale;
                const double elementGapBase = 15;
                final titleStyle = AppTextStyles.heading(textScale);
                final subtitleStyle = AppTextStyles.description(textScale);
                final dayButtonSize = (AppSizes.reminderDayButtonBaseSize * scale)
                    .clamp(AppSizes.reminderDayButtonMinSize, AppSizes.reminderDayButtonMaxSize);
                final buttonElevation = AppSizes.buttonElevationBase * scale;
                final buttonVertPadding = AppSizes.buttonPaddingVertical * scale;
                final buttonLetterSpacing = AppSizes.buttonLetterSpacing * textScale;
                final noThanksPadding = AppSizes.textLinkPadding * scale;
                final noThanksOpacity = _noThanksHovered ? AppColors.linkHoverOpacity : 1.0;
                final double cornerRadius = 18 * scale;

                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: EdgeInsets.only(
                              left: horizontalPad,
                              right: horizontalPad,
                              bottom: AppSizes.reminderBottomPadding * scale,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: AppSizes.contentTopPadding * scale),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(cornerRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadowColor.withOpacity(AppColors.shadowOpacity),
                                        blurRadius: 8 * scale,
                                        offset: Offset(0, 4 * scale),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(20 * scale),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppStrings.reminderWhatTimeLine1, style: titleStyle),
                                      Text(AppStrings.reminderWhatTimeLine2, style: titleStyle),
                                      SizedBox(height: elementGapBase),
                                      Text(
                                        AppStrings.reminderTimeRecommendation,
                                        style: subtitleStyle.copyWith(color: AppColors.textGray),
                                      ),
                                      SizedBox(height: 20),
                                      TimePickerCard(
                                        selectedTime: _selectedTime,
                                        scale: scale,
                                        onTimeChanged: (newTime) => setState(() => _selectedTime = newTime),
                                      ),
                                      SizedBox(height: elementGapBase),
                                      Divider(color: AppColors.borderGray),
                                      SizedBox(height: elementGapBase),
                                      Text(AppStrings.reminderWhichDayLine1, style: titleStyle),
                                      Text(AppStrings.reminderWhichDayLine2, style: titleStyle),
                                      SizedBox(height: elementGapBase),
                                      Text(
                                        AppStrings.reminderDayRecommendation,
                                        style: subtitleStyle.copyWith(color: AppColors.textGray),
                                      ),
                                      SizedBox(height: 40),
                                      Wrap(
                                        spacing: AppSizes.pageGapSmall * scale,
                                        runSpacing: AppSizes.pageGapSmall * scale,
                                        children: _days.map((day) {
                                          final isSelected = _selectedDays.contains(day);
                                          return DayButton(
                                            day: day,
                                            isSelected: isSelected,
                                            size: dayButtonSize,
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedDays.remove(day);
                                                } else {
                                                  _selectedDays.add(day);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: elementGapBase),

                                      SizedBox(height: 100 * scale),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Animated Bottom Container
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      bottom: _showBottomBar ? 0 : -150 * scale,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(cornerRadius),
                            topRight: Radius.circular(cornerRadius),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowColor.withOpacity(AppColors.shadowOpacity),
                              blurRadius: 8 * scale,
                              offset: Offset(0, -2 * scale),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: horizontalPad)
                            .copyWith(bottom: 16 * scale, top: 8 * scale),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: AppSizes.signUpButtonHeight * scale,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  elevation: buttonElevation,
                                  shadowColor: AppColors.shadowColor.withOpacity(AppColors.shadowOpacity),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(cornerRadius),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: buttonVertPadding),
                                ),
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomePage7()),
                                ),
                                child: Text(
                                  AppStrings.saveButton,
                                  style: TextStyle(
                                    fontFamily: AppFonts.helveticaBold,
                                    fontWeight: AppFonts.bold,
                                    fontSize: 16 * textScale,
                                    color: AppColors.white,
                                    letterSpacing: buttonLetterSpacing,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: elementGapBase),
                            MouseRegion(
                              onEnter: (_) => setState(() => _noThanksHovered = true),
                              onExit: (_) => setState(() => _noThanksHovered = false),
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomePage7()),
                                ),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: noThanksOpacity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: noThanksPadding,
                                      horizontal: noThanksPadding / 2,
                                    ),
                                    child: Text(
                                      AppStrings.noThanks,
                                      style: AppTextStyles.label(textScale).copyWith(
                                        color: AppColors.bodyPrimary,
                                        fontFamily: AppFonts.helveticaBold,
                                        letterSpacing: 1 * textScale,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
