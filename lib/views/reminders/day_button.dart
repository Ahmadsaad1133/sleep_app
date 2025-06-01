import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';

class DayButton extends StatelessWidget {
  final String day;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  static const Color _selectedBackgroundColor   = AppColors.onLightBg;
  static const Color _selectedBorderColor       = AppColors.onLightBg;
  static const Color _selectedTextColor         = AppColors.white;
  static const Color _unselectedBackgroundColor = AppColors.white;
  static const Color _unselectedBorderColor     = Color(0xFFE6E7F2);
  static const Color _unselectedTextColor       = AppColors.textGray;
  static const double _borderWidth              = 1.5;
  static const double _textSizeFactor           = 0.35;
  static const Duration _animationDuration      = Duration(milliseconds: 200);
  static const double _shadowBlurRadius         = 4.0;
  static const Offset _shadowOffset             = Offset(0, 2);
  static const double _scaleSelected            = 1.1;
  static const double _scaleUnselected          = 1.0;

  const DayButton({
    Key? key,
    required this.day,
    required this.isSelected,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? _selectedBackgroundColor
        : _unselectedBackgroundColor;
    final borderColor = isSelected
        ? _selectedBorderColor
        : _unselectedBorderColor;
    final textColor = isSelected
        ? _selectedTextColor
        : _unselectedTextColor;
    final scaleFactor = isSelected ? _scaleSelected : _scaleUnselected;

    return Semantics(
      label: 'Day $day button ${isSelected ? "selected" : "not selected"}',
      button: true,
      child: SizedBox(
        width: size,
        height: size,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: scaleFactor,
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: _animationDuration,
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: _borderWidth,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.onLightBg.withOpacity(0.4),
                      blurRadius: _shadowBlurRadius,
                      offset: _shadowOffset,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                    height: 1.0,
                  ),
                  style: TextStyle(
                    fontFamily: AppFonts.helveticaBold,
                    fontWeight: AppFonts.medium,
                    color: textColor,
                    fontSize: size * _textSizeFactor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
