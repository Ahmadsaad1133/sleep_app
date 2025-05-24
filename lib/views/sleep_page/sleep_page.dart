import 'package:flutter/material.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF03174C), // Background color
      child: const Center(
        child: Text(
          'Sleep Page',
          style: TextStyle(
            color: Colors.white, // Changed to white for better contrast
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
