import 'package:flutter/material.dart';

class AppColors {
  static const cosmicPrimary = Color(0xFF5A6BC0);
  static const cosmicSecondary = Color(0xFF9D7BFE);
  static const cosmicBackground = Color(0xFF0D1B2A);
  static const cosmicSurface = Color(0xFF1E293B);
  static const cosmicText = Color(0xFFE0E7FF);

  // Quality colors
  static const excellentQuality = Color(0xFF4CAF50);
  static const goodQuality = Color(0xFF8BC34A);
  static const fairQuality = Color(0xFFFFC107);
  static const poorQuality = Color(0xFFF44336);
}

class AppDimens {
  static const pagePadding = EdgeInsets.all(16);
  static const sectionSpacing = 40.0;
  static const inputSpacing = 24.0;
  static const cardRadius = 20.0;
}

class AppTextStyles {
  static TextStyle sectionTitle(BuildContext context) {
    return TextStyle(
      color: Colors.blueGrey[200],
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.1,
      fontFamily: 'Comfortaa',
      shadows: const [
        Shadow(
          color: Colors.black26,
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  static TextStyle bodyText(BuildContext context) {
    return TextStyle(
      color: Colors.blueGrey[100],
      fontSize: 16,
      fontFamily: 'Comfortaa',
      height: 1.5,
    );
  }
}