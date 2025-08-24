import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey = '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';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> fetchSleepMessage() async {
    debugPrint('GroqService: Starting request to $_apiUrl');
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "llama3-8b-8192",
        "messages": [
          {"role": "system", "content": "You are a sleep coach."},
          {"role": "user", "content": "Give me a one-line calming sleep affirmation."}
        ]
      }),
    );

    debugPrint('GroqService: HTTP status = ${response.statusCode}');
    debugPrint('GroqService: Raw response body = ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      final String content = jsonMap['choices']?[0]?['message']?['content'] as String? ?? '';
      debugPrint('GroqService: Parsed content → $content');
      return content;
    } else {
      final errorBody = response.body;
      debugPrint('GroqService: ERROR → HTTP ${response.statusCode}: $errorBody');
      throw Exception('Groq API call failed: HTTP ${response.statusCode}');
    }
  }
}
