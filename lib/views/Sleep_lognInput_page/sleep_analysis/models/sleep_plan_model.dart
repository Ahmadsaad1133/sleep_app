import 'package:cloud_firestore/cloud_firestore.dart';

class SleepPlanDay {
  final int day;
  final String title;
  final String focus;
  final String morningRoutine;
  final String afternoonRoutine;
  final String eveningRoutine;
  final String sleepTips;
  final String motivationalQuote;

  SleepPlanDay({
    required this.day,
    required this.title,
    required this.focus,
    required this.morningRoutine,
    required this.afternoonRoutine,
    required this.eveningRoutine,
    required this.sleepTips,
    required this.motivationalQuote,
  });

  factory SleepPlanDay.fromMap(Map<String, dynamic> map) {
    return SleepPlanDay(
      day: map['day'] as int,
      title: map['title'] as String,
      focus: map['focus'] as String,
      morningRoutine: map['morning_routine'] as String,
      afternoonRoutine: map['afternoon_routine'] as String,
      eveningRoutine: map['evening_routine'] as String,
      sleepTips: map['sleep_tips'] as String,
      motivationalQuote: map['motivational_quote'] as String,
    );
  }
}

class SleepPlan {
  final DateTime startDate;
  final DateTime endDate;
  final String overview;
  final List<SleepPlanDay> days;
  final String mainFocus;
  final String keyMetrics;

  SleepPlan({
    required this.startDate,
    required this.endDate,
    required this.overview,
    required this.days,
    required this.mainFocus,
    required this.keyMetrics,
  });

  factory SleepPlan.fromMap(Map<String, dynamic> map) {
    return SleepPlan(
      startDate: (map['start_date'] as Timestamp).toDate(),
      endDate: (map['end_date'] as Timestamp).toDate(),
      overview: map['overview'] as String,
      days: (map['days'] as List).map((e) => SleepPlanDay.fromMap(e)).toList(),
      mainFocus: map['main_focus'] as String,
      keyMetrics: map['key_metrics'] as String,
    );
  }
}