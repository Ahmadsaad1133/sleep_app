import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/fonts.dart';

class SleepAlertsHistoryPage extends StatelessWidget {
  const SleepAlertsHistoryPage({super.key});

  Future<List<Map<String, dynamic>>> fetchAlerts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('sleep_alerts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'text': doc.data()['alertText'] ?? '',
      'createdAt': (doc.data()['createdAt'] as Timestamp).toDate(),
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Alerts History', style: TextStyle(fontFamily: AppFonts.AirbnbCerealBook)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sleep alerts found.', style: TextStyle(fontSize: 16)));
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final dateStr = "${alert['createdAt'].toLocal()}".split(' ').first;

              return Card(
                color: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('⚠️ Alert on $dateStr',
                        style: const TextStyle(
                          fontFamily: AppFonts.AirbnbCerealBook,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert['text'],
                        style: const TextStyle(
                          fontFamily: AppFonts.AirbnbCerealBook,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
