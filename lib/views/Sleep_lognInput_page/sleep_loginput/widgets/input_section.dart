import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../constants/fonts.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';
import 'step_wrapper.dart';
class InputSection extends StatelessWidget {
  const InputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildHabitTilesRow(context);
  }

  Widget _buildHabitTilesRow(BuildContext context) {
    return SizedBox(
      // Increased height to prevent clipping
      height: 360,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Prevent clipping of child widgets
        clipBehavior: Clip.none,
        children: [
          _buildHabitTile(context, 'Coffee', Icons.coffee_maker_rounded, 'mg'),
          const SizedBox(width: 16),
          _buildHabitTile(context, 'Exercise', Icons.directions_run, 'min'),
          const SizedBox(width: 16),
          _buildHabitTile(context, 'Screen Time', Icons.phone_iphone, 'min'),
        ],
      ),
    );
  }

  Widget _buildHabitTile(
      BuildContext context, String label, IconData icon, String unit) {
    return SizedBox(
      width: 220,
      child: HabitTile(
        label: label,
        icon: icon,
        unit: unit,
        onValueChanged: (value) {
          final sleepLog = context.read<SleepLog>();
          try {
            switch (label) {
              case 'Coffee':
                sleepLog.setCaffeine(value);
                break;
              case 'Exercise':
                sleepLog.setExercise(value);
                break;
              case 'Screen Time':
                sleepLog.setScreenTime(value);
                break;
            }
          } catch (e) {
            debugPrint('Error updating $label: $e');
          }
        },
      ),
    );
  }
}

class HabitTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final String unit;
  final ValueChanged<String> onValueChanged;

  static const Map<String, int> maxValues = {
    'Coffee': 1000,
    'Exercise': 300,
    'Screen Time': 600,
  };

  const HabitTile({
    super.key,
    required this.label,
    required this.icon,
    required this.unit,
    required this.onValueChanged,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile>
    with SingleTickerProviderStateMixin {
  static const double kMainRadius = 50.0;
  static const double kInputRadius = 100.0;

  late final FocusNode _focusNode;
  late final TextEditingController _textController;
  late final AnimationController _controller;
  late final Animation<double> _orbitAnimation;
  late final Animation<double> _pulseAnimation;

  final ValueNotifier<bool> _isFocused = ValueNotifier(false);
  final ValueNotifier<bool> _showError = ValueNotifier(false);
  final ValueNotifier<int> _valueNotifier = ValueNotifier(0);

  // Cosmic color scheme
  Color get _primaryColor {
    switch (widget.label) {
      case 'Coffee':
        return const Color(0xFFFFD54F);
      case 'Exercise':
        return const Color(0xFF81C784);
      case 'Screen Time':
        return const Color(0xFF64B5F6);
      default:
        return const Color(0xFF4AC8FF);
    }
  }

  Color get _secondaryColor {
    switch (widget.label) {
      case 'Coffee':
        return const Color(0xFFE65100);
      case 'Exercise':
        return const Color(0xFF2E7D32);
      case 'Screen Time':
        return const Color(0xFF0D47A1);
      default:
        return const Color(0xFF0277BD);
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    _textController = TextEditingController(text: '0');
    _textController.addListener(_handleTextChange);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _orbitAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat();
    widget.onValueChanged('0');
  }

  void _handleTextChange() {
    final text = _textController.text;
    final value = text.isEmpty ? 0 : int.tryParse(text) ?? 0;
    _valueNotifier.value = value;
    widget.onValueChanged(text);

    if (_showError.value) _showError.value = false;
  }

  void _handleFocusChange() {
    _isFocused.value = _focusNode.hasFocus;
    if (!_focusNode.hasFocus) _validateInput();
  }

  void _validateInput() {
    if (_textController.text.isEmpty) {
      _textController.text = '0';
      return;
    }

    final value = int.tryParse(_textController.text);
    final maxValue = HabitTile.maxValues[widget.label] ?? 9999;
    final isError = value == null || value > maxValue;

    if (isError) {
      _showError.value = true;
      _textController.text = maxValue.toString();
      widget.onValueChanged(maxValue.toString());
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _showError.value = false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _textController.removeListener(_handleTextChange);
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCosmicOrbit(Animation<double> animation, double size, int count) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(count, (index) {
              final angle = (2 * pi * index) / count;
              final distance = size * 0.8;
              return Transform.translate(
                offset: Offset(
                  cos(angle) * distance,
                  sin(angle) * distance,
                ),
                child: Container(
                  width: size / 8,
                  height: size / 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryColor.withOpacity(0.7),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCosmicPlanet() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _primaryColor,
                  _secondaryColor,
                ],
                center: Alignment.topLeft,
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCosmicInputField(bool isFocused, bool showError) {
    return Column(
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kInputRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0x201A1F30),
                const Color(0x101A1F30),
              ],
            ),
            border: Border.all(
              color: isFocused
                  ? _primaryColor.withOpacity(0.5)
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                onSubmitted: (_) => _validateInput(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppFonts.ComfortaaLight,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                cursorColor: _primaryColor,
                cursorWidth: 4,
                cursorRadius: const Radius.circular(2),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Color(0x77B0C8DE),
                    fontSize: 28,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                child: Text(
                  widget.unit,
                  style: TextStyle(
                    color: isFocused
                        ? _primaryColor
                        : const Color(0xFFB0BEC5),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.ComfortaaLight,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showError,
          builder: (context, showError, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showError
                  ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: const Color(0xFFFF5252),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Max ${HabitTile.maxValues[widget.label]} ${widget.unit}',
                      style: TextStyle(
                        color: const Color(0xFFFF5252),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.ComfortaaLight,
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(height: 8),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_isFocused, _showError]),
      builder: (context, _) {
        final isFocused = _isFocused.value;
        final showError = _showError.value;

        return Container(
          margin: EdgeInsets.only(bottom: isFocused ? 5 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kMainRadius),
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [
                const Color(0x301A1F30),
                const Color(0x101A1F30),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kMainRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Padding(
                // Adjusted padding for better fit
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reduced container height and orbit sizes
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildCosmicOrbit(_orbitAnimation, 120, 10),
                          _buildCosmicOrbit(
                            Tween<double>(begin: 0, end: -2 * pi)
                                .animate(CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(0, 1, curve: Curves.linear),
                            )),
                            100,
                            8,
                          ),
                          _buildCosmicOrbit(
                            Tween<double>(begin: 0, end: 2 * pi)
                                .animate(CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(0, 1, curve: Curves.linear),
                            )),
                            80,
                            6,
                          ),
                          _buildCosmicPlanet(),
                        ],
                      ),
                    ),
                    // Reduced spacer heights
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: isFocused ? _primaryColor : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontFamily: AppFonts.ComfortaaLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCosmicInputField(isFocused, showError),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<int>(
                      valueListenable: _valueNotifier,
                      builder: (context, value, _) {
                        final maxValue = HabitTile.maxValues[widget.label] ?? 1000;
                        final pct = (value / maxValue).clamp(0.0, 1.0);
                        final isOverMax = value > maxValue;

                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: pct,
                              backgroundColor: const Color(0x33445566),
                              color: isOverMax ? const Color(0xFFFF5252) : _primaryColor,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$value ${widget.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: isOverMax ? const Color(0xFFFF5252) : const Color(0xFFB0BEC5),
                                    fontFamily: AppFonts.ComfortaaLight,
                                  ),
                                ),
                                Text(
                                  'Max $maxValue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: const Color(0xFFB0BEC5),
                                    fontFamily: AppFonts.ComfortaaLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}