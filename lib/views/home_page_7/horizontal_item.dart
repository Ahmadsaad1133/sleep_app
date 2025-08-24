import 'package:flutter/material.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
import '/constants/colors.dart';

class HorizontalItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const HorizontalItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const baseWidth = 410.0;
    final scale = (width / baseWidth); // No clamp to allow full scaling
    double s(double v) => v * scale;

    return Container(
      width: s(182),
      margin: EdgeInsets.only(
        right: s(AppSizes.cardSpacing),
        bottom: s(30),
      ),
      constraints: BoxConstraints(
        minHeight: s(220),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(s(12)),
            child: Image.network(
              imageUrl,
              width: s(162),
              height: s(133),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: s(162),
                height: s(133),
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: s(162),
                  height: s(133),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              },
            ),
          ),
          SizedBox(height: s(15)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: s(16),
                  fontFamily: AppFonts.helveticaBold,
                  fontWeight: AppFonts.bold,
                  color: AppColors.bodyPrimary,
                ),
              ),
              SizedBox(height: s(6)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: s(11),
                  fontFamily: AppFonts.helveticaRegular,
                  fontWeight: AppFonts.light,
                  letterSpacing: 0.05 * s(11),
                  color: AppColors.bodySecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
