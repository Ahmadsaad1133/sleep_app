import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/views/home_page_7/home_Page_7.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DateTime _selectedTime = DateTime.now();
  final List<String> _days = ['SU', 'M', 'T', 'W', 'TH', 'F', 'S'];
  final Set<String> _selectedDays = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale factor based on screen width
    double scale;
    if (screenWidth <= 330) {
      scale = 0.55;
    } else if (screenWidth <= 350) {
      scale = 0.70;
    } else if (screenWidth <= 414) {
      scale = 0.85;
    } else if (screenWidth <= 600) {
      scale = 1.0;
    } else {
      scale = 1.2;
    }

    const double spacing = 20.0;
    final primary = const Color(0xFF8E97FD);
    final selectedDayColor = const Color(0xFF3F414E);
    final titleFontSize = 28 * scale;
    final subtitleFontSize = 16 * scale;
    final noThanksFontSize = 14 * scale;

    final extraBoldTitleStyle = TextStyle(
      fontFamily: 'HelveticaNeueBold',
      fontSize: titleFontSize,
      fontWeight: FontWeight.w900,
      height: 1.35,
      color: const Color(0xFF3F414E),
    );

    final largerSubtitleStyle = TextStyle(
      fontFamily: 'HelveticaNeueRegular',
      fontSize: subtitleFontSize * 1.2,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: const Color(0xFFA1A4B2),
    );

    final noThanksButtonStyle = TextStyle(
      fontFamily: 'HelveticaNeueRegular',
      fontWeight: FontWeight.w400,
      fontSize: noThanksFontSize,
      height: 1.08,
      letterSpacing: 1,
      color: selectedDayColor,
    );
    double dayButtonSize = 50 * scale;
    dayButtonSize = dayButtonSize.clamp(30.0, 50.0);

    final double leftPadding = 15 * scale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * scale).copyWith(top: 40 * scale),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding, top: 30 * scale),
                        child: Text('What time would you', style: extraBoldTitleStyle),
                      ),
                      SizedBox(height: 1 * scale),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text('like to meditate?', style: extraBoldTitleStyle),
                      ),
                      SizedBox(height: 10 * scale),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text(
                          'Any time you can choose but we recommend',
                          style: largerSubtitleStyle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text(
                          'first thing in the morning.',
                          style: largerSubtitleStyle,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Container(
                        width: double.infinity,
                        height: 230 * scale,
                        padding: EdgeInsets.symmetric(vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        child: CupertinoTheme(
                          data: CupertinoTheme.of(context).copyWith(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 30 * scale,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: _selectedTime,
                            use24hFormat: false,
                            onDateTimeChanged: (newTime) {
                              setState(() {
                                _selectedTime = newTime;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text('Which day would you', style: extraBoldTitleStyle),
                      ),
                      SizedBox(height: 1 * scale),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text('like to meditate?', style: extraBoldTitleStyle),
                      ),
                      SizedBox(height: spacing),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text(
                          'Everyday is best, but we recommend picking',
                          style: largerSubtitleStyle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Text('at least five.', style: largerSubtitleStyle),
                      ),
                      SizedBox(height: spacing),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _days.map((day) {
                    final selected = _selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                        });
                      },
                      child: Container(
                        width: dayButtonSize,
                        height: dayButtonSize,
                        decoration: BoxDecoration(
                          color: selected ? selectedDayColor : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? selectedDayColor : const Color(0xFFE6E7F2),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : const Color(0xFFA1A4B2),
                            fontSize: dayButtonSize * 0.35,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: spacing),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 63 * scale,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38 * scale),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage7()),
                        );
                      },
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40 * scale),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage7()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 10),
                      child: Text(
                        'No Thanks',
                        style: noThanksButtonStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
