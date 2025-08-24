// lib/widgets/sleep_efficiency_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class SleepEfficiencySection extends StatelessWidget {
  const SleepEfficiencySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ← remove ScreenUtils.init(context);
    return Consumer<SleepLog>(
      builder: (context, log, _) {
        return Container(
          padding: ScreenUtils.paddingAll(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(ScreenUtils.scale(20)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              SizedBox(height: ScreenUtils.height(12)),
              _buildSectionDescription(),
              SizedBox(height: ScreenUtils.height(24)),
              _buildInputRow(
                context: context,
                log: log,
                label: 'Time to Fall Asleep (min)',
                icon: Icons.hourglass_top_rounded,
                color: Colors.amber,
                value: log.latencyMinutes,
                setter: log.setLatencyMinutes,
              ),
              SizedBox(height: ScreenUtils.height(20)),
              _buildInputRow(
                context: context,
                log: log,
                label: 'Wake After Sleep Onset (min)',
                icon: Icons.nightlight_round,
                color: Colors.deepOrangeAccent,
                value: log.wasoMinutes,
                setter: log.setWasoMinutes,
              ),
              SizedBox(height: ScreenUtils.height(20)),
              _buildInputRow(
                context: context,
                log: log,
                label: 'Total Time in Bed (min)',
                icon: Icons.bed_rounded,
                color: Colors.purpleAccent,
                value: log.timeInBedMinutes,
                setter: log.setTimeInBedMinutes,
                helperText: 'Time from bedtime to wake time',
              ),
              if (log.timeInBedMinutes != null && log.durationMinutes > 0)
                _buildEfficiencyDisplay(log),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.timeline_rounded,
          color: Colors.tealAccent[200],
          size: ScreenUtils.textScale(20),
        ),
        SizedBox(width: ScreenUtils.width(8)),
        Text(
          'SLEEP EFFICIENCY',
          style: TextStyle(
            color: Colors.tealAccent[200],
            fontSize: ScreenUtils.textScale(12),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDescription() {
    return Text(
      'Track efficiency metrics to analyze sleep continuity',
      style: TextStyle(
        color: Colors.white70,
        fontSize: ScreenUtils.textScale(14),
      ),
    );
  }

  Widget _buildInputRow({
    required BuildContext context,
    required SleepLog log,
    required String label,
    required IconData icon,
    required Color color,
    required int? value,
    required Function(int?) setter,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: ScreenUtils.textScale(20)),
            SizedBox(width: ScreenUtils.width(8)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: ScreenUtils.textScale(14),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtils.height(8)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(ScreenUtils.scale(12)),
          ),
          child: TextFormField(
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtils.textScale(16),
            ),
            decoration: InputDecoration(
              contentPadding: ScreenUtils.symmetric(h: 16, v: 16),
              border: InputBorder.none,
              suffixText: 'min',
              suffixStyle: TextStyle(color: Colors.white54),
              helperText: helperText,
              helperStyle: TextStyle(
                color: Colors.white54,
                fontSize: ScreenUtils.textScale(12),
              ),
            ),
            keyboardType: TextInputType.number,
            initialValue: value?.toString(),
            onChanged: (v) => setter(int.tryParse(v)),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final val = int.tryParse(value);
                if (val == null || val < 0) return 'Enter a valid number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyDisplay(SleepLog log) {
    final efficiency =
    (log.durationMinutes / log.timeInBedMinutes! * 100).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.only(top: ScreenUtils.height(16)),
      child: Container(
        padding: ScreenUtils.paddingAll(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ScreenUtils.scale(14)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: ScreenUtils.textScale(22),
            ),
            SizedBox(width: ScreenUtils.width(12)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLEEP EFFICIENCY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ScreenUtils.textScale(11),
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: ScreenUtils.height(2)),
                Text(
                  '$efficiency%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtils.textScale(22),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
