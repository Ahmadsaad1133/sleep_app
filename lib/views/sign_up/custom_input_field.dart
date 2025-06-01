import 'package:flutter/material.dart';
import '/constants/colors.dart';
import '/constants/sizes.dart';
import '/constants/fonts.dart';
class CustomInputField extends StatelessWidget {
  final String hintText;
  final double fontSize;
  final double height;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  const CustomInputField({
    Key? key,
    required this.hintText,
    required this.fontSize,
    required this.height,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.focusNode,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: AppFonts.helveticaRegular,
          fontSize: fontSize,
          color: AppColors.textGray,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: (height - fontSize) / 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        fontFamily: AppFonts.helveticaRegular,
        fontSize: fontSize,
        color: Colors.black,
      ),
    );
  }
}
