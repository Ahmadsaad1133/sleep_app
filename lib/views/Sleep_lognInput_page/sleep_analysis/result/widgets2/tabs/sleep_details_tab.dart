import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_environment_analysis.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_quality_breakdown.dart';
import '../../../../../../constants/colors.dart';
import '../neo_design.dart';
import '../../../models/sleeplog_model_page.dart';
import 'neo_section.dart';

class SleepDetailsTab extends StatelessWidget {
  final Widget environmentAnalysis;
  final SleepLog? lastSleepLog;
  final Map<String, dynamic>? preloadedQualityData;
  final Map<String, dynamic>? dreamMoodForecast;

  const SleepDetailsTab({
    super.key,
    required this.environmentAnalysis,
    required this.lastSleepLog,
    this.preloadedQualityData,
    this.dreamMoodForecast,
  });

  List<Widget> get slivers {
    return [
      SliverToBoxAdapter(child: environmentAnalysis),
      SliverToBoxAdapter(
        child: SleepQualityBreakdown(
          preloadedData: preloadedQualityData ?? {},
        ),
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
