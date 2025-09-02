// lib/widgets/disturbance_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class DisturbanceSection extends StatelessWidget {
  const DisturbanceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disturbances = [
      'Nightmares',
      'Restless Legs',
      'Snoring',
      'Frequent Bathroom',
      'Pain',
    ];

    return Consumer<SleepLog>(
      builder: (context, model, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: ScreenUtils.width(12),
              runSpacing: ScreenUtils.height(12),
              children: disturbances
                  .map((dist) => _buildDisturbanceChip(dist, model))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisturbanceChip(String dist, SleepLog model) {
    final isSelected = model.disturbances.contains(dist);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      child: InkWell(
        borderRadius: BorderRadius.circular(ScreenUtils.scale(20)),
        onTap: () {
          HapticFeedback.lightImpact();
          model.toggleDisturbance(dist);
        },
        child: Container(
          padding: ScreenUtils.symmetric(h: 16, v: 12),
          constraints: BoxConstraints(
            minWidth: ScreenUtils.width(120),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.scale(20)),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.3)
                  : Colors.blueGrey.withOpacity(0.15),
              width: ScreenUtils.scale(1.2),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                const Color(0xFF4A7BD5).withOpacity(0.5),
                const Color(0xFF00D2FF).withOpacity(0.35),
              ]
                  : [
                Colors.blueGrey.withOpacity(0.03),
                Colors.blueGrey.withOpacity(0.08),
              ],
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF4A7BD5).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check_rounded,
                  key: const ValueKey('checked'),
                  color: Colors.white,
                  size: ScreenUtils.textScale(20),
                )
                    : Container(
                  key: const ValueKey('unchecked'),
                  width: ScreenUtils.width(18),
                  height: ScreenUtils.height(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueGrey.withOpacity(0.5),
                      width: ScreenUtils.scale(1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtils.width(8)),
              Flexible(
                child: AutoSizeText(
                  dist,
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(
                    fontSize: ScreenUtils.textScale(15),
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.blueGrey[100]!.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
