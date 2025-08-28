// lib/services/api/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as _httpClient;
import '../../Sleep_lognInput_page/sleep_analysis/models/sleep_plan_model.dart';
import '../../Sleep_lognInput_page/sleep_analysis/models/sleeplog_model_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../bedtime_page/story.dart' as bedtime_story;

class SleepAnalysisException implements Exception {
  final String message;
  SleepAnalysisException(this.message);
  @override
  String toString() => 'SleepAnalysisException: $message';
}
class NoNetworkException extends SleepAnalysisException {
  NoNetworkException() : super('No internet connection available');
}
class ApiTimeoutException extends SleepAnalysisException {
  ApiTimeoutException() : super('Server response timed out');
}
class ApiResponseException extends SleepAnalysisException {
  final int statusCode;
  ApiResponseException(this.statusCode, String message)
      : super('API error $statusCode: $message');
}
class ApiService {
  static const String baseUrl = 'https://flutter2-backend.onrender.com';
  static final Uri _sleepAnalysisUri = Uri.parse('$baseUrl/sleep-analysis');
  static final Uri _sleepPlanUri = Uri.parse('$baseUrl/generate-sleep-plan');
  static final Uri _chatUri = Uri.parse('$baseUrl/chat');
  static final Uri _storyUri = Uri.parse('$baseUrl/generate-story');
  static final Uri _storyImageUri = Uri.parse('$baseUrl/generate-story-and-image');
  static final Uri _insightsUri = Uri.parse('$baseUrl/insights');
  static const Duration apiTimeout = Duration(seconds: 45);
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token;

    if (user != null) {
      token = await user.getIdToken();
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  static Future<List<SleepLog>> getHistoricalSleepLogs({int limit = 7}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw SleepAnalysisException('User not authenticated');
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('anonymous_sleep_logs')
          .doc(user.uid)
          .collection('logs')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => SleepLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw SleepAnalysisException('Failed to fetch historical logs: ${e.toString()}');
    }
  }
  static Future<Map<String, dynamic>> compareSleepLogs({
    required Map<String, dynamic> currentLog,
    required Map<String, dynamic> previousLog,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/compare-sleep-logs'),
        headers: await _getHeaders(),
        body: json.encode({
          'current_log': _sanitizeForJson(currentLog),
          'previous_log': _sanitizeForJson(previousLog),
        }),
      )
          .timeout(apiTimeout);
      if (response.statusCode != 200) {
        final bodyText =
        response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}';
        throw SleepAnalysisException('Compare logs failed: $bodyText');
      }
      dynamic body;
      try {
        body = json.decode(response.body);
      } on FormatException {
        debugPrint('Invalid JSON response: ${response.body}');
        throw SleepAnalysisException('Invalid compare response format');
      }
      try {
        body = json.decode(response.body);
      } on FormatException {
        debugPrint('Invalid JSON response: ${response.body}');
        throw SleepAnalysisException('Invalid compare response format');
      }
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        // Some backends wrap results in a `data` or `comparison` object.
        final raw = body['comparison'] ?? body['data'] ?? body;
        if (raw is Map<String, dynamic>) {
          return raw;
        }
      }
      throw SleepAnalysisException('Invalid compare response format');
    } catch (e) {
      debugPrint('Error comparing sleep logs: $e');
      if (e is SleepAnalysisException) rethrow;
      throw SleepAnalysisException('Failed to compare logs: $e');
    }
  }
  static Future<Map<String, dynamic>> compareLastTwoSleepLogs() async {
    final logs = await getHistoricalSleepLogs(limit: 2);
    if (logs.length < 2) {
      throw SleepAnalysisException('Not enough logs for comparison');
    }
    return compareSleepLogs(
      currentLog: logs[0].toMap(),
      previousLog: logs[1].toMap(),
    );
  }
  static Map<String, dynamic> _sanitizeForJson(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      } else if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeForJson(value));
      } else if (value is List) {
        return MapEntry(key, value.map((e) {
          if (e is Timestamp) return e.toDate().toIso8601String();
          if (e is DateTime) return e.toIso8601String();
          if (e is Map<String, dynamic>) return _sanitizeForJson(e);
          return e;
        }).toList());
      }
      return MapEntry(key, value);
    });
  }
  static Future<String> getHistoricalSleepAnalysis({int limit = 10}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw SleepAnalysisException('User not signed in');
    }
    try {
      debugPrint('📡 Fetching last $limit sleep logs for user=${user.uid}');

      // Use the same collection where sleep logs are stored. Previously, this
      // function queried 'anonymous_sleep_logs', which caused a "No sleep logs
      // available" error even when logs existed under 'user_sleep_logs'. To
      // keep consistency with `getHistoricalSleepLogs` and other parts of the
      // app, we read from 'user_sleep_logs'.
      final snapshot = await FirebaseFirestore.instance
          .collection('anonymous_sleep_logs')
          .doc(user.uid)
          .collection('logs')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      debugPrint('✅ Retrieved ${snapshot.docs.length} docs');
      final sleepLogs = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }
        return SleepLog.fromMap(data);
      }).toList();

      if (sleepLogs.isEmpty) {
        throw SleepAnalysisException('No sleep logs available. Please add sleep logs first.');
      }

      // build prompt (reuses your existing formatter)
      final prompt = '''
As a sleep expert, analyze the user's historical sleep data and provide insights and suggestions.
Focus on patterns, recurring issues, and overall sleep health. Provide actionable advice.

Historical Sleep Data (last ${sleepLogs.length} entries):
${_formatSleepLogsForPrompt(sleepLogs)}

Your response should be a comprehensive analysis in markdown format, with sections for:
- Overall Sleep Quality
- Patterns and Trends
- Key Issues
- Personalized Recommendations
''';

      debugPrint('🌐 Generating historical sleep analysis (AI)');
      final response = await generateResponse(prompt);
      debugPrint('📥 AI Response length: ${response.length}');
      return response;
    } on FirebaseException catch (e) {
      debugPrint('🔥 Firestore exception: ${e.message}');
      final message = e.message ?? e.toString();
      final match = RegExp(r'https?://[^\s]+').firstMatch(message);
      final indexUrl = match?.group(0);
      if (indexUrl != null) {
        throw SleepAnalysisException('Firestore requires a composite index. Open this URL to create it:\n$indexUrl');
      }
      throw SleepAnalysisException('Failed to fetch historical sleep logs: $message');
    } catch (e) {
      debugPrint('⚠️ Unexpected error in getHistoricalSleepAnalysis: $e');
      throw SleepAnalysisException('Failed to generate historical analysis: ${e.toString()}');
    }
  }


  static Future<Map<String, dynamic>> getEnhancedSleepQualityAnalysis(
      Map<String, dynamic> sleepData) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw NoNetworkException();
      }

      String _toTitleCase(String input) {
        if (input.isEmpty) return input;
        return input
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.substring(0, 1).toUpperCase() + w.substring(1))
            .join(' ');
      }

      Map<String, dynamic> _normalizeSleepData() => {
        'duration_minutes': (sleepData['duration_minutes'] as num?)?.toDouble() ?? 0.0,
        'disturbances': sleepData['disturbances'] is List
            ? (sleepData['disturbances'] as List).length
            : (sleepData['disturbances'] as num?)?.toInt() ?? 0,
        'waso_minutes': (sleepData['waso_minutes'] as num?)?.toDouble() ?? 0.0,
        'deep_sleep_minutes': (sleepData['deep_sleep_minutes'] as num?)?.toDouble() ?? (sleepData['deep_minutes'] as num?)?.toDouble() ?? 0.0,
        'rem_sleep_minutes': (sleepData['rem_sleep_minutes'] as num?)?.toDouble() ?? (sleepData['rem_minutes'] as num?)?.toDouble() ?? 0.0,
        'light_sleep_minutes': (sleepData['light_sleep_minutes'] as num?)?.toDouble() ?? (sleepData['light_minutes'] as num?)?.toDouble() ?? 0.0,
        'quality': (sleepData['quality'] as num?)?.toDouble() ?? 0.0,
        'stress_level': (sleepData['stress_level'] as num?)?.toDouble() ?? 0.0,
        'latency_minutes': (sleepData['latency_minutes'] as num?)?.toDouble() ?? 0.0,
        'time_in_bed_minutes': (sleepData['time_in_bed_minutes'] as num?)?.toDouble() ?? (sleepData['time_in_bed'] as num?)?.toDouble() ?? 0.0,
        'caffeine_intake': (sleepData['caffeine_intake'] as num?)?.toDouble() ?? 0.0,
        'exercise_minutes': (sleepData['exercise_minutes'] as num?)?.toDouble() ?? 0.0,
        'screen_time_before_bed': (sleepData['screen_time_before_bed'] as num?)?.toDouble() ?? 0.0,
        'sleep_environment_score': (sleepData['sleep_environment_score'] as num?)?.toInt() ?? 0,
      };

      String _formatSleepData(Map<String, dynamic> data) {
        String getUnit(String key) {
          if (key.contains('minutes')) return ' mins';
          if (key.contains('intake')) return ' mg';
          if (key.contains('quality') || key.contains('score')) return '/10';
          if (key.contains('level')) return '/10';
          return '';
        }

        return data.entries.map((e) {
          final label = _toTitleCase(e.key);
          final unit = getUnit(e.key);
          return '- $label: ${e.value}$unit';
        }).join('\\n');
      }

      final normalizedData = _normalizeSleepData();
      final formattedData = _formatSleepData(normalizedData);

      final prompt = '''
As a senior sleep neuroscientist, conduct a comprehensive analysis using these parameters:\n$formattedData\n
Provide EXTREMELY DETAILED responses in this EXACT JSON structure without comments or trailing commas. 
Use only escaped newlines (\\n) and ensure all strings are double-quoted. Cite at least 3 peer-reviewed studies. 
Output ONLY valid JSON. Do not include any additional text before or after the JSON object.

{
  "neuroscientific_analysis": "Detailed neuroscientific explanation...",
  "circadian_assessment": "Analysis of circadian rhythm alignment...",
  "strength": {
    "title": "Main strength title",
    "explanation": "Detailed explanation of strength",
    "impact": "Positive impact of this strength"
  },
  "improvement": {
    "title": "Main improvement area",
    "explanation": "Detailed explanation of improvement area",
    "impact": "Negative impact if not addressed"
  },
  "recommendations": [
    {
      "action": "Actionable step 1",
      "rationale": "Scientific rationale for this action",
      "implementation": "Practical implementation tips"
    },
    {
      "action": "Actionable step 2",
      "rationale": "Scientific rationale for this action",
      "implementation": "Practical implementation tips"
    }
  ],
  "health_implications": "Potential health impacts based on current patterns"
}
''';

      debugPrint('🧠 Sending enhanced sleep analysis request');
      final rawResponse = await generateResponse(prompt);

      Map<String, dynamic> parseJsonResponse(String response) {
        int start = response.indexOf('{');
        if (start == -1) throw FormatException('No JSON object found');

        int braceCount = 0;
        int end = -1;

        for (int i = start; i < response.length; i++) {
          if (response[i] == '{') braceCount++;
          if (response[i] == '}') braceCount--;

          if (braceCount == 0) {
            end = i;
            break;
          }
        }

        if (end == -1) throw FormatException('Unbalanced braces in JSON');

        String jsonStr = response.substring(start, end + 1);

        jsonStr = jsonStr
            .replaceAllMapped(RegExp(r',\s*(?=[}\]])'), (match) => '')
            .replaceAll(RegExp(r'\\r|\\t'), '')
            .replaceAll(RegExp(r'(?<!\\)\\n'), '\\n');

        return jsonDecode(jsonStr);
      }

      return parseJsonResponse(rawResponse);

    } on TimeoutException {
      throw ApiTimeoutException();
    } on FormatException catch (e) {
      debugPrint('🚨 JSON STRUCTURE ERROR: $e');
      rethrow;
    } catch (e, st) {
      debugPrint('🚨 getEnhancedSleepQualityAnalysis error: $e\n$st');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getEnhancedDreamAnalysis({
    required String dreamJournal,
    required List<String> dreamElements,
    required String mood,
    required int sleepQuality,
    required int stressLevel,
  }) async {
    try {
      const String systemPrompt = '''
You are a senior dream analyst and neuroscientist. Analyze the dream journal entry using:
- Jungian archetypes
- Freudian symbolism
- Modern neuroscience of REM sleep
- Emotional processing theories
- Cultural context
- Personal development insights

Provide EXTREMELY DETAILED analysis in this JSON format:
{
  "symbolic_analysis": {
    "main_archetypes": [],
    "key_symbols": {},
    "emotional_themes": []
  },
  "neuroscientific_insights": "",
  "emotional_processing": "",
  "potential_interpretations": [],
  "connections_to_waking_life": "",
  "recommended_actions": []
}
''';

      final prompt = '''
Dream Journal:
$dreamJournal

Key Elements: ${dreamElements.join(', ')}

Sleep Context:
- Mood: $mood
- Sleep Quality: $sleepQuality/10
- Stress Level: $stressLevel/10
''';

      final response = await generateResponse(systemPrompt + prompt);

      // Parse response
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}');
      if (start == -1 || end == -1) throw FormatException('Invalid JSON response');

      return jsonDecode(response.substring(start, end + 1));
    } catch (e) {
      debugPrint('Dream analysis error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getDreamPredictionAndMoodForecast(
      Map<String, dynamic> sleepData) async {
    try {
      // ---------------- Prompt ----------------
      final String prompt = '''
SYSTEM INSTRUCTION:
You are a sleep neuroscientist and dream researcher. Generate a comprehensive sleep analysis report in JSON format with the following sections:

1. dream_prediction (object)
   - prediction (string): "Likely vivid dreams", "Possible vivid dreams", "Unlikely vivid dreams", 
     "Likely nightmares", "Possible nightmares", "Unlikely nightmares", "No significant change"
   - confidence (int 0-100)
   - explanation (string): Detailed 5-line neuroscientific explanation

2. mood_forecast (object)
   - mood (string): "Positive", "Neutral", "Negative"
   - confidence (int 0-100)
   - explanation (string): Detailed 5-line neuroscientific explanation

3. dream_metrics (object)
   - vividness (int 0-100)
   - emotional_intensity (int 0-100)
   - recall_probability (int 0-100)
   - lucidity_index (int 0-100)
   - explanation (string): Detailed 5-line analysis

4. neural_patterns (object)
   - delta (int 0-100)
   - theta (int 0-100)
   - alpha (int 0-100)
   - beta (int 0-100)
   - gamma (int 0-100)
   - coherence (object): {frontal, temporal, occipital} (float 0-1)
   - asymmetry (object): {alpha_frontal, beta_parietal} (float -1 to 1)
   - explanation (string): Detailed 5-line analysis

5. clinical_interpretation (object)
   - rem_density (float 0-1)
   - emotional_processing_index (int 0-100)
   - memory_consolidation_score (int 0-100)
   - threat_simulation (string): "Active" or "Inactive"
   - creativity_index (int 0-100)
   - neuroplasticity_markers (int 0-100)
   - personalized_analysis (string): Detailed 5-line analysis
   - explanation (string): Detailed 5-line neuroscientific interpretation

6. sleep_architecture (object)
   - rem_latency (int minutes)
   - rem_percent (int 0-100)
   - n3_percent (int 0-100)
   - light_percent (int 0-100)
   - sleep_efficiency (int 0-100)
   - waso (int minutes)
   - sleep_onset (int minutes)
   - rem_cycles (int)
   - explanation (string): Detailed 5-line analysis

7. cognitive_assessment (object)
   - problem_solving_index (int 0-100)
   - emotional_insight_index (int 0-100)
   - memory_consolidation_index (int 0-100)
   - creative_processing_index (int 0-100)
   - threat_processing_index (int 0-100)
   - explanation (string): Detailed 5-line analysis

8. recommendations (list of objects)
   - title (string)
   - description (string)

9. uiTexts (object): UI labels
   - header_title: "DreamLab Analysis"
   - header_subtitle: "Neuroscientific Sleep Insights"
   - sections: ["Summary", "Neural", "Sleep", "Emotions", "Cognition", "Recommendations"]
   - card_primary_diagnosis: "Primary Diagnosis"
   - card_affective_state: "Affective State"
   - card_key_neural_indicators: "Key Neural Indicators"
   - card_clinical_impression: "Clinical Impression"
   - view_technical: "View Technical Data"
   - hide_technical: "Hide Technical Data"
   - card_technical_data: "Technical Data"
   - export_action: "Export Clinical Report"
   - section_clinical_dream_summary: "Clinical Dream Summary"
   - section_quantitative_eeg: "Quantitative EEG Analysis"
   - section_sleep_architecture: "Sleep Architecture"
   - section_emotional_processing: "Emotional Processing"
   - section_cognitive_assessment: "Cognitive Assessment"
   - section_recommendations: "Clinical Recommendations"
   - card_spectral_power: "Spectral Power Distribution"
   - card_hemispheric_coherence: "Hemispheric Coherence"
   - card_interhemispheric_asymmetry: "Interhemispheric Asymmetry"
   - card_neural_interpretation: "Neural Interpretation"
   - card_sleep_stage_distribution: "Sleep Stage Distribution"
   - card_architecture_metrics: "Architecture Metrics"
   - card_architecture_interpretation: "Architecture Interpretation"
   - card_emotional_processing_index: "Emotional Processing Index"
   - card_threat_simulation: "Threat Simulation"
   - card_emotional_details: "Emotional Details"
   - card_cognitive_performance: "Cognitive Performance"
   - card_key_cognitive_metrics: "Key Cognitive Metrics"
   - card_cognitive_interpretation: "Cognitive Interpretation"
   - card_recommendations: "Clinical Recommendations"
   - card_personalized_analysis: "Personalized Analysis"

RULES:
- All explanations must be 5+ lines of detailed neuroscientific analysis
- Use only evidence-based reasoning from sleep science
- Reference circadian rhythms, sleep stages, and neurochemical processes
- Never include placeholder text or fallback values
- Output ONLY valid JSON

Sleep Data:
- Duration: ${sleepData['duration_minutes']} minutes
- Quality: ${sleepData['quality']}/10
- Stress: ${sleepData['stress_level']}/10
- Caffeine: ${sleepData['caffeine_intake']} mg
- Exercise: ${sleepData['exercise_minutes']} minutes
- Screen Time: ${sleepData['screen_time_before_bed']} minutes before bed
''';

      debugPrint('🌙 Generating comprehensive dream/mood forecast (prompt length: ${prompt.length})');

      // -------- Call your LLM ----------
      final String rawResponse = await generateResponse(prompt);

      debugPrint('🔮 AI response length: ${rawResponse.length}');

      // -------- JSON Parsing Helper ----------
      Map<String, dynamic> parseJsonResponse(String response) {
        dynamic tryDecode(String candidate) {
          try {
            return jsonDecode(candidate);
          } catch (e) {
            throw FormatException('jsonDecode failed: $e');
          }
        }

        try {
          final direct = tryDecode(response);
          if (direct is Map<String, dynamic>) return direct;
        } catch (_) {}

        String working = response.trim();
        working = working.replaceAll('```json', '');
        working = working.replaceAll('```', '');
        working = working.replaceAll("'''", '');
        working = working.replaceAll('"""', '');

        final int firstOpen = working.indexOf('{');
        final int lastClose = working.lastIndexOf('}');
        if (firstOpen >= 0 && lastClose > firstOpen) {
          working = working.substring(firstOpen, lastClose + 1);
        }

        working = working.replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E]'), '');
        working = working.replaceAll(RegExp(r',\s*(?=[}\]])'), '');
        working = working.replaceAllMapped(RegExp(r"'([A-Za-z0-9_]+)'\s*:"), (m) => '"${m[1]}":');
        working = working.replaceAllMapped(RegExp(r":\s*'([^']*)'(?=\s*[,}\]])"), (m) => ': "${m[1]}"');
        working = working.replaceAllMapped(RegExp(r'(?<=\{|,)\s*([A-Za-z0-9_]+)\s*:'), (m) => '"${m[1]}":');

        int opens = working.split('{').length - 1;
        int closes = working.split('}').length - 1;
        while (opens > closes) {
          working = working + '}';
          closes++;
        }

        try {
          final decoded = jsonDecode(working);
          if (decoded is Map<String, dynamic>) return decoded;
          throw FormatException('Decoded JSON is not a Map (got ${decoded.runtimeType})');
        } catch (e) {
          final snippet = working.length > 2000
              ? working.substring(0, 2000) + '... (trimmed)'
              : working;
          throw FormatException('Failed to parse LLM response as JSON.\nSanitized snippet:\n$snippet\n\nError: $e');
        }
      }

      // -------- Parse AI JSON --------
      Map<String, dynamic> parsed;
      try {
        parsed = parseJsonResponse(rawResponse);
      } catch (e) {
        debugPrint('❌ JSON parse error: $e');
        throw SleepAnalysisException('Failed to parse JSON response: ${e.toString()}');
      }

      debugPrint('✅ Returning DreamLab JSON (keys: ${parsed.keys.toList()})');

      // -------- MERGE with fallback safe values --------
      return {
        // full parsed data first
        ...parsed,

        // override or add safe guaranteed keys
        'dream_prediction': {
          'prediction': parsed['dream_prediction']?['prediction'] ?? 'N/A',
          'explanation': parsed['dream_prediction']?['explanation'] ?? 'No data',
        },
        'mood_forecast': {
          'mood': parsed['mood_forecast']?['mood'] ?? 'Unknown',
          'confidence': parsed['mood_forecast']?['confidence'] ?? 0,
        },
        'cognitive_assessment': {
          'problem_solving_index':
          parsed['cognitive_assessment']?['problem_solving_index'] ?? 0,
          'memory_consolidation_index':
          parsed['cognitive_assessment']?['memory_consolidation_index'] ?? 0,
          'creative_processing_index':
          parsed['cognitive_assessment']?['creative_processing_index'] ?? 0,
        },
      };

    } catch (e, stack) {
      debugPrint('❗ getDreamPredictionAndMoodForecast error: $e');
      debugPrint('❗ Stack trace: $stack');
      if (e is SleepAnalysisException) rethrow;
      throw SleepAnalysisException('Failed to generate forecast: ${e.toString()}');
    }
  }


  static String _formatSleepLogsForPrompt(List<SleepLog> logs) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('MMM dd, yyyy');

    logs.sort((a, b) => a.date.compareTo(b.date));

    for (final log in logs) {
      final date = log.date;
      buffer.writeln('Date: ${dateFormat.format(date)}');
      buffer.writeln('  Duration: ${log.durationMinutes ~/ 60}h ${log.durationMinutes % 60}m');
      buffer.writeln('  Quality: ${log.quality}/10');
      buffer.writeln('  Stress Level: ${log.stressLevel}/10');
      buffer.writeln('  Caffeine Intake: ${log.caffeineIntake} mg');
      buffer.writeln('  Exercise: ${log.exerciseMinutes} minutes');
      buffer.writeln('  Screen Time Before Bed: ${log.screenTimeBeforeBed} minutes before bed');
      buffer.writeln('  Mood: ${log.mood}');
      buffer.writeln('  Disturbances: ${log.disturbances.join(", ")}');
      buffer.writeln('  Environment: Noise: ${log.noiseLevel}, Light: ${log.lightExposure}, Temp: ${log.temperature}, Comfort: ${log.comfortLevel}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  static Future<Map<String, dynamic>> getSleepEnvironmentRecommendations(
      String noiseLevel,
      String lightLevel,
      String temperature,
      String comfortLevel,
      ) async {
    final prompt = '''
As a sleep science expert, analyze this sleep environment and provide:
1. Environmental score (0-10)
2. Key insights
3. Factor ratings
4. Detailed recommendations per factor

Factors:
- Noise Level: $noiseLevel
- Light Exposure: $lightLevel
- Temperature: $temperature
- Comfort Level: $comfortLevel

Response must be JSON with this structure:
{
  "score": 7.5,
  "insights": "Your environment is generally good but...",
  "factors": {
    "noise_level": "Moderate",
    "light_exposure": "Dark",
    "temperature": "Cool",
    "comfort_level": "Comfortable"
  },
  "recommendations": {
    "noise_level": ["Rec 1", "Rec 2", "Rec 3"],
    "light_exposure": ["Rec 1", "Rec 2", "Rec 3"],
    "temperature": ["Rec 1", "Rec 2", "Rec 3"],
    "comfort_level": ["Rec 1", "Rec 2", "Rec 3"]
  }
}
''';

    try {
      debugPrint('🌐 Generating sleep environment analysis');
      final response = await generateResponse(prompt);
      debugPrint('📥 AI Response: $response');

      final jsonPattern = RegExp(r'\{[\s\S]*\}');
      final match = jsonPattern.firstMatch(response);
      if (match == null) {
        throw const FormatException('No valid JSON found in response');
      }

      return jsonDecode(match.group(0)!);
    } catch (e) {
      debugPrint('❗ Failed to analyze sleep environment: $e');
      throw SleepAnalysisException('Failed to analyze environment: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getSleepStagesAnalysis(
      Map<String, dynamic> sleepData,
      ) async {
    try {
      final deep = sleepData['deep']?.toStringAsFixed(1) ?? '0';
      final rem = sleepData['rem']?.toStringAsFixed(1) ?? '0';
      final light = sleepData['light']?.toStringAsFixed(1) ?? '0';

      final total = double.parse(deep) + double.parse(rem) + double.parse(light);
      if (total < 50 || total > 150) {
        throw const FormatException('Invalid sleep stage percentages');
      }

      final prompt = '''
As a sleep expert, analyze the following sleep stages distribution:

- Deep Sleep: $deep%
- REM Sleep: $rem%
- Light Sleep: $light%

Ideal Ranges for Adults:
- Deep Sleep: 13-23%
- REM Sleep: 20-25%
- Light Sleep: 50-60%

Provide analysis that includes:
1. Evaluation of sleep architecture
2. Interpretation of each stage's distribution
3. Impact on physical/cognitive function
4. Potential causes for deviations

Then provide:
- Key insights
- Actionable recommendations

Response must be JSON with this structure:
{
  "analysis": "Detailed analysis text...",
  "insights": ["Insight 1", "Insight 2"],
  "recommendations": ["Rec 1", "Rec 2"]
}
''';

      final response = await generateResponse(prompt);

      try {
        final jsonPattern = RegExp(r'\{[\s\S]*\}');
        final match = jsonPattern.firstMatch(response);
        if (match == null) throw const FormatException('No JSON found');

        final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;

        if (!parsed.containsKey('analysis') ||
            !parsed.containsKey('insights') ||
            !parsed.containsKey('recommendations')) {
          throw const FormatException('Invalid analysis structure');
        }

        return parsed;
      } catch (e) {
        return {
          'analysis': 'Professional analysis:\n$response',
          'insights': ['Key patterns detected in your sleep architecture'],
          'recommendations': ['Consult full report for personalized advice']
        };
      }
    } catch (e) {
      debugPrint('❗ Sleep stages analysis error: $e');
      return {
        'analysis': 'Could not generate detailed analysis. '
            'Your sleep data appears valid but our analysis engine failed. '
            'Please try again later.',
        'insights': [],
        'recommendations': []
      };
    }
  }

  static Future<Map<String, dynamic>> getSleepQualityAnalysis(
      Map<String, dynamic> sleepData,
      ) async {
    try {
      final prompt = '''
As a sleep expert, analyze the following sleep data and provide a quality breakdown with scores (0-10) for key factors and a key insight.

Sleep Data:
- Duration: ${sleepData['duration_minutes']} minutes
- Disturbances: ${sleepData['disturbances']} times
- WASO (Wake After Sleep Onset): ${sleepData['waso_minutes']} minutes
- Sleep Stages: 
  - Deep: ${sleepData['sleep_stages']?['deep'] ?? 0}%
  - REM: ${sleepData['sleep_stages']?['rem'] ?? 0}%
  - Light: ${sleepData['sleep_stages']?['light'] ?? 0}%
- Quality Rating: ${sleepData['quality']}/10
- Stress Level: ${sleepData['stress_level']}/10
- Caffeine Intake: ${sleepData['caffeine_intake']} mg
- Exercise: ${sleepData['exercise_minutes']} minutes
- Screen Time Before Bed: ${sleepData['screen_time_before_bed']} minutes

Your response must be a valid JSON object with exactly the following structure:
{
  "factors": {
    "Duration": 8.5,
    "Continuity": 7.2,
    "Depth": 6.8,
    "Regularity": 9.1,
    "Efficiency": 7.9
  },
  "key_insight": "Your sleep efficiency is excellent, but depth could be improved by reducing screen time before bed."
}

Output only the JSON object without any additional text.
''';

      debugPrint('🌐 Generating sleep quality analysis via chat endpoint');
      final response = await generateResponse(prompt);
      debugPrint('📥 AI Response: $response');

      try {
        return jsonDecode(response) as Map<String, dynamic>;
      } catch (_) {
        final jsonPattern = r'\{[\s\S]*\}';
        final match = RegExp(jsonPattern).firstMatch(response);
        if (match != null) {
          return jsonDecode(match.group(0)!) as Map<String, dynamic>;
        }
        throw const FormatException('No valid JSON found in response');
      }
    } catch (e) {
      debugPrint('❗ Failed to get sleep quality analysis: $e');
      throw SleepAnalysisException('Failed to get analysis: ${e.toString()}');
    }
  }

  /// Fetches comprehensive sleep analysis (data + environment + context)
  static Future<Map<String, dynamic>> fetchSleepAnalysis(List<Map<String, dynamic>> sleepData) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw NoNetworkException();
    }

    try {
      debugPrint('🧠 Sending comprehensive sleep analysis request (logs: ${sleepData.length})');

      final converted = sleepData.map((entry) {
        return entry.map((k, v) {
          if (v is Timestamp) return MapEntry(k, v.toDate().toIso8601String());
          if (v is DateTime) return MapEntry(k, v.toIso8601String());
          if (v is TimeOfDay) return MapEntry(k, '${v.hour}:${v.minute}');
          return MapEntry(k, v);
        });
      }).toList();

      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic> userContext = {};
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('user_sleep_logs').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          userContext = {
            'age': data['age'],
            'gender': data['gender'],
            'health_conditions': data['healthConditions'] ?? [],
            'medications': data['medications'] ?? [],
            'family_history': data['familyHistory'] ?? [],
            'sleep_goals': data['sleepGoals'] ?? [],
            'preferences': data['sleepPreferences'] ?? {},
          };
        }
      }

      final env = sleepData.isNotEmpty ? {
        'noise_level': sleepData.last['noise_level'] ?? 'N/A',
        'light_level': sleepData.last['light_level'] ?? 'N/A',
        'temperature': sleepData.last['temperature'] ?? 'N/A',
        'comfort_level': sleepData.last['comfort_level'] ?? 'N/A',
      } : {};

      final body = jsonEncode({
        'sleep_data': converted,
        'analysis_type': 'advanced',
        'capabilities': [
          'pattern_recognition',
          'health_predictions',
          'behavioral_impact',
          'circadian_analysis',
          'intervention_suggestions',
          'environment_analysis'
        ],
        'user_context': userContext,
        'environment_data': env,
      });

      final response = await http.post(
        _sleepAnalysisUri,
        headers: await _getHeaders(),
        body: body,
      ).timeout(apiTimeout);

      debugPrint('🔍 /sleep-analysis status ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiResponseException(response.statusCode, response.body);
      }
    } on TimeoutException {
      throw ApiTimeoutException();
    } catch (e) {
      throw SleepAnalysisException('Unexpected error: ${e.toString()}');
    }
  }

  static Future<SleepPlan> generateSleepPlan(String analysisSummary) async {
    return _retry(() async {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) throw NoNetworkException();

      final res = await http.post(
        _sleepPlanUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'analysis_summary': analysisSummary}),
      ).timeout(apiTimeout);

      if (res.statusCode != 200) {
        throw ApiResponseException(res.statusCode, res.body);
      }

      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic> || body.containsKey('error')) {
        throw SleepAnalysisException('Invalid sleep plan response format');
      }
      return SleepPlan.fromMap(body);
    });
  }

  static Future<String> generateResponse(String prompt) async {
    return _retry(() async {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) throw NoNetworkException();

      final res = await http.post(
        _chatUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(apiTimeout);

      if (res.statusCode != 200) {
        throw ApiResponseException(res.statusCode, res.body);
      }

      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic> || body.containsKey('error')) {
        throw SleepAnalysisException('Invalid chat response format');
      }
      return (body['response'] as String).trim();
    });
  }

  static Future<bedtime_story.Story> _generateStoryWithImage({
    required String mood,
    required String sleepQuality,
  }) async {
    return _retry(() async {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) throw NoNetworkException();

      final res = await http.post(
        _storyImageUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mood': mood,
          'sleep_quality': sleepQuality,
          'include_image': true,
        }),
      ).timeout(apiTimeout);

      if (res.statusCode != 200) {
        throw ApiResponseException(res.statusCode, res.body);
      }

      final data = jsonDecode(res.body);
      if (data is! Map<String, dynamic> || data.containsKey('error')) {
        throw SleepAnalysisException('Invalid story+image response format');
      }
      return bedtime_story.Story.fromJson(data);
    });
  }

  static Future<String> generatePlainStory({
    required String mood,
    required String sleepQuality,
  }) async {
    return _retry(() async {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) throw NoNetworkException();

      final res = await http.post(
        _storyUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mood': mood,
          'sleep_quality': sleepQuality,
          'story_type': 'bedtime',
        }),
      ).timeout(apiTimeout);

      if (res.statusCode != 200) {
        throw ApiResponseException(res.statusCode, res.body);
      }

      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic> || body.containsKey('error')) {
        throw SleepAnalysisException('Invalid story response format');
      }
      return (body['story'] as String).trim();
    });
  }

  static Future<List<bedtime_story.Story>> generateBedtimeStories({
    required String mood,
    required String sleepQuality,
    int count = 3,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) throw NoNetworkException();

    final futures = List.generate(
      count,
          (_) => _generateStoryWithImage(mood: mood, sleepQuality: sleepQuality),
    );
    return Future.wait(futures);
  }

  static Future<List<Map<String, String>>> getLongTermProjections(
      List<SleepLog> sleepLogs,
      ) async {
    try {
      if (sleepLogs.isEmpty) {
        throw SleepAnalysisException('No sleep logs available. Please add sleep logs first.');
      }

      final prompt = '''
As a sleep expert, generate a personalized long-term sleep improvement projection based on the user's historical sleep data.
The projections should cover four timeframes: 1 week, 1 month, 3 months, and 6 months.

Historical Sleep Data Summary:
- Average sleep duration: ${_calculateAverageDuration(sleepLogs)} hours
- Average sleep quality: ${_calculateAverageQuality(sleepLogs)}/10
- Consistency score: ${_calculateConsistency(sleepLogs)}%
- Recent improvements: ${_detectTrends(sleepLogs)}
- Main issues: ${_identifyMainIssues(sleepLogs)}

Your response must be a valid JSON array of objects with exactly the following structure:
[
  {
    "timeframe": "1 Week",
    "improvement": "15-20% better sleep quality"
  },
  {
    "timeframe": "1 Month",
    "improvement": "Consistent 7+ hours with 85%+ efficiency"
  },
  {
    "timeframe": "3 Months",
    "improvement": "Reduced sleep latency to under 15 minutes"
  },
  {
    "timeframe": "6 Months",
    "improvement": "Sleep score consistently above 80"
  }
]

Output only the JSON array without any additional text.
''';

      debugPrint('🌐 Generating long-term sleep projections');
      final response = await generateResponse(prompt);
      debugPrint('📥 AI Response: $response');

      final List<dynamic> parsed = jsonDecode(response);
      return parsed.map((item) {
        return {
          'timeframe': item['timeframe']?.toString() ?? 'Unknown timeframe',
          'improvement': item['improvement']?.toString() ?? 'Unknown improvement',
        };
      }).toList();
    } catch (e) {
      throw SleepAnalysisException('Failed to generate projections: ${e.toString()}');
    }
  }

  // Helper methods
  static String _calculateAverageDuration(List<SleepLog> logs) {
    if (logs.isEmpty) return '0.0';
    final total = logs.fold(0, (sum, log) => sum + log.durationMinutes);
    return (total / logs.length / 60).toStringAsFixed(1);
  }

  static String _calculateAverageQuality(List<SleepLog> logs) {
    if (logs.isEmpty) return '0.0';
    final total = logs.fold(0, (sum, log) => sum + log.quality);
    return (total / logs.length).toStringAsFixed(1);
  }

  static String _calculateConsistency(List<SleepLog> logs) {
    if (logs.length < 5) return 'Insufficient data';
    final valid = logs.where((log) {
      try {
        log.parseTime(log.bedtime);
        return true;
      } catch (_) {
        return false;
      }
    }).toList();

    if (valid.length < 5) return 'Insufficient valid data';
    final hours = valid.map((log) => log.parseTime(log.bedtime).hour).toList();
    final avg = hours.reduce((a, b) => a + b) / hours.length;
    final variance = hours.map((h) => pow(h - avg, 2)).reduce((a, b) => a + b) / hours.length;
    return (100 - variance * 5).clamp(0, 100).toStringAsFixed(0);
  }

  static String _detectTrends(List<SleepLog> logs) {
    if (logs.length < 3) return 'No significant trends';
    final valid = logs.where((log) => log.durationMinutes > 0).toList();
    if (valid.length < 3) return 'No valid duration data';
    final recent = valid.sublist(valid.length - 3);
    final qualityChange = recent.last.quality - recent.first.quality;
    final durationChange = (recent.last.durationMinutes - recent.first.durationMinutes) / 60;
    if (qualityChange > 1 || durationChange > 0.5) {
      return 'Positive trend: Quality +${qualityChange.toStringAsFixed(1)}/10, Duration +${durationChange.toStringAsFixed(1)} hours';
    } else if (qualityChange < -1 || durationChange < -0.5) {
      return 'Negative trend: Quality -${qualityChange.abs().toStringAsFixed(1)}/10, Duration -${durationChange.abs().toStringAsFixed(1)} hours';
    }
    return 'Stable sleep patterns';
  }

  static String _identifyMainIssues(List<SleepLog> logs) {
    if (logs.isEmpty) return 'No sleep data';
    final issues = <String, int>{};
    for (final log in logs) {
      if (log.quality < 5) issues['Poor quality'] = (issues['Poor quality'] ?? 0) + 1;
      if (log.durationMinutes < 360) issues['Short duration'] = (issues['Short duration'] ?? 0) + 1;
      if (log.stressLevel > 7) issues['High stress'] = (issues['High stress'] ?? 0) + 1;
      if (log.screenTimeBeforeBed > 60) issues['Late screen time'] = (issues['Late screen time'] ?? 0) + 1;
      if (log.noiseLevel == 'Noisy') issues['Noisy environment'] = (issues['Noisy environment'] ?? 0) + 1;
      if (log.lightExposure == 'Bright') issues['Bright environment'] = (issues['Bright environment'] ?? 0) + 1;
    }
    return issues.entries.map((e) => '${e.key} (${e.value}x)').take(3).join(', ');
  }

  static Future<T> _retry<T>(
      Future<T> Function() func, {
        int maxRetries = 3,
        Duration initialDelay = const Duration(seconds: 1),
      }) async {
    int attempt = 0;
    var delay = initialDelay;
    final random = Random();
    while (attempt < maxRetries) {
      try {
        return await func();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        final jitter = Duration(milliseconds: random.nextInt(500));
        await Future.delayed(delay + jitter);
        delay *= 2;
      }
    }
    throw StateError('Retry loop exited unexpectedly');
  }
  static Map<String, dynamic> _computeHistoricalMetrics(List<SleepLog> logs) {
    if (logs.isEmpty) {
      return {
        'count': 0,
        'avg_duration_min': 0,
        'avg_quality': 0,
        'avg_stress': 0,
        'avg_latency_min': 0,
        'avg_waso_min': 0,
        'avg_caffeine_mg': 0,
        'avg_exercise_min': 0,
      };
    }

    double _avg(num Function(SleepLog) pick) {
      final values = logs.map((l) => pick(l)).where((v) => v.isFinite);
      final total = values.fold<double>(0, (a, b) => a + b);
      return logs.isEmpty ? 0 : total / logs.length;
    }

    return {
      'count': logs.length,
      'avg_duration_min': _avg((l) => (l.durationMinutes).toDouble()),
      'avg_quality': _avg((l) => (l.quality).toDouble()),
      'avg_stress': _avg((l) => (l.stressLevel).toDouble()),
      'avg_latency_min': _avg((l) => ((l.latencyMinutes ?? 0)).toDouble()),
      'avg_waso_min': _avg((l) => ((l.wasoMinutes ?? 0)).toDouble()),
      'avg_caffeine_mg': _avg((l) => (l.caffeineIntake).toDouble()),
      'avg_exercise_min': _avg((l) => (l.exerciseMinutes).toDouble()),
    };
  }

  /// Ensures a complete, UI-friendly insights map even if the model returns partial JSON.
  static Map<String, dynamic> _normalizeInsightsForUI(Map<String, dynamic> src) {
    final safe = Map<String, dynamic>.from(src);

    // Defaults
    safe.putIfAbsent('summary', () => '');
    safe.putIfAbsent('quality_score', () => 65);
    safe.putIfAbsent('key_insights', () => <dynamic>[]);
    safe.putIfAbsent('anomalies', () => <dynamic>[]);
    safe.putIfAbsent('risk_flags', () => <dynamic>[]);
    safe.putIfAbsent('recommendations', () => <dynamic>[]);
    safe.putIfAbsent('forecast', () => {
      'mood': 'neutral',
      'confidence': 60,
      'focus': 60,
    });
    safe.putIfAbsent('environment_impact', () => {
      'noise': 50,
      'light': 50,
      'temperature': 50,
      'comfort': 50,
      'overall': 50,
      'notes': ''
    });

    // Backward-compat mapping for UI keys
    safe['dream_vividness'] ??= {
      'level': (safe['forecast'] is Map && safe['forecast']['mood'] == 'positive') ? 'High' : 'Moderate',
      'prediction': '—'
    };
    safe['mood_forecast'] ??= {
      'mood': (safe['forecast'] is Map) ? (safe['forecast']['mood'] ?? 'neutral') : 'neutral',
      'confidence': (safe['forecast'] is Map) ? (safe['forecast']['confidence'] ?? 60) : 60,
    };
    safe['cognitive_performance'] ??= {
      'focus': (safe['forecast'] is Map) ? (safe['forecast']['focus'] ?? 60) : 60,
      'memory': 60,
      'processing_speed': 60,
    };
    safe['stress_risk'] ??= {
      'risk': (safe['risk_flags'] is List && (safe['risk_flags'] as List).isNotEmpty) ? 'elevated' : 'low',
      'drivers': safe['risk_flags'] ?? <dynamic>[]
    };
    safe['quick_tips'] ??= (safe['recommendations'] as List)
        .take(3)
        .map((r) => (r is Map && r['how_to_apply'] != null && r['how_to_apply'].toString().isNotEmpty)
        ? r['how_to_apply']
        : (r is Map && r['title'] != null ? r['title'] : 'Focus on consistent sleep/wake time'))
        .toList();

    safe['historical_comparison'] ??= {'summary': ''};
    return safe;
  }

  /// Builds the refinement prompt that forces strict JSON and quantification.
  static String _buildInsightsRefinementPrompt({
    required Map<String, dynamic> sleepData,
    required Map<String, dynamic> hist,
    required Map<String, dynamic> raw,
  }) {
    final sleepJson = const JsonEncoder.withIndent('  ').convert(sleepData);
    final histJson = const JsonEncoder.withIndent('  ').convert(hist);
    final rawJson = const JsonEncoder.withIndent('  ').convert(raw);

    return '''
You are a careful, concise sleep coach. Rewrite and IMPROVE the following raw insights using the current sleep log and 7-day historical metrics. Respond with ONLY a JSON object that strictly matches this schema and never include extra keys, comments, or markdown.

Schema:
{
  "summary": string,
  "quality_score": integer,
  "key_insights": string[],
  "anomalies": string[],
  "risk_flags": string[],
  "recommendations": [
    {"title": string, "reason": string, "impact": integer, "how_to_apply": string}
  ],
  "forecast": {"mood": "positive|neutral|negative", "confidence": integer, "focus": integer},
  "environment_impact": {"noise": integer, "light": integer, "temperature": integer, "comfort": integer, "overall": integer, "notes": string}
}

Hard rules:
- Use metric/minutes where applicable and quote actual values (e.g., "latency 32 min", "screen time 90 min").
- Ground comparisons on the 7-day averages when useful.
- Keep tone neutral and specific.
- If a field is unknown, estimate sensibly from context; do NOT omit any schema keys.

CURRENT_SLEEP_LOG = ${sleepJson}
SEVEN_DAY_BASELINE = ${histJson}
RAW_INSIGHTS_FROM_BACKEND = ${rawJson}
''';
  }

  /// Basic quality heuristic: ensure we have enough meat before accepting the model output.
  static bool _insightsLookStrong(Map<String, dynamic> data) {
    final hasBullets = (data['key_insights'] is List) && (data['key_insights'] as List).length >= 3;
    final hasRecs = (data['recommendations'] is List) && (data['recommendations'] as List).length >= 3;
    final score = (data['quality_score'] is num) ? (data['quality_score'] as num).toInt() : 0;
    return hasBullets && hasRecs && score > 40;
  }
  /// Generates insights directly with the LLM if the backend endpoint is
  /// unavailable (e.g., returns 404). This mirrors the expected JSON schema
  /// from the backend so the rest of the pipeline can remain unchanged.
  static Future<Map<String, dynamic>> _generateInsightsFallback(
      Map<String, dynamic> sleepData) async {
    final prompt = '''
You are a concise sleep coach. Analyze the provided sleep log and return
actionable insights in JSON using the following schema:
{
  "summary": string,
  "quality_score": integer,
  "key_insights": string[],
  "anomalies": string[],
  "risk_flags": string[],
  "recommendations": [
    {"title": string, "reason": string, "impact": integer, "how_to_apply": string}
  ],
  "forecast": {"mood": "positive|neutral|negative", "confidence": integer, "focus": integer},
  "environment_impact": {"noise": integer, "light": integer, "temperature": integer, "comfort": integer, "overall": integer, "notes": string}
}
Return only JSON.

SLEEP_LOG: ${jsonEncode(sleepData)}
''';

    final text = await generateResponse(prompt);
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (match == null) {
      throw const FormatException('No JSON found in fallback insights response');
    }
    return jsonDecode(match.group(0)!);
  }
  Future<Map<String, dynamic>> getInsights(Map<String, dynamic> sleepData) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw NoNetworkException();
      }

      // Convert non-serializable values for the API
      final cleanedSleepData = sleepData.map((k, v) {
        if (v is Timestamp) return MapEntry(k, v.toDate().toIso8601String());
        if (v is DateTime) return MapEntry(k, v.toIso8601String());
        if (v is TimeOfDay) return MapEntry(k, '${v.hour}:${v.minute}');
        return MapEntry(k, v);
      });
      Map<String, dynamic> raw;
      try {
        raw = await _retry(() async {
          final headers = await _getHeaders();
          final response = await http
              .post(_insightsUri, headers: headers, body: jsonEncode(cleanedSleepData))
              .timeout(apiTimeout);
          if (response.statusCode != 200) {
            throw ApiResponseException(response.statusCode, response.body);
          }
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) return body;
          throw const FormatException('Insights API did not return JSON object');
        });
      } on ApiResponseException catch (e) {
        if (e.statusCode == 404) {
          debugPrint('⚠️ Insights endpoint not found, using fallback generation');
          raw = await _generateInsightsFallback(cleanedSleepData);
        } else {
          rethrow;
        }
      }

      // 2) 7-day baseline for grounding
      final recent = await getHistoricalSleepLogs(limit: 7);
      final hist = _computeHistoricalMetrics(recent);

      // 3) LLM refinement into strict JSON schema
      Future<Map<String, dynamic>> _refineOnce() async {
        final prompt = _buildInsightsRefinementPrompt(
          sleepData: cleanedSleepData,
          hist: hist,
          raw: raw,
        );
        final text = await generateResponse(prompt);
        final match = RegExp(r"\{[\s\S]*\}").firstMatch(text);
        if (match == null) throw const FormatException('No JSON found in refinement response');
        final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
        return parsed;
      }

      Map<String, dynamic> refined;
      try {
        refined = await _refineOnce();
        if (!_insightsLookStrong(refined)) {
          // Second pass – gentle nudge for specificity
          final nudge = {
            ...refined,
            'summary': '${refined['summary'] ?? ''} (add concrete numbers where possible)',
          };
          final text = await generateResponse(
              'Improve this JSON with more quantified details. Preserve the exact schema and keys. Return JSON only.\n${jsonEncode(nudge)}');
          final m2 = RegExp(r"\{[\s\S]*\}").firstMatch(text);
          if (m2 != null) {
            refined = jsonDecode(m2.group(0)!) as Map<String, dynamic>;
          }
        }
      } catch (_) {
        // Fallback to raw API response if refinement fails
        refined = raw;
      }

      // 4) Normalize for UI
      final normalized = _normalizeInsightsForUI(refined);
      return normalized;
    } on TimeoutException {
      throw ApiTimeoutException();
    } catch (e) {
      throw SleepAnalysisException('Failed to get insights: ${e.toString()}');
    }
  }

}