import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerCard extends StatefulWidget {
  final DateTime selectedTime;
  final double scale;
  final ValueChanged<DateTime> onTimeChanged;

  const TimePickerCard({
    Key? key,
    required this.selectedTime,
    required this.scale,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _TimePickerCardState createState() => _TimePickerCardState();
}

class _TimePickerCardState extends State<TimePickerCard> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;
  final List<int> _hourValues = List.generate(12, (i) => i + 1);
  final List<int> _minuteValues = List.generate(60, (i) => i);
  final List<String> _periodValues = ['AM', 'PM'];

  int _selectedHourIndex = 0;
  int _selectedMinuteIndex = 0;
  int _selectedPeriodIndex = 0;

  @override
  void initState() {
    super.initState();
    final hour24 = widget.selectedTime.hour;
    if (hour24 == 0) {
      _selectedHourIndex = 11;
      _selectedPeriodIndex = 0;
    } else if (hour24 < 12) {
      _selectedHourIndex = hour24 - 1;
      _selectedPeriodIndex = 0;
    } else if (hour24 == 12) {
      _selectedHourIndex = 11;
      _selectedPeriodIndex = 1;
    } else {
      _selectedHourIndex = hour24 - 13;
      _selectedPeriodIndex = 1;
    }

    _selectedMinuteIndex = widget.selectedTime.minute;

    _hourController = FixedExtentScrollController(initialItem: _selectedHourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinuteIndex);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriodIndex);
  }

  @override
  void didUpdateWidget(covariant TimePickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTime != widget.selectedTime) {
      final hour24 = widget.selectedTime.hour;
      int newHourIndex, newPeriodIndex;

      if (hour24 == 0) {
        newHourIndex = 11;
        newPeriodIndex = 0;
      } else if (hour24 < 12) {
        newHourIndex = hour24 - 1;
        newPeriodIndex = 0;
      } else if (hour24 == 12) {
        newHourIndex = 11;
        newPeriodIndex = 1;
      } else {
        newHourIndex = hour24 - 13;
        newPeriodIndex = 1;
      }

      final newMinuteIndex = widget.selectedTime.minute;

      if (newHourIndex != _selectedHourIndex) {
        _selectedHourIndex = newHourIndex;
        _hourController.jumpToItem(_selectedHourIndex);
      }
      if (newMinuteIndex != _selectedMinuteIndex) {
        _selectedMinuteIndex = newMinuteIndex;
        _minuteController.jumpToItem(_selectedMinuteIndex);
      }
      if (newPeriodIndex != _selectedPeriodIndex) {
        _selectedPeriodIndex = newPeriodIndex;
        _periodController.jumpToItem(_selectedPeriodIndex);
      }
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _onPickerChanged() {
    final selectedHour12 = _hourValues[_selectedHourIndex];
    final selectedMinute = _minuteValues[_selectedMinuteIndex];
    final isPm = (_periodValues[_selectedPeriodIndex] == 'PM');

    int hour24;
    if (isPm) {
      hour24 = (selectedHour12 == 12) ? 12 : (selectedHour12 + 12);
    } else {
      hour24 = (selectedHour12 == 12) ? 0 : selectedHour12;
    }

    final updated = DateTime(
      widget.selectedTime.year,
      widget.selectedTime.month,
      widget.selectedTime.day,
      hour24,
      selectedMinute,
    );
    widget.onTimeChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final pickerHeight = 230 * scale;
    const baseTextColor = Colors.black;
    const unselectedColor = Color(0xFFA1A4B2);

    return Container(
      width: double.infinity,
      height: pickerHeight,
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Semi-transparent overlay behind selected rows
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  height: 40 * scale,
                  margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: _hourController,
                  itemExtent: 40 * scale,
                  useMagnifier: true,
                  magnification: 1.1,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedHourIndex = index;
                      _onPickerChanged();
                    });
                  },
                  children: List<Widget>.generate(_hourValues.length, (index) {
                    final distance = (_selectedHourIndex - index).abs();
                    Color color;
                    if (distance == 0) {
                      color = baseTextColor;
                    } else if (distance == 1) {
                      color = unselectedColor;
                    } else if (distance == 2) {
                      color = unselectedColor.withOpacity(0.5);
                    } else {
                      color = unselectedColor.withOpacity(0.0);
                    }
                    return Center(
                      child: Text(
                        _hourValues[index].toString(),
                        style: TextStyle(fontSize: 30 * scale, color: color),
                      ),
                    );
                  }),
                ),
              ),
              // Vertical divider between pickers
              Container(
                width: 1 * scale,
                height: pickerHeight * 0.6,
                color: Colors.white.withOpacity(0.7),
                margin: EdgeInsets.symmetric(vertical: pickerHeight * 0.2),
              ),

              Expanded(
                child: CupertinoPicker(
                  scrollController: _minuteController,
                  itemExtent: 40 * scale,
                  useMagnifier: true,
                  magnification: 1.1,
                  squeeze: 1.1,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMinuteIndex = index;
                      _onPickerChanged();
                    });
                  },
                  children: List<Widget>.generate(_minuteValues.length, (index) {
                    final distance = (_selectedMinuteIndex - index).abs();
                    Color color;
                    if (distance == 0) {
                      color = baseTextColor;
                    } else if (distance == 1) {
                      color = unselectedColor;
                    } else if (distance == 2) {
                      color = unselectedColor.withOpacity(0.5);
                    } else {
                      color = unselectedColor.withOpacity(0.0);
                    }
                    return Center(
                      child: Text(
                        _minuteValues[index].toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 30 * scale, color: color),
                      ),
                    );
                  }),
                ),
              ),

              Container(
                width: 1 * scale,
                height: pickerHeight * 0.6,
                color: Colors.white.withOpacity(0.7),
                margin: EdgeInsets.symmetric(vertical: pickerHeight * 0.2),
              ),

              Expanded(
                child: CupertinoPicker(
                  scrollController: _periodController,
                  itemExtent: 40 * scale,
                  useMagnifier: true,
                  magnification: 1.1,
                  squeeze: 1.1,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedPeriodIndex = index;
                      _onPickerChanged();
                    });
                  },
                  children: List<Widget>.generate(_periodValues.length, (index) {
                    final distance = (_selectedPeriodIndex - index).abs();
                    Color color;
                    if (distance == 0) {
                      color = baseTextColor;
                    } else if (distance == 1) {
                      color = unselectedColor;
                    } else if (distance == 2) {
                      color = unselectedColor.withOpacity(0.5);
                    } else {
                      color = unselectedColor.withOpacity(0.0);
                    }
                    return Center(
                      child: Text(
                        _periodValues[index],
                        style: TextStyle(fontSize: 30 * scale, color: color),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}