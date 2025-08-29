import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../constants/colors.dart';
import '../neo_design.dart';

/// Shared section widget used across sleep analysis tabs to maintain
/// a consistent look and feel.
class NeoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const NeoSection({super.key, required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: NeoCard(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NeoSectionHeader(icon: icon, title: title),
            SizedBox(height: 8.h),
            child,
          ],
        ),
      ),
    );
  }
}

class SliverNeoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SliverNeoSection({super.key, required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: NeoSection(icon: icon, title: title, child: child),
    );
  }
}

class _NeoSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _NeoSectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20.w, color: AppColors.primaryPurple),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'NunitoSansBold',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}