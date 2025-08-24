// lib/widgets/sleep_stages_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class SleepStagesSection extends StatelessWidget {
  const SleepStagesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepLog>(
      builder: (context, log, _) {
        final deep = _clampValue(log.deepSleepMinutes ?? 0, 180);
        final rem = _clampValue(log.remSleepMinutes ?? 0, 180);
        final light = _clampValue(log.lightSleepMinutes ?? 0, 360);
        final totalSleep = deep + rem + light;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.width(20),
            vertical: ScreenUtils.height(16),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(ScreenUtils.scale(24)),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context),
              SizedBox(height: ScreenUtils.height(16)),
              _buildSectionDescription(),
              SizedBox(height: ScreenUtils.height(24)),
              _buildStageSlider(
                context,
                label: 'Deep Sleep',
                icon: Icons.nights_stay_rounded,
                value: deep,
                min: 0.0,
                max: 180.0,
                color: const Color(0xFF6A67CE),
                setter: log.setDeepSleepMinutes,
              ),
              SizedBox(height: ScreenUtils.height(24)),
              _buildStageSlider(
                context,
                label: 'REM Sleep',
                icon: Icons.self_improvement_rounded,
                value: rem,
                min: 0.0,
                max: 180.0,
                color: const Color(0xFF4CAF50),
                setter: log.setRemSleepMinutes,
              ),
              SizedBox(height: ScreenUtils.height(24)),
              _buildStageSlider(
                context,
                label: 'Light Sleep',
                icon: Icons.bedtime_rounded,
                value: light,
                min: 0.0,
                max: 360.0,
                color: const Color(0xFF2196F3),
                setter: log.setLightSleepMinutes,
              ),
              SizedBox(height: ScreenUtils.height(20)),
              _buildTotalSleep(totalSleep),
            ],
          ),
        );
      },
    );
  }

  double _clampValue(int value, int max) => value.clamp(0, max).toDouble();

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtils.height(12)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ScreenUtils.scale(6)),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: Colors.blueAccent,
              size: ScreenUtils.textScale(20),
            ),
          ),
          SizedBox(width: ScreenUtils.width(12)),
          Text(
            'SLEEP COMPOSITION',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: ScreenUtils.textScale(14),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDescription() {
    return Text(
      'Track your sleep stages to analyze depth and restoration',
      style: TextStyle(
        color: Colors.white70,
        fontSize: ScreenUtils.textScale(14),
        height: 1.4,
      ),
    );
  }

  Widget _buildStageSlider(
      BuildContext context, {
        required String label,
        required IconData icon,
        required double value,
        required double min,
        required double max,
        required Color color,
        required Function(int) setter,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(ScreenUtils.scale(4)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: ScreenUtils.textScale(18)),
            ),
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
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.width(10),
                vertical: ScreenUtils.height(4),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ScreenUtils.scale(20)),
              ),
              child: Text(
                '${value.round()} min',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: ScreenUtils.textScale(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtils.height(8)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: ScreenUtils.scale(6),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: ScreenUtils.scale(10),
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: ScreenUtils.scale(16),
            ),
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => setter(v.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSleep(double totalSleep) {
    final hours = (totalSleep / 60).floor();
    final minutes = (totalSleep % 60).round();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.width(16),
        vertical: ScreenUtils.height(14),
      ),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ScreenUtils.scale(16)),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            color: Colors.amber[300],
            size: ScreenUtils.textScale(20),
          ),
          SizedBox(width: ScreenUtils.width(12)),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Total sleep: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ScreenUtils.textScale(14),
                  ),
                ),
                TextSpan(
                  text: '${hours}h ${minutes}m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtils.textScale(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}