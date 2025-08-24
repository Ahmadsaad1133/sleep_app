import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../constants/fonts.dart';
import '../../../../constants/colors.dart';
import '../models/sleep_plan_model.dart';
import '../models/sleeplog_model_page.dart';

class SleepAIPlanPage extends StatefulWidget {
  final SleepPlan plan;
  final String? planBaseLogId;

  const SleepAIPlanPage({Key? key, required this.plan, this.planBaseLogId}) : super(key: key);

  @override
  _SleepAIPlanPageState createState() => _SleepAIPlanPageState();
}

class _SleepAIPlanPageState extends State<SleepAIPlanPage> {
  bool _isPlanSaved = false;

  Future<void> _savePlan(SleepPlan plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sleep_plans')
          .add({
        'created_at': Timestamp.now(),
        'start_date': Timestamp.fromDate(plan.startDate),
        'end_date': Timestamp.fromDate(plan.endDate),
        'overview': plan.overview,
        'main_focus': plan.mainFocus,
        'key_metrics': plan.keyMetrics,
        'days': plan.days.map((day) => {
          'day': day.day,
          'title': day.title,
          'focus': day.focus,
          'morning_routine': day.morningRoutine,
          'afternoon_routine': day.afternoonRoutine,
          'evening_routine': day.eveningRoutine,
          'sleep_tips': day.sleepTips,
          'motivational_quote': day.motivationalQuote,
        }).toList(),
      });

      setState(() => _isPlanSaved = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sleep plan saved!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save plan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader(SleepPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-DAY SLEEP PLAN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontFamily: AppFonts.ComfortaaBold,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPlanSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.yellow,
                  size: 30,
                ),
                onPressed: _isPlanSaved ? null : () => _savePlan(plan),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${DateFormat('MMM dd').format(plan.startDate)} - ${DateFormat('MMM dd').format(plan.endDate)}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            plan.overview,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Main Focus', plan.mainFocus),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard('Key Metrics', plan.keyMetrics),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(SleepPlanDay day) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: _getDayColor(day.day),
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTextColor(day.day),
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
        ),
        title: Text(
          day.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: AppFonts.ComfortaaBold,
          ),
        ),
        subtitle: Text(
          day.focus,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontFamily: AppFonts.ComfortaaBold,
          ),
        ),
        children: [
          _buildRoutineSection('🌞 Morning Routine', day.morningRoutine),
          _buildRoutineSection('⛅ Afternoon Routine', day.afternoonRoutine),
          _buildRoutineSection('🌙 Evening Routine', day.eveningRoutine),
          _buildTipSection(day.sleepTips, day.motivationalQuote),
        ],
      ),
    );
  }

  Color _getDayColor(int day) {
    final colors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
      Colors.pink.shade100,
      Colors.indigo.shade100,
    ];
    return colors[(day - 1) % colors.length];
  }

  Color _getTextColor(int day) {
    final colors = [
      Colors.blue.shade800,
      Colors.green.shade800,
      Colors.purple.shade800,
      Colors.orange.shade800,
      Colors.teal.shade800,
      Colors.pink.shade800,
      Colors.indigo.shade800,
    ];
    return colors[(day - 1) % colors.length];
  }

  Widget _buildRoutineSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTipSection(String tip, String quote) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                "Today's Sleep Tip",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: AppFonts.ComfortaaBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.blue, width: 3)),
            ),
            child: Text(
              '"$quote"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.blue.shade800,
                fontSize: 15,
                fontFamily: AppFonts.ComfortaaBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sleep Plan'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {/* Implement share functionality */},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(widget.plan),
            const SizedBox(height: 20),
            ...widget.plan.days.map(_buildDayCard).toList(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {/* Implement calendar export */},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Add to Calendar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back to Analysis',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
        ),
      ],
    );
  }
}