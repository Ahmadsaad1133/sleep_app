import 'package:flutter/material.dart';

class BaseMusicPage extends StatelessWidget {
  final String title;
  final Widget? bodyContent;

  const BaseMusicPage({
    Key? key,
    required this.title,
    this.bodyContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03174C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: bodyContent ?? const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
