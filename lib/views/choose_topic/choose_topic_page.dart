import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../reminders/reminder_page.dart';

class ChooseTopicPage extends StatelessWidget {
  const ChooseTopicPage({Key? key}) : super(key: key);

  Widget buildTopicWidget({
    required double baseWidth,
    required double baseHeight,
    required Color color,
    String? label,
    String? svgAsset,
    double? baseSvgWidth,
    double? baseSvgHeight,
    bool noPaddingTopForSvg = false,
    List<Widget>? extraTopWidgets,
    double scale = 1.0,
    Widget? customLabelWidget,
    VoidCallback? onTap,
  }) {
    final width = baseWidth * scale;
    final height = baseHeight * scale;
    final svgWidth = baseSvgWidth != null ? baseSvgWidth * scale : null;
    final svgHeight = baseSvgHeight != null ? baseSvgHeight * scale : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (svgAsset != null)
              noPaddingTopForSvg
                  ? Align(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset(
                  svgAsset,
                  width: svgWidth,
                  height: svgHeight,
                  fit: BoxFit.contain,
                ),
              )
                  : Padding(
                padding: EdgeInsets.only(top: 8.0 * scale),
                child: SvgPicture.asset(
                  svgAsset,
                  width: svgWidth,
                  height: svgHeight,
                  fit: BoxFit.contain,
                ),
              ),
            if (extraTopWidgets != null)
              ...extraTopWidgets.map(
                    (widget) => Padding(
                  padding: EdgeInsets.only(top: 8.0 * scale),
                  child: widget,
                ),
              ),
            if (customLabelWidget != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.0 * scale),
                child: customLabelWidget,
              )
            else if (label != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.0 * scale),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'HelveticaNeue',
                    fontWeight: FontWeight.w600,
                    fontSize: 18 * scale,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // scale for sizing the entire widgets
    double scale;
    if (screenWidth <= 320) {
      scale = 0.7;
    } else if (screenWidth <= 360) {
      scale = 0.8;
    } else if (screenWidth <= 414) {
      scale = 0.9;
    } else if (screenWidth <= 600) {
      scale = 1.0;
    } else {
      scale = 1.2;
    }

    // separate scale factor for text sizes inside widgets (smaller overall)
    double textScaleFactor;
    if (screenWidth <= 320) {
      textScaleFactor = 0.6;
    } else if (screenWidth <= 360) {
      textScaleFactor = 0.7;
    } else if (screenWidth <= 414) {
      textScaleFactor = 0.8;
    } else if (screenWidth <= 600) {
      textScaleFactor = 0.85;
    } else {
      textScaleFactor = 1.0;
    }

    final labelTextStyle = TextStyle(
      color: const Color(0xFFFFECCC),
      fontFamily: 'HelveticaNeue',
      fontWeight: FontWeight.w700,
      fontSize: 18 * textScaleFactor,
      height: 1.35,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 100 * scale),
              child: SvgPicture.asset(
                'assets/images/UnionFrame.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * scale,
                vertical: 40 * scale,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Brings you',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeueBold',
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: const Color(0xFF3F414E),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'to Silent Moon?',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeueRegular',
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        color: const Color(0xFF3F414E),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Text(
                      'choose a topic to focuse on:',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w300,
                        height: 1.0,
                        color: const Color(0xFFA1A4B2),
                      ),
                    ),
                    SizedBox(height: 30 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            buildTopicWidget(
                              baseWidth: 176.43,
                              baseHeight: 210,
                              color: const Color(0xFF8E97FD),
                              svgAsset: 'assets/images/Widget1.svg',
                              baseSvgWidth: 164,
                              baseSvgHeight: 146,
                              noPaddingTopForSvg: true,
                              scale: scale,
                              customLabelWidget: Text(
                                'Reduce Stress',
                                style: labelTextStyle,
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 167,
                              color: const Color(0xFFFEB18F),
                              scale: scale,
                              extraTopWidgets: [
                                SvgPicture.asset(
                                  'assets/images/Widget3.svg',
                                  width: 176 * scale,
                                  height: 90 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ],
                              customLabelWidget: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10 * scale),
                                child: Text(
                                  'Increase\nHappiness',
                                  style: labelTextStyle.copyWith(color: Colors.black),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 210,
                              color: const Color(0xFF6CB28E),
                              scale: scale,
                              extraTopWidgets: [
                                SvgPicture.asset(
                                  'assets/images/Widget5.svg',
                                  width: 176 * scale,
                                  height: 114 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ],
                              customLabelWidget: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10 * scale),
                                child: Text(
                                  'Personal\nGrowth',
                                  style: labelTextStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 210,
                              color: const Color(0xFF8E97FD),
                              svgAsset: 'assets/images/Widget1.svg',
                              baseSvgWidth: 164,
                              baseSvgHeight: 146,
                              noPaddingTopForSvg: true,
                              scale: scale,
                              customLabelWidget: Text(
                                'Reduce Stress',
                                style: labelTextStyle,
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 167,
                              color: const Color(0xFFFA6E5A),
                              extraTopWidgets: [
                                SvgPicture.asset(
                                  'assets/images/Widget2.svg',
                                  width: 118 * scale,
                                  height: 85 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ],
                              scale: scale,
                              customLabelWidget: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10 * scale),
                                child: Text(
                                  'Improve\nPerformance',
                                  style: labelTextStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 210,
                              color: const Color(0xFFFFCF86),
                              label: 'Reduce Anxiety',
                              extraTopWidgets: [
                                SvgPicture.asset(
                                  'assets/images/Widget4.svg',
                                  width: 139 * scale,
                                  height: 122 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ],
                              scale: scale,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 167,
                              color: const Color(0xFF3F414E),
                              scale: scale,
                              extraTopWidgets: [
                                SvgPicture.asset(
                                  'assets/images/Widget6.svg',
                                  width: 176 * scale,
                                  height: 86 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ],
                              customLabelWidget: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10 * scale),
                                child: Text(
                                  'Better Sleep',
                                  style: labelTextStyle.copyWith(
                                    color: const Color(0xFFEBEAEC),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 176,
                              baseHeight: 210,
                              color: const Color(0xFFD9A5B5),
                              svgAsset: 'assets/images/Widget1.svg',
                              baseSvgWidth: 164,
                              baseSvgHeight: 146,
                              noPaddingTopForSvg: true,
                              scale: scale,
                              customLabelWidget: Text(
                                'Old Music',
                                style: labelTextStyle,
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderPage()));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
