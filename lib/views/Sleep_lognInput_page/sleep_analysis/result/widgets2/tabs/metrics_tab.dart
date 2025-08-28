import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_metrics.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/lifestyle_factors.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_cycles.dart';
import '../../../../../../constants/colors.dart';
import '../../../models/sleeplog_model_page.dart';
import '../neo_design.dart';

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
      _buildSectionSliver(
        icon: Icons.analytics,
        title: "Sleep Metrics",
        content: SleepMetrics(sleepMetrics: sleepMetrics),
      ),
      _buildSectionSliver(
        icon: Icons.night_shelter,
        title: "Sleep Cycles",
        content: SleepCycles(sleepCycles: sleepCycles),
      ),
      _buildSectionSliver(
        icon: Icons.coffee,
        title: "Lifestyle Factors",
        content: LifestyleFactors(lastSleepLog: lastSleepLog),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 80.h)),
    ];
  }

  Widget _buildSectionSliver({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: NeoCard(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(icon, title),
              SizedBox(height: 8.h),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.w, color: AppColors.primaryPurple),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'NunitoSansBold',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('Use `slivers` getter with a CustomScrollView.');
  }
}