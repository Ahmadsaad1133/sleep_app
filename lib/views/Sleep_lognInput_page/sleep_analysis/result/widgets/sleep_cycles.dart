import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/fonts.dart';

class SleepCycles extends StatelessWidget {
  final List<Map<String, dynamic>> sleepCycles;

  const SleepCycles({
    Key? key,
    required this.sleepCycles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sleepCycles.isEmpty) return const SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(Icons.cyclone, color: Colors.orange, size: 28.sp),
                SizedBox(width: 10.w),
                Text(
                  'SLEEP CYCLES',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontFamily: AppFonts.ComfortaaBold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0.h, color: Colors.black12),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Text(
                  '${sleepCycles.length} Sleep Cycles Detected',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.ComfortaaBold,
                  ),
                ),
                SizedBox(height: 15.h),
                ...sleepCycles.map(
                      (cycle) => Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Row(
                      children: [
                        Text(
                          'Cycle ${cycle['number']}:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.ComfortaaBold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '${cycle['duration']} mins',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(width: 20.w),
                        Icon(
                          Icons.star,
                          color: (cycle['quality'] as num? ?? 0) > 7
                              ? Colors.amber
                              : Colors.grey,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${cycle['quality']}/10',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
                if (sleepCycles.isNotEmpty && sleepCycles[0]['notes'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Text(
                      sleepCycles[0]['notes'].toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        fontFamily: AppFonts.ComfortaaLight,
                      ),
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
