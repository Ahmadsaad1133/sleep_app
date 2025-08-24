import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized error handling service
class ErrorHandler {
  /// Log and report errors
  static Future<void> recordError(
      dynamic error,
      StackTrace stackTrace, {
        String context = 'general',
        bool fatal = false,
      }) async {
    // Print to console for development
    print('[$context] ERROR: $error');
    print(stackTrace);

    // Report to Crashlytics
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: context,
      fatal: fatal,
    );
  }

  /// Shortcut to log an error without optional parameters
  static Future<void> logError(
      dynamic error,
      StackTrace stackTrace, [
        String context = 'general',
      ]) async {
    await recordError(error, stackTrace, context: context);
  }

  /// Set custom error key
  static Future<void> setCustomKey(String key, dynamic value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Set user identifier for error tracking
  static Future<void> setUserId(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Log a message to Crashlytics
  static Future<void> logMessage(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }

  /// Handle and wrap async errors
  static Future<void> handleAsyncError(
      Future Function() fn,
      String context,
      ) async {
    try {
      await fn();
    } catch (e, stack) {
      await recordError(e, stack, context: context);
    }
  }
}
