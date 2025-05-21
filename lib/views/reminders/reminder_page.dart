import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    if (screenWidth <= 320) {
      scale = 0.65;
    } else if (screenWidth <= 360) {
      scale = 0.75;
    } else if (screenWidth <= 414) {
      scale = 0.85;
    } else if (screenWidth <= 600) {
      scale = 1.0;
    } else {
      scale = 1.2;
    }

    const double spacing = 20.0;

    final double titleFontSize = 28 * scale;
    final double subtitleFontSize = 16 * scale;
    final double noThanksFontSize = 14 * scale;

    final primary = const Color(0xFF8E97FD);

    final titleStyle = TextStyle(
      fontFamily: 'HelveticaNeueBold',
      fontSize: titleFontSize,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: const Color(0xFF3F414E),
    );

    final smallTitleStyle = TextStyle(
      fontFamily: 'HelveticaNeueBold',
      fontSize: titleFontSize * 0.85,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: const Color(0xFF3F414E),
    );

    final subtitleStyle = TextStyle(
      fontFamily: 'HelveticaNeueRegular',
      fontSize: subtitleFontSize,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: const Color(0xFFA1A4B2),
    );

    final largerSubtitleStyle = subtitleStyle.copyWith(
      fontSize: subtitleFontSize * 1.2,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFA1A4B2),
    );

    final noThanksButtonStyle = TextStyle(
      fontFamily: 'HelveticaNeue',
      fontWeight: FontWeight.w400,
      fontSize: noThanksFontSize,
      height: 1.08,
      letterSpacing: 0.05,
      color: const Color(0xFF3F414E),
    );

    // Day button size: base 40 px scaled by scale factor but constrained min and max
    double dayButtonSize = 40 * scale;
    if (dayButtonSize < 30) dayButtonSize = 30; // minimum size
    if (dayButtonSize > 50) dayButtonSize = 50; // maximum size

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: 20 * scale).copyWith(top: 40 * scale),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What time would you', style: smallTitleStyle),
                      SizedBox(height: 8 * scale),
                      Text('like to meditate?', style: smallTitleStyle),
                      SizedBox(height: 24 * scale),

                      Text('Any time you can choose but we recommend', style: largerSubtitleStyle),
                      Text('first thing in the morning.', style: largerSubtitleStyle),
                      SizedBox(height: spacing),

                      Container(
                        width: double.infinity,
                        height: 212 * scale,
                        padding: EdgeInsets.symmetric(vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12 * scale),
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
                      SizedBox(height: spacing),

                      Text('Which day would you', style: smallTitleStyle),
                      SizedBox(height: 8 * scale),
                      Text('like to meditate?', style: smallTitleStyle),
                      SizedBox(height: spacing),

                      Text('Everyday is best, but we recommend picking', style: largerSubtitleStyle),
                      Text('at least five.', style: largerSubtitleStyle),
                      SizedBox(height: spacing),
                    ],
                  ),
                ),
              ),

              // Days chooser row moved here - above Save button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _days.map((day) {
                  final bool selected = _selectedDays.contains(day);
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
                        color: selected ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(dayButtonSize / 2),
                        border: Border.all(
                          color: selected ? primary : const Color(0xFFE6E7F2),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : const Color(0xFF3F414E),
                          fontSize: dayButtonSize * 0.35,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: spacing),

              // Save button and No Thanks text
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
                        // TODO: Save logic
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
                  SizedBox(height: 12 * scale),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Center(
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
