import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics service for tracking app events
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer =
  FirebaseAnalyticsObserver(analytics: _analytics);

  /// Get analytics observer for MaterialApp
  static FirebaseAnalyticsObserver get observer => _observer;

  /// Log a custom event
  static Future<void> logEvent(
      String name,
      [Map<String, dynamic>? parameters]
      ) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>(),
    );
  }

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  /// Log button press event
  static Future<void> logButtonPress(String buttonName) async {
    await logEvent('button_press', {'button': buttonName});
  }

  /// Log feature usage
  static Future<void> logFeatureUsage(String feature) async {
    await logEvent('feature_used', {'feature': feature});
  }

  /// Log error event
  static Future<void> logError(String errorType, String message) async {
    await logEvent('app_error', {
      'error_type': errorType,
      'message': message,
    });
  }

  /// Log performance metric
  static Future<void> logPerformance(
      String metricName, int milliseconds) async {
    await logEvent('performance_metric', {
      'metric': metricName,
      'value': milliseconds,
    });
  }

  /// Set user properties
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}