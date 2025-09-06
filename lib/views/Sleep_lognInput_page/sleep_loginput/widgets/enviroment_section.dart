// lib/widgets/environment_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../sleep_analysis/models/sleeplog_model_page.dart';

/// ------------------------------------------------------------
/// EnvironmentSection (Refactored - No Humidity field)
/// ------------------------------------------------------------
/// - Dark background friendly (all texts are white)
/// - Organized with Rows, Columns, Containers
/// - Uses only: lightExposure, temperature, noiseLevel from SleepLog
/// - Responsive via flutter_screenutil
class EnvironmentSection extends StatelessWidget {
  const EnvironmentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final log = context.watch<SleepLog>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.eco, color: Colors.white, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: AutoSizeText(
                  'Sleep Environment',
                  maxLines: 1,
                  minFontSize: 14,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Row 1: Light Exposure | Temperature
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _OptionCard(
                  title: 'Light Exposure',
                  icon: Icons.light_mode,
                  description: 'How bright was your room?',
                  options: const ['Dark', 'Dim', 'Bright'],
                  selected: log.lightExposure,
                  onSelect: (v) => log.setLightExposure(v),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _OptionCard(
                  title: 'Temperature',
                  icon: Icons.thermostat,
                  description: 'How did it feel?',
                  options: const ['Cold', 'Cool', 'Comfortable', 'Warm', 'Hot'],
                  selected: log.temperature,
                  onSelect: (v) => log.setTemperature(v),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Row 2: Noise Level | Tips (static)
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _OptionCard(
                  title: 'Noise Level',
                  icon: Icons.volume_up,
                  description: 'Ambient sound around you',
                  options: const ['Silent', 'Low', 'Moderate', 'Loud'],
                  selected: log.noiseLevel,
                  onSelect: (v) => log.setNoiseLevel(v),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _OptionCard(
                  title: 'Comfort Level',
                  icon: Icons.bed_outlined,
                  description: 'How comfortable did you feel?',
                  options: const ['Uncomfortable', 'Neutral', 'Comfortable'],
                  selected: log.comfortLevel,
                  onSelect: (v) => log.setComfortLevel(v),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _TipsCard(),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _OptionCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      maxLines: 1,
                      minFontSize: 12,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AutoSizeText(
                      description,
                      maxLines: 1,
                      minFontSize: 10,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Options Wrap
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: options.map((opt) {
              final bool isSelected = (opt == selected);
              return _ChoicePill(
                label: opt,
                isSelected: isSelected,
                onTap: () => onSelect(opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF131313),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
          ),
        ),
        child: AutoSizeText(
          label,
          maxLines: 1,
          minFontSize: 10,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.tips_and_updates, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AutoSizeText(
                  'Quick Tips',
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AutoSizeText(
            'Keep the room dark and cool.\nUse white noise if needed.\nAim for consistent conditions nightly.',
            maxLines: 4,
            minFontSize: 10,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
