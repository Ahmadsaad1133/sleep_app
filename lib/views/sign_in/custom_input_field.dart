import 'package:flutter/material.dart';
import '/constants/sizes.dart';
import '/constants/colors.dart';
import '/constants/fonts.dart';
class CustomInputField extends StatelessWidget {
  final String label;
  final String? hintText;
  final double fontSize;
  final double height;
  final bool obscureText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const CustomInputField({
    Key? key,
    required this.label,
    this.hintText,
    required this.fontSize,
    required this.height,
    this.obscureText = false,
    this.suffixIcon,
    this.focusNode,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: AppFonts.helveticaRegular,
          fontSize: fontSize,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w600,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: AppFonts.helveticaRegular,
          fontSize: fontSize,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.backgroundLight,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.inputHorizontalPadding,
          vertical: (height - fontSize) / 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        fontFamily: AppFonts.helveticaBold,
        fontSize: fontSize,
        color: AppColors.textDark,
      ),
    );
  }
}

