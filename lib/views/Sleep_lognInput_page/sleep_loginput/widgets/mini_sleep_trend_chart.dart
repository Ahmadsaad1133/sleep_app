import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../sleep_log_service/sleep_log_service.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class MiniSleepTrendChart extends StatefulWidget {
  const MiniSleepTrendChart({super.key});

  @override
  State<MiniSleepTrendChart> createState() => _MiniSleepTrendChartState();
}

class _MiniSleepTrendChartState extends State<MiniSleepTrendChart> {
  List<SleepLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await SleepLogService.getHistoricalSleepLogs(limit: 7);
      if (res.isSuccess && res.data != null) {
        setState(() {
          _logs = res.data!.reversed.toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _logs.isEmpty) {
      return const SizedBox.shrink(); // no forced height
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < _logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), _logs[i].durationMinutes.toDouble()));
    }

    return SizedBox(
      height: 100,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: false),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}