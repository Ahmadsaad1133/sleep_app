import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final String? iconAsset;
  final bool isActive;
  final double scale;
  final VoidCallback onTap;

  const CategoryChip({
    required this.label,
    this.iconAsset,
    required this.isActive,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16 * scale),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 70 * scale,
              height: 70 * scale,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF8E97FD)
                    : const Color(0xFFA0A3B1),
                borderRadius: BorderRadius.circular(28 * scale),
              ),
              child: Center(
                child: iconAsset != null
                    ? SvgPicture.asset(
                  iconAsset!,
                  width: 28 * scale,
                  height: 28 * scale,
                  color: Colors.white,
                )
                    : const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: 18 * scale,
                color: isActive
                    ? const Color(0xFF3F414E)
                    : const Color(0xFFA0A3B1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
