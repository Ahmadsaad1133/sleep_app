import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../sleep_analysis/models/sleeplog_model_page.dart';
import 'package:flutter/foundation.dart';

import 'api_result.dart';
class SleepLogService {
  static Future<ApiResult<void>> saveSleepLog(SleepLog log) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const ApiResult(error: 'User not authenticated');
      }


      await FirebaseFirestore.instance
          .collection('user_sleep_logs')
          .doc(user.uid)
          .collection('logs')
          .add(log.toMap());
      return const ApiResult();
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  static Future<ApiResult<List<SleepLog>>> getHistoricalSleepLogs({int limit = 7}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const ApiResult(error: 'User not authenticated');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('user_sleep_logs')
          .doc(user.uid)
          .collection('logs')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final logs = snapshot.docs
          .map((doc) => SleepLog.fromMap(doc.data(), doc.id))
          .toList();
      return ApiResult(data: logs);
    } catch (e) {
      return ApiResult(error: e.toString());
    }
  }
  static Future<void> logAnalytics(SleepLog log) async {
    debugPrint('Analytics: saved log for ${log.date}');
  }
}