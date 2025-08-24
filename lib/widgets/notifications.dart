import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final _notifications = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _notifications.initialize(
    const InitializationSettings(android: androidSettings),
  );

  _scheduleDailyReminder();
}

void _scheduleDailyReminder() async {
  final now = tz.TZDateTime.now(tz.local);
  final scheduledTime = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    20, 0, 0,
  );

  final nextScheduledTime = scheduledTime.isBefore(now) ? scheduledTime.add(const Duration(days: 1)) : scheduledTime;

  await _notifications.zonedSchedule(
    0,
    'Sleep Log Reminder',
    'Don’t forget to log your sleep!',
    nextScheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'sleep_channel',
        'Sleep Logs',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
