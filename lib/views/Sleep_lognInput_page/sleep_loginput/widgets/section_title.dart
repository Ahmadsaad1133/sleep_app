// lib/widgets/common/section_title.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/screen_utils.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionTitle(this.title, {Key? key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No more per-widget init
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.tealAccent[200],
            size: ScreenUtils.textScale(20),
          ),
          SizedBox(width: ScreenUtils.width(8)),
        ],
        Text(
          title,
          style: TextStyle(
            color: Colors.tealAccent[200],
            fontSize: ScreenUtils.textScale(16),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
