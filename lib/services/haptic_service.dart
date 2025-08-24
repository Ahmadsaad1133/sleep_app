// lib/services/haptic_service.dart
import 'package:flutter/services.dart';

class HapticService {
  static void lightImpact() => HapticFeedback.lightImpact();
  static void selectionClick() => HapticFeedback.selectionClick();
  static void mediumImpact() => HapticFeedback.mediumImpact();
}