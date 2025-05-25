// lib/views/sleep/sleep_flow_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:first_flutter_app/views/sleep_page/sleep_page.dart';
import 'package:first_flutter_app/views/welcome_sleep/welcome_sleep_page.dart';

class SleepFlowPage extends StatefulWidget {
  final ValueChanged<bool> onNavbarVisibilityChange;

  const SleepFlowPage({Key? key, required this.onNavbarVisibilityChange})
      : super(key: key);

  @override
  _SleepFlowPageState createState() => _SleepFlowPageState();
}

class _SleepFlowPageState extends State<SleepFlowPage> {
  bool _showSplash = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavbarVisibilityChange(false);
    });
    _timer = Timer(const Duration(seconds: 2), _proceedToSleep);
  }

  void _proceedToSleep() {
    if (!mounted) return;
    _timer?.cancel();
    setState(() => _showSplash = false);
    widget.onNavbarVisibilityChange(true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const WelcomeSleepPage();
    }
    return const SleepPage();
  }
}
