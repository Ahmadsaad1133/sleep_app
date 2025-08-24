// lib/utils/time_utils.dart
import 'dart:math';

import 'package:flutter/material.dart';

TimeOfDay parseTimeString(String timeStr) {
  try {
    final RegExp timeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
    final match = timeRegex.firstMatch(timeStr);
    if (match == null) throw const FormatException('Invalid time format');

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const FormatException('Time values out of range');
    }

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    debugPrint('Time parsing error: $e');
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

String formatTimeOfDay(TimeOfDay time, {bool use24Hour = false}) {
  if (use24Hour) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  final period = time.hour >= 12 ? 'PM' : 'AM';
  var hour = time.hour % 12;
  hour = hour == 0 ? 12 : hour;

  return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
}

Duration calculateDuration(TimeOfDay start, TimeOfDay end) {
  final now = DateTime.now();
  var startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
  var endDt = DateTime(now.year, now.month, now.day, end.hour, end.minute);
  if (endDt.isBefore(startDt)) endDt = endDt.add(const Duration(days: 1));
  return endDt.difference(startDt);
}