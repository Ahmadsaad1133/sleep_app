// lib/sleep_affirmation_widget.dart

import 'package:flutter/material.dart';
import '../views/groq_service/groq_service.dart';

class SleepAffirmationWidget extends StatefulWidget {
  const SleepAffirmationWidget({Key? key}) : super(key: key);

  @override
  _SleepAffirmationWidgetState createState() => _SleepAffirmationWidgetState();
}

class _SleepAffirmationWidgetState extends State<SleepAffirmationWidget> {
  String _affirmation = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAffirmation();
  }

  Future<void> _loadAffirmation() async {
    try {
      final text = await GroqService.fetchSleepMessage();
      setState(() {
        _affirmation = text.trim();
      });
    } catch (e) {
      setState(() {
        _affirmation = 'Failed to load affirmation.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Affirmation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text(
            _affirmation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'AirbnbCereal',
              fontSize: 20,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
