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
                    fontFamily: 'HelveticaNeueBold',
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
      fontFamily: 'HelveticaNeueBold',
      fontWeight: FontWeight.w700,
      fontSize: 20 * textScaleFactor,
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
                        fontWeight: FontWeight.w300,
                        height: 1.35,
                        color: const Color(0xFF3F414E),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Text(
                      'choose a topic to focuse on:',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeueRegular',
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
                              baseWidth: 186,
                              baseHeight: 220,
                              color: const Color(0xFF8E97FD),
                              svgAsset: 'assets/images/Widget1.svg',
                              baseSvgWidth: 164,
                              baseSvgHeight: 146,
                              noPaddingTopForSvg: true,
                              scale: scale,
                              customLabelWidget: Container(
                                alignment: Alignment.centerLeft, // aligns text to the left center
                                padding: EdgeInsets.only(left: 10 * scale),
                                child: Text(
                                  'Reduce Stress',
                                  style: labelTextStyle.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'HelveticaNeueBold',
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),


                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 177,
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
                                  style: labelTextStyle.copyWith(color: Color(0xFF3F414E)),

                                  textAlign: TextAlign.left,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 220,
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
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 220,
                              color: const Color(0xFF8E97FD),
                              svgAsset: 'assets/images/Widget1.svg',
                              baseSvgWidth: 164,
                              baseSvgHeight: 146,
                              noPaddingTopForSvg: true,  // This ensures the SVG is aligned at the top without padding
                              scale: scale,
                              customLabelWidget: Text(
                                'Reduce Stress',
                                style: labelTextStyle.copyWith(
                                  color: Colors.white,
                                  fontFamily: 'HelveticaNeue',
                                ),
                                textAlign: TextAlign.left,
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),

                          ],
                        ),
                        Column(
                          children: [
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 187,
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
                                  style: labelTextStyle.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'HelveticaNeueBold',
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 210,
                              color: const Color(0xFFFFCF86),
                              extraTopWidgets: [
                                SvgPicture.asset(
                                  'assets/images/Widget4.svg',
                                  width: 139 * scale,
                                  height: 122 * scale,
                                  fit: BoxFit.contain,
                                ),
                              ],
                              scale: scale,
                              customLabelWidget: Padding(
                                padding: EdgeInsets.only(bottom: 12.0 * scale),
                                child: Text(
                                  'Reduce Anxiety',
                                  style: labelTextStyle.copyWith(color: Color(0xFF3F414E) , fontFamily: 'HelveticaNeueBold',),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 177,
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
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
                              },
                            ),
                            SizedBox(height: 15 * scale),
                            buildTopicWidget(
                              baseWidth: 186,
                              baseHeight: 220,
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
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
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
