import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/widgets/analysis_section.dart';
import '../neo_design.dart';

class ReportTab extends StatelessWidget {
  final String detailedReport;

  const ReportTab({
    super.key,
    required this.detailedReport,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          NeoCard(
            padding: EdgeInsets.all(16.r),
            child: AnalysisSection(detailedReport: detailedReport),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
