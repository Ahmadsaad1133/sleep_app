import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_environment_analysis.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/sleep_quality_breakdown.dart';
import '../../../../../../constants/colors.dart';
import '../../../models/sleeplog_model_page.dart';

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
      _buildSectionSliver(
        icon: Icons.bedroom_parent,
        title: "Sleep Environment",
        content: environmentAnalysis,
      ),
      _buildSectionSliver(
        icon: Icons.stacked_bar_chart,
        title: "Quality Breakdown",
        content: SleepQualityBreakdown(
          preloadedData: preloadedQualityData ?? {},
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(icon, title),
            SizedBox(height: 8.h),
            content,
          ],
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