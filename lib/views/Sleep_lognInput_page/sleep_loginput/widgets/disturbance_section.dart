// lib/widgets/disturbance_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../sleep_analysis/models/sleeplog_model_page.dart';

/// ------------------------------------------------------------
/// DisturbanceSection (Provider + SleepLog)
/// ------------------------------------------------------------
/// - Dark UI (texts white), organized with Rows/Columns/Containers
/// - Uses SleepLog via Provider:
///     - read: model.disturbances (List<String>)
///     - toggle: model.toggleDisturbance(String)
///     - (optional bulk): model.setDisturbances(List<String>)
class DisturbanceSection extends StatelessWidget {
  const DisturbanceSection({Key? key}) : super(key: key);
//
  static const List<_DistItem> _all = [
    _DistItem('Phone notifications', Icons.notifications_active),
    _DistItem('Partner movement', Icons.bed),
    _DistItem('Traffic noise', Icons.directions_car),
    _DistItem('Pets', Icons.pets),
    _DistItem('Children', Icons.child_care),
    _DistItem('Late-night screens', Icons.phone_android),
    _DistItem('Caffeine late', Icons.local_cafe),
    _DistItem('Stress', Icons.self_improvement),
    _DistItem('Nightmares', Icons.nightlight_round),
    _DistItem('Snoring', Icons.record_voice_over),
    _DistItem('Heat', Icons.device_thermostat),
    _DistItem('Cold', Icons.ac_unit),
  ];

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SleepLog>();
    final selected = model.disturbances;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: AutoSizeText(
                  'Sleep Disturbances',
                  maxLines: 1,
                  minFontSize: 14,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected.isNotEmpty)
                TextButton(
                  onPressed: () => model.setDisturbances(const []),
                  child: AutoSizeText(
                    'Clear',
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CardBlock(
                  title: 'Select what bothered your sleep',
                  items: _all.sublist(0, (_all.length / 2).ceil()),
                  selected: selected,
                  onToggle: (label) {
                    HapticFeedback.lightImpact();
                    model.toggleDisturbance(label);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _CardBlock(
                  title: 'More possible disturbances',
                  items: _all.sublist((_all.length / 2).ceil()),
                  selected: selected,
                  onToggle: (label) {
                    HapticFeedback.lightImpact();
                    model.toggleDisturbance(label);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  final String title;
  final List<_DistItem> items;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _CardBlock({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
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
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: items.map((e) {
              final bool isSelected = selected.contains(e.label);
              return _DisturbanceChip(
                label: e.label,
                icon: e.icon,
                isSelected: isSelected,
                onTap: () => onToggle(e.label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DisturbanceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DisturbanceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF131313),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: isSelected ? Colors.black : Colors.white),
            SizedBox(width: 6.w),
            AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 10,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistItem {
  final String label;
  final IconData icon;
  const _DistItem(this.label, this.icon);
}
