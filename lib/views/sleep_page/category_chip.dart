import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/constants/sizes.dart';
class CategoryChip extends StatelessWidget {
  final String label;
  final String? iconPath;
  final bool isActive;
  final double scale;
  final VoidCallback onTap;
  const CategoryChip({
    Key? key,
    required this.label,
    this.iconPath,
    this.isActive = false,
    this.scale = 1.0,
    required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double chipSize = AppSizes.categoryChipSize * scale;
    final double iconSize = AppSizes.categoryIconSize * scale;
    final double borderRadius = AppSizes.categoryBorderRadius * scale;
    final double labelFontSize = AppSizes.categoryFontSize * scale;
    final double spacingBelow = AppSizes.categorySpacingBelow * scale;
    final Color activeColor = const Color(0xFF8E97FD);
    final Color inactiveColor = const Color(0xFF586894);
    final Color activeTextColor = const Color(0xFFE6E7F2);
    final Color inactiveTextColor = const Color(0xFF98A1BD);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: chipSize,
            height: chipSize,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: iconPath != null
                  ? SvgPicture.asset(
                iconPath!,
                width: iconSize,
                height: iconSize,
                color: Colors.white,
              )
                  : const SizedBox.shrink(),
            ),
          ),
          SizedBox(height: spacingBelow),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: isActive ? activeTextColor : inactiveTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
