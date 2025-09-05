// lib/widgets/sleep_efficiency_section.dart
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/step_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class SleepEfficiencySection extends StatelessWidget {
  const SleepEfficiencySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

  Widget _buildSectionDescription() {
    return Text(
      'Latency, time awake, and total time in bed',
      style: TextStyle(
        color: Colors.white70,
        fontSize: ScreenUtils.textScale(14),
        height: 1.4,
      ),
    );
  }

  Widget _buildInputRow({
    required BuildContext context,
    required SleepLog log,
    required String label,
    required IconData icon,
    required Color color,
    int? value,
    String? helperText,
    required Function(int) setter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: ScreenUtils.textScale(18)),
            SizedBox(width: ScreenUtils.width(10)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtils.textScale(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: ScreenUtils.width(80),
              child: TextFormField(
                initialValue: value?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(isDense: true),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null) setter(parsed);
                },
              ),
            ),
          ],
        ),
        if (helperText != null)
          Padding(
            padding: EdgeInsets.only(top: ScreenUtils.height(4)),
            child: Text(
              helperText,
              style: TextStyle(
                color: Colors.white70,
                fontSize: ScreenUtils.textScale(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEfficiencyDisplay(SleepLog log) {
    final efficiency = (log.durationMinutes / log.timeInBedMinutes!) * 100;
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtils.height(24)),
      child: Text(
        'Efficiency: ${efficiency.toStringAsFixed(1)}%',
        style: TextStyle(
          color: Colors.tealAccent[200],
          fontSize: ScreenUtils.textScale(14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}