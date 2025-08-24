import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  /// Unique identifier (e.g. Firestore document ID)
  final String id;

  final String title;
  final String imageUrl;
  final int durationMinutes;
  final String description;
  final String content;

  Story({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.durationMinutes,
    required this.description,
    required this.content,
  });

  /// Create from arbitrary JSON structure
  factory Story.fromJson(dynamic json) {
    // Normalize to Map
    Map<String, dynamic> rawMap;
    if (json is List && json.isNotEmpty) {
      rawMap = json.first as Map<String, dynamic>;
    } else if (json is Map<String, dynamic>) {
      rawMap = json;
    } else {
      throw Exception('Unexpected JSON format for Story');
    }

    // Unwrap nested "story" wrapper if present
    if (rawMap.containsKey('story') && rawMap['story'] is Map<String, dynamic>) {
      rawMap = rawMap['story'] as Map<String, dynamic>;
    }

    String extractText(dynamic field) {
      if (field == null) return '';
      if (field is String) {
        final str = field.trim();
        if ((str.startsWith('{') && str.endsWith('}')) ||
            (str.startsWith('[') && str.endsWith(']'))) {
          try {
            return extractText(jsonDecode(str));
          } catch (_) {}
        }
        return str;
      }
      if (field is List && field.isNotEmpty) return extractText(field.first);
      if (field is Map<String, dynamic>) {
        if (field.containsKey('text')) return extractText(field['text']);
        if (field.containsKey('en')) return extractText(field['en']);
        return extractText(field.values.first);
      }
      return field.toString().trim();
    }

    int parseDuration(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) {
        final n = num.tryParse(val);
        if (n != null) return n.toInt();
      }
      return 5; // default fallback
    }

    // Primary extraction
    String title = extractText(rawMap['title']);
    String description = extractText(rawMap['description']);
    String content = extractText(rawMap['content'] ?? rawMap['fullStory'] ?? rawMap['body']);
    String imageUrl = extractText(rawMap['imageUrl'] ?? rawMap['image_url'] ?? rawMap['image']);

    // Additional fallbacks
    if (title.isEmpty)       title = extractText(rawMap['name']);
    if (description.isEmpty) description = extractText(rawMap['desc']);
    if (content.isEmpty)     content = extractText(rawMap['body']);

    // Final defaults
    title       = title.isNotEmpty       ? title       : 'Untitled Story';
    description = description.isNotEmpty ? description : 'No description available';
    content     = content.isNotEmpty     ? content     : 'No content available';
    imageUrl    = imageUrl.startsWith('http') ? imageUrl : '';

    return Story(
      id: '', // caller should fill in a meaningful id, e.g. from API response
      title: title,
      imageUrl: imageUrl,
      durationMinutes: parseDuration(rawMap['durationMinutes'] ?? rawMap['duration']),
      description: description,
      content: content,
    );
  }

  /// Create from Firestore document
  factory Story.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Story',
      imageUrl: data['imageUrl'] as String? ?? '',
      durationMinutes: (data['durationMinutes'] as int?) ?? 0,
      description: data['description'] as String? ?? '',
      content: data['content'] as String? ?? data['fullStory'] as String? ?? '',
    );
  }

  /// Convert to JSON for Firestore (or API)
  Map<String, dynamic> toJson() => {
    'title': title,
    'imageUrl': imageUrl,
    'durationMinutes': durationMinutes,
    'description': description,
    'content': content,
  };

  @override
  String toString() {
    return 'Story(id: $id, title: $title, duration: $durationMinutes)';
  }
}
