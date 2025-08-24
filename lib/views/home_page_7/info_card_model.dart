import 'package:flutter/material.dart';

class InfoCardModel {
  final String imageAsset;
  final String title;
  final String subtitle;
  final bool isCourse;
  final Color backgroundColor;

  InfoCardModel({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.isCourse,
    required this.backgroundColor,
  });

  factory InfoCardModel.fromFirestore(Map<String, dynamic> data) {
    return InfoCardModel(
      imageAsset: data['imageAsset'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      isCourse: data['isCourse'] ?? false,
      backgroundColor: _parseColor(data['backgroundColor']),
    );
  }

  // Helper function to parse color string from Firestore
  static Color _parseColor(String? hexColor) {
    try {
      if (hexColor != null && hexColor.startsWith('0x')) {
        return Color(int.parse(hexColor));
      }
    } catch (_) {}
    return Colors.grey; // Default color if parsing fails
  }
}
