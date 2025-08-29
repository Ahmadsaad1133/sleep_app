import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_metrics.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/lifestyle_factors.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_cycles.dart';
import '../../../models/sleeplog_model_page.dart';

class MetricsTab extends StatelessWidget {
  final Map<String, dynamic> sleepMetrics;
  final List<Map<String, dynamic>> sleepCycles;
  final SleepLog? lastSleepLog;

  const MetricsTab({
    super.key,
    required this.sleepMetrics,
    required this.sleepCycles,
    required this.lastSleepLog,
  });

  List<Widget> get slivers {
    return [
      SliverToBoxAdapter(
        child: SleepMetrics(sleepMetrics: sleepMetrics),
      ),
      SliverToBoxAdapter(
        child: SleepCycles(sleepCycles: sleepCycles),
      ),
      SliverToBoxAdapter(
        child: LifestyleFactors(lastSleepLog: lastSleepLog),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 80.h)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: slivers,
    );
  }
}
