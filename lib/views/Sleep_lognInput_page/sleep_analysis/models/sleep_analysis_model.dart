import 'package:cloud_firestore/cloud_firestore.dart';

class SleepAnalysis {
  final int sleepScore;
  final Map<String, dynamic> sleepMetrics;
  final Map<String, double> sleepStages;
  final String detailedReport;
  final List<String> recommendations;
  final Map<String, dynamic> sleepPatterns;
  final List<String> predictiveWarnings;
  final Map<String, dynamic> behavioralFactors;
  final String chronotype;
  final String sleepMidpoint;
  final List<Map<String, dynamic>> interventions;
  final Map<String, dynamic> sleepEfficiencyAnalysis;
  final Map<String, dynamic> sleepDepthAnalysis;
  final Map<String, dynamic> recoveryAnalysis;
  final List<Map<String, dynamic>> sleepCycles;
  final Map<String, dynamic> sleepTrends;
  final Map<String, int> sleepFactors;
  final Map<String, dynamic> emotionalActivityAnalysis;
  final Map<String, double> qualityFactors;
  final String keyInsight;
  final String strength;
  final String improvement;

  SleepAnalysis({
    required this.sleepScore,
    required this.sleepMetrics,
    required this.sleepStages,
    required this.detailedReport,
    required this.recommendations,
    required this.sleepPatterns,
    required this.predictiveWarnings,
    required this.behavioralFactors,
    required this.chronotype,
    required this.sleepMidpoint,
    required this.interventions,
    required this.sleepEfficiencyAnalysis,
    required this.sleepDepthAnalysis,
    required this.recoveryAnalysis,
    required this.sleepCycles,
    required this.sleepTrends,
    required this.sleepFactors,
    required this.emotionalActivityAnalysis,
    required this.qualityFactors,
    required this.keyInsight,
    required this.strength,
    required this.improvement,
  });

  factory SleepAnalysis.fromJson(Map<String, dynamic> json) {
    return SleepAnalysis(
      sleepScore: json['sleepScore'] as int? ?? 0,
      sleepMetrics: Map<String, dynamic>.from(json['sleepMetrics'] as Map? ?? {}),
      sleepStages: (json['sleepStages'] as Map? ?? {}).map<String, double>(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      detailedReport: json['detailedReport'] as String? ?? '',
      recommendations: List<String>.from(json['recommendations'] as List? ?? []),
      sleepPatterns: Map<String, dynamic>.from(json['sleepPatterns'] as Map? ?? {}),
      predictiveWarnings: List<String>.from(json['predictiveWarnings'] as List? ?? []),
      behavioralFactors: Map<String, dynamic>.from(json['behavioralFactors'] as Map? ?? {}),
      chronotype: json['chronotype'] as String? ?? '',
      sleepMidpoint: json['sleepMidpoint'] as String? ?? '',
      interventions: (json['interventions'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      sleepEfficiencyAnalysis: Map<String, dynamic>.from(json['sleepEfficiencyAnalysis'] as Map? ?? {}),
      sleepDepthAnalysis: Map<String, dynamic>.from(json['sleepDepthAnalysis'] as Map? ?? {}),
      recoveryAnalysis: Map<String, dynamic>.from(json['recoveryAnalysis'] as Map? ?? {}),
      sleepCycles: (json['sleepCycles'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      sleepTrends: Map<String, dynamic>.from(json['sleepTrends'] as Map? ?? {}),
      sleepFactors: (json['sleepFactors'] as Map? ?? {}).map<String, int>(
            (key, value) => MapEntry(key, value as int),
      ),
      emotionalActivityAnalysis: Map<String, dynamic>.from(json['emotionalActivityAnalysis'] as Map? ?? {}),
      qualityFactors: (json['qualityFactors'] as Map? ?? {}).map<String, double>(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      keyInsight: json['keyInsight'] as String? ?? '',
      strength: json['strength'] as String? ?? '',
      improvement: json['improvement'] as String? ?? '',
    );
  }
}
