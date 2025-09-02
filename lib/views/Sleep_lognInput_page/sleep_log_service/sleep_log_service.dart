import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../sleep_analysis/models/sleeplog_model_page.dart';
import 'package:flutter/foundation.dart';
class SleepLogService {
  static Future<void> saveSleepLog(SleepLog log) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('user_sleep_logs')
        .doc(user.uid)
        .collection('logs')
        .add(log.toMap());
  }

  static Future<List<SleepLog>> getHistoricalSleepLogs({int limit = 7}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final snapshot = await FirebaseFirestore.instance
        .collection('user_sleep_logs')
        .doc(user.uid)
        .collection('logs')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SleepLog.fromMap(doc.data(), doc.id))
        .toList();
  }
  static Future<void> logAnalytics(SleepLog log) async {
    debugPrint('Analytics: saved log for ${log.date}');
  }
}