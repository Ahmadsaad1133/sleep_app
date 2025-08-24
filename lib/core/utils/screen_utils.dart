// lib/core/utils/screen_utils.dart
import 'package:flutter/cupertino.dart' hide Size;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtils {
  // No need to pass context anymore; initialization happens in main.dart using ScreenUtilInit
  static double scale(double value) => value.w;
  static double textScale(double size) => size.sp;
  static double height(double value) => value.h;
  static double width(double value) => value.w;

  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value.w);

  static EdgeInsets symmetric({double? h, double? v}) => EdgeInsets.symmetric(
    horizontal: h != null ? h.w : 0,
    vertical: v != null ? v.h : 0,
  );
}
