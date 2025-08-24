// lib/services/sleep_log_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../views/Sleep_lognInput_page/sleep_analysis/models/sleeplog_model_page.dart';

class SleepLogService {
  static Future<void> saveLog(SleepLog model) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sleep_logs')
        .add(model.toMap());
  }

  static Future<void> saveLogWithErrorHandling(
      SleepLog model,
      BuildContext context
      ) async {
    try {
      await saveLog(model);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sleep log saved successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving log: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}