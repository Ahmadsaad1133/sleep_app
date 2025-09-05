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
/// - Dark UI (texts white), organized with Columns/Containers
/// - Uses SleepLog via Provider:
///     - read: model.disturbances (List<String>)
///     - toggle: model.toggleDisturbance(String)
/// - Two blocks stacked VERTICALLY (no horizontal row)
/// ------------------------------------------------------------
class DisturbanceSection extends StatelessWidget {
  const DisturbanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUtil is initialized higher up in your app.
    final theme = Theme.of(context);

    // Full list of available disturbance choices.
    const List<_DistItem> _all = [
      _DistItem('Noise', Icons.volume_up_rounded),
      _DistItem('Light', Icons.light_mode_rounded),
      _DistItem('Temperature', Icons.thermostat_rounded),
      _DistItem('Snoring', Icons.bedtime_rounded),
      _DistItem('Pets', Icons.pets_rounded),
      _DistItem('Kids', Icons.child_care_rounded),
      _DistItem('Stress', Icons.self_improvement_rounded),
      _DistItem('Late meals', Icons.restaurant_rounded),
      _DistItem('Caffeine', Icons.coffee_rounded),
      _DistItem('Alcohol', Icons.wine_bar_rounded),
      _DistItem('Screens', Icons.tv_rounded),
      _DistItem('Nightmares', Icons.nightlight_round),
    ];

    return Consumer<SleepLog>(
      builder: (context, model, _) {
        final selected = model.disturbances; // List<String>

        // Split choices into two vertical blocks
        final mid = (_all.length / 2).ceil();
        final firstHalf = _all.sublist(0, mid);
        final secondHalf = _all.sublist(mid);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardBlock(
              title: 'Common disturbances',
              items: firstHalf,
              selected: selected,
              onToggle: (label) {
                HapticFeedback.lightImpact();
                model.toggleDisturbance(label);
              },
            ),
            SizedBox(height: 12.h),
            _CardBlock(
              title: 'More possible disturbances',
              items: secondHalf,
              selected: selected,
              onToggle: (label) {
                HapticFeedback.lightImpact();
                model.toggleDisturbance(label);
              },
            ),
          ],
        );
      },
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF121218),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final item in items)
                _ChipChoice(
                  label: item.label,
                  icon: item.icon,
                  selected: selected.contains(item.label),
                  onTap: () => onToggle(item.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChipChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E335A) : const Color(0xFF1A1B22),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? const Color(0xFF7B7FF4) : const Color(0x33FFFFFF),
            width: 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
              color: const Color(0xFF7B7FF4).withOpacity(0.25),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
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
