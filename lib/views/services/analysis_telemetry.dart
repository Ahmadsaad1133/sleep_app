/// analysis_telemetry.dart
library analysis_telemetry;

import 'dart:async';
import 'dart:math';

/// A single event line for the console.
class AnalysisEvent {
  final DateTime time;
  final String stage;      // e.g. "Queue", "Network", "Parse", "ExecutiveSummary"
  final String message;    // short line for the console
  final Map<String, dynamic>? data;
  final double? progress;  // 0..1 if meaningful
  final bool? success;     // null = running, true/false = completed

  AnalysisEvent({
    DateTime? time,
    required this.stage,
    required this.message,
    this.data,
    this.progress,
    this.success,
  }) : time = time ?? DateTime.now();
}

/// Rolling metrics for the header/footer.
class ConsoleMetrics {
  final int activeTasks;
  final double avgLatencyMs;   // EWMA
  final double lastLatencyMs;
  final double successRate;    // 0..1
  final double tokensPerSec;   // EWMA

  const ConsoleMetrics({
    required this.activeTasks,
    required this.avgLatencyMs,
    required this.lastLatencyMs,
    required this.successRate,
    required this.tokensPerSec,
  });

  ConsoleMetrics copyWith({
    int? activeTasks,
    double? avgLatencyMs,
    double? lastLatencyMs,
    double? successRate,
    double? tokensPerSec,
  }) {
    return ConsoleMetrics(
      activeTasks: activeTasks ?? this.activeTasks,
      avgLatencyMs: avgLatencyMs ?? this.avgLatencyMs,
      lastLatencyMs: lastLatencyMs ?? this.lastLatencyMs,
      successRate: successRate ?? this.successRate,
      tokensPerSec: tokensPerSec ?? this.tokensPerSec,
    );
  }
}

class AnalysisSpan {
  final String name;
  final Map<String, dynamic>? context;
  final Stopwatch _sw = Stopwatch()..start();
  final String _id;
  bool _closed = false;

  AnalysisSpan._(this.name, this.context, this._id);

  void success({int? latencyMs, int? outputTokens, Map<String, dynamic>? extra}) {
    if (_closed) return;
    _closed = true;
    _sw.stop();
    final dt = latencyMs ?? _sw.elapsedMilliseconds;
    AnalysisTelemetry.instance._onSpanEnd(
      this, true, dt,
      outputTokens: outputTokens, extra: extra,
    );
  }

  void failure({int? latencyMs, Object? error, Map<String, dynamic>? extra}) {
    if (_closed) return;
    _closed = true;
    _sw.stop();
    final dt = latencyMs ?? _sw.elapsedMilliseconds;
    AnalysisTelemetry.instance._onSpanEnd(
      this, false, dt,
      error: error, extra: extra,
    );
  }
}

class AnalysisTelemetry {
  static final AnalysisTelemetry instance = AnalysisTelemetry._();

  final _events = StreamController<AnalysisEvent>.broadcast();
  Stream<AnalysisEvent> get stream => _events.stream;

  final _metrics = StreamController<ConsoleMetrics>.broadcast();
  Stream<ConsoleMetrics> get metricsStream => _metrics.stream;

  ConsoleMetrics _cur = const ConsoleMetrics(
    activeTasks: 0,
    avgLatencyMs: 0,
    lastLatencyMs: 0,
    successRate: 1,
    tokensPerSec: 0,
  );

  final Map<String, AnalysisSpan> _active = {};
  int _completed = 0;
  int _succeeded = 0;

  AnalysisTelemetry._();

  void log(String stage, String message, {Map<String, dynamic>? data, double? progress, bool? success}) {
    _events.add(AnalysisEvent(stage: stage, message: message, data: data, progress: progress, success: success));
  }

  AnalysisSpan startSpan(String name, {Map<String, dynamic>? context}) {
    final id = _randId();
    final span = AnalysisSpan._(name, context, id);
    _active[id] = span;
    _events.add(AnalysisEvent(stage: name, message: 'START', data: context, progress: 0, success: null));
    _updateMetrics(activeDelta: 1);
    return span;
  }

  Future<T> wrap<T>(String name, Future<T> Function() fn, {Map<String, dynamic>? context, int? outputTokens}) async {
    final span = startSpan(name, context: context);
    try {
      final result = await fn();
      span.success(outputTokens: outputTokens);
      return result;
    } catch (e) {
      span.failure(error: e);
      rethrow;
    }
  }

  void _onSpanEnd(AnalysisSpan span, bool success, int latencyMs, {int? outputTokens, Object? error, Map<String, dynamic>? extra}) {
    // Remove from active
    _active.removeWhere((_, s) => identical(s, span));
    _completed += 1;
    if (success) _succeeded += 1;

    final double tps = (outputTokens != null && latencyMs > 0) ? outputTokens / (latencyMs / 1000.0) : 0;

    _events.add(AnalysisEvent(
      stage: span.name,
      message: success ? 'DONE' : 'FAIL',
      data: {
        'latencyMs': latencyMs,
        if (span.context != null) ...span.context!,
        if (extra != null) ...extra,
        if (error != null) 'error': error.toString(),
        if (outputTokens != null) 'outputTokens': outputTokens,
        if (tps > 0) 'tps': tps,
      },
      progress: 1,
      success: success,
    ));

    _updateMetrics(
      activeDelta: -1,
      lastLatencyMs: latencyMs.toDouble(),
      tps: tps,
      success: success,
    );
  }

  void _updateMetrics({int? activeDelta, double? lastLatencyMs, double? tps, bool? success}) {
    int active = _cur.activeTasks + (activeDelta ?? 0);
    if (active < 0) active = 0;

    const alpha = 0.25; // EWMA smoothing
    final ewmaLatency = (lastLatencyMs != null)
        ? (_cur.avgLatencyMs == 0 ? lastLatencyMs : (_cur.avgLatencyMs * (1 - alpha) + lastLatencyMs * alpha))
        : _cur.avgLatencyMs;
    final ewmaTps = (tps != null && tps > 0)
        ? (_cur.tokensPerSec == 0 ? tps : (_cur.tokensPerSec * (1 - alpha) + tps * alpha))
        : _cur.tokensPerSec;

    final completed = _completed + ((success != null) ? 1 : 0);
    final succeeded = _succeeded + ((success == true) ? 1 : 0);
    final sr = completed == 0 ? _cur.successRate : (succeeded / completed);

    _cur = _cur.copyWith(
      activeTasks: active,
      avgLatencyMs: ewmaLatency,
      lastLatencyMs: lastLatencyMs ?? _cur.lastLatencyMs,
      tokensPerSec: ewmaTps,
      successRate: sr,
    );
    _metrics.add(_cur);
  }

  /// Rough token estimation from text length (4 chars/token).
  int estimateTokensFromText(String text) {
    if (text.isEmpty) return 0;
    final len = text.length;
    return max(1, (len / 4).round());
  }

  String _randId() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return List.generate(8, (_) => alphabet[rnd.nextInt(alphabet.length)]).join();
  }
}
