

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/fonts.dart';

class SleepEfficiencyAnalysis extends StatelessWidget {
  final Map<String, dynamic> sleepEfficiencyAnalysis;

  const SleepEfficiencyAnalysis({
    Key? key,
    required this.sleepEfficiencyAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sleepEfficiencyAnalysis.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Text(
                  'SLEEP EFFICIENCY ANALYSIS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontFamily: AppFonts.ComfortaaBold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                _buildAnalysisRow('Actual Efficiency',
                    '${sleepEfficiencyAnalysis['value']?.toStringAsFixed(1) ?? 'N/A'}%'),
                _buildAnalysisRow('Ideal Range',
                    sleepEfficiencyAnalysis['ideal_range'] ?? '85-95%'),
                _buildAnalysisRow('Time in Bed',
                    sleepEfficiencyAnalysis['time_in_bed'] ?? 'N/A'),
                _buildAnalysisRow('Actual Sleep',
                    sleepEfficiencyAnalysis['actual_sleep'] ?? 'N/A'),
                _buildAnalysisRow('Efficiency Gap',
                    sleepEfficiencyAnalysis['gap']?.toStringAsFixed(1) ?? 'N/A'),
                _buildAnalysisRow('Primary Efficiency Loss',
                    sleepEfficiencyAnalysis['primary_loss'] ?? 'N/A'),
              ],
            ),
          ),
          if (sleepEfficiencyAnalysis['notes'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Text(
                sleepEfficiencyAnalysis['notes'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  TableRow _buildAnalysisRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.ComfortaaLight,
            ),
          ),
        ),
      ],
    );
  }
}