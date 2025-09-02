import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../sleep_analysis/models/sleeplog_model_page.dart';

class SleepLogLocalStorage {
  static const _key = 'partial_sleep_log';

  static Future<void> savePartial(SleepLog log) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(log.toMap()));
  }

  static Future<SleepLog?> loadPartial() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;
    final map = jsonDecode(data) as Map<String, dynamic>;
    return SleepLog.fromMap(map);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}