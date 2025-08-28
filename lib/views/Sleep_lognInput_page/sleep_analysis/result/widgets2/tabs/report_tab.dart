import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          NeoCard(
            padding: const EdgeInsets.all(16),
            child: AnalysisSection(detailedReport: detailedReport),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}