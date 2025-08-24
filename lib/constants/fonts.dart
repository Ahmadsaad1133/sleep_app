import 'package:flutter/material.dart';
import 'colors.dart';

/// Fonts names and weights
class AppFonts {
  static const String helveticaBold = 'HelveticaNeueBold';
  static const String helveticaRegular = 'HelveticaNeueRegular';
  static const String AirbnbCerealBook = 'AirbnbCereal';
  static const FontWeight light = FontWeight.w300;
  static const FontWeight medium = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight navLabelWeight = FontWeight.w400;
  static const String mainFontFamily  = 'YourFontFamilyName';
  static const String ComfortaaLight = 'ComfortaaLight';
  static const String ComfortaaBold = 'ComfortaaBold';
  static const String ComfortaaRegular = 'ComfortaaRegular';
  static const String nunitoSansRegular = 'nunitoSansRegular';
  static const String nunitoSansBold = 'nunitoSansBold';
  static const String PlayfairDisplay = 'PlayfairDisplay';
}

/// Common TextStyles used across the app
class AppTextStyles {
  static TextStyle heading(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.bold,
    fontSize: 28 * scale,
    height: 1.35,
    color: AppColors.bodyPrimary,
  );



  static TextStyle subheading(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.light,
    fontSize: 28 * scale,
    height: 1.35,
    color: AppColors.bodyPrimary,
  );

  static TextStyle sectionLabel(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.light,
    fontSize: 20 * scale,
    height: 1.0,
    color: AppColors.bodySecondary,
  );

  static TextStyle cardDefaultLabel(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.medium,
    fontSize: 18 * scale,
    height: 1.35,
    color: AppColors.onPrimaryLight,
  );

  static TextStyle cardCustomLabel(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.medium,
    fontSize: 18 * scale,
    height: 1.35,
  );

  static TextStyle title(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.bold,
    fontSize: 24 * scale,
    height: 1.3,
    color: AppColors.bodyPrimary,
  );

  static TextStyle label(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.medium,
    fontSize: 14 * scale,
    height: 1.2,
    color: AppColors.bodySecondary,
  );

  static TextStyle description(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.light,
    fontSize: 16 * scale,
    height: 1.4,
    color: AppColors.bodyPrimary,
  );

  static TextStyle info(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.light,
    fontSize: 12 * scale,
    height: 1.0,
    color: AppColors.bodySecondary,
  );

  static TextStyle sectionHeader(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.bold,
    fontSize: 18 * scale,
    height: 1.2,
    color: AppColors.bodyPrimary,
  );

  static TextStyle tabLabel(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.medium,
    fontSize: 16 * scale,
    height: 1.0,
    color: AppColors.bodyPrimary,
  );

  static TextStyle listTitle(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.medium,
    fontSize: 16 * scale,
    height: 1.2,
    color: AppColors.bodyPrimary,
  );

  static TextStyle listSubtitle(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.light,
    fontSize: 12 * scale,
    height: 1.0,
    color: AppColors.bodySecondary,
  );

  static TextStyle pageTitle(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.bold,
    fontSize: 24 * scale,
    height: 1.08,
    color: AppColors.onPrimaryLight,
  );

  static TextStyle cardTitle(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaBold,
    fontWeight: AppFonts.medium,
    fontSize: 18 * scale,
    height: 1.35,
    color: AppColors.onPrimaryLight,
  );

  static TextStyle cardSubtitle(double scale) => TextStyle(
    fontFamily: AppFonts.helveticaRegular,
    fontWeight: AppFonts.light,
    fontSize: 11 * scale,
    height: 1.0,
    letterSpacing: 0.55 * scale,
    color: AppColors.bodySecondary,
  );


}
