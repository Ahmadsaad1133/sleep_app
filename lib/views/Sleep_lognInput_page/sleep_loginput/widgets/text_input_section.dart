// text_input_section.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../constants/fonts.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class TextInputSection extends StatelessWidget {
  const TextInputSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('COSMIC NOTES'),
        const SizedBox(height: 24),
        SleepTextInputField(
          label: 'Diet Notes (dinner/snacks)',
          icon: Icons.restaurant,
          controller: (value) => context.read<SleepLog>().setDietNotes(value),
          maxLength: 200,
          hintExamples: const [
            'Had grilled salmon with veggies at 7pm',
            'Late night snack: almonds and banana',
            'Drank chamomile tea before bed'
          ],
        ),
        const SizedBox(height: 28),
        SleepTextInputField(
          label: 'Medications & Supplements',
          icon: Icons.medical_services,
          controller: (value) => context.read<SleepLog>().setMedications(value),
          maxLength: 150,
          hintExamples: const [
            'Took magnesium supplement at 8pm',
            'Prescription: 10mg melatonin',
            'CBD oil 30 minutes before sleep'
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.blueGrey[100]!.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Record anything that might affect your cosmic sleep',
            child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.blueGrey[200]!.withOpacity(0.7)
            ),
          ),
        ],
      ),
    );
  }
}

class SleepTextInputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final Function(String) controller;
  final int maxLength;
  final List<String> hintExamples;

  const SleepTextInputField({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.maxLength = 100,
    this.hintExamples = const [],
  }) : super(key: key);

  @override
  _SleepTextInputFieldState createState() => _SleepTextInputFieldState();
}

class _SleepTextInputFieldState extends State<SleepTextInputField>
    with TickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  bool _isFocused = false;
  bool _showHintExamples = false;
  final TextEditingController _textController = TextEditingController();
  final List<AnimationController> _starControllers = [];
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize star controllers
    for (int i = 0; i < 3; i++) {
      _starControllers.add(
          AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1200),
          )
      );
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _textController.text.isEmpty) {
        setState(() => _showHintExamples = true);
        _animateStars();
      }
    });
  }

  void _animateStars() {
    if (_showHintExamples) {
      for (int i = 0; i < _starControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 300), () {
          if (mounted) _starControllers[i].repeat(reverse: true);
        });
      }
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_isFocused) {
      _controller.forward();
      setState(() => _showHintExamples = false);
    } else {
      _controller.reverse();
      if (_textController.text.isEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _showHintExamples = true);
        });
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    _controller.dispose();
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nebula label
        Container(
          padding: const EdgeInsets.only(left: 12, bottom: 6),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isFocused
                  ? const Color(0xFF5A6BC0)
                  : Colors.blueGrey[300]!.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontFamily: AppFonts.ComfortaaBold,
            ),
          ),
        ),

        // Cosmic input field
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 2.0,
                  colors: [
                    Colors.blueGrey.withOpacity(0.1),
                    Colors.blueGrey.withOpacity(0.2),
                    const Color(0xFF0D1B2A).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  if (_isFocused)
                    BoxShadow(
                      color: const Color(0xFF5A6BC0).withOpacity(0.4 * _glowAnimation.value),
                      blurRadius: 20 + (15 * _glowAnimation.value),
                      spreadRadius: 1,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isFocused
                            ? const Color(0xFF5A6BC0).withOpacity(0.5)
                            : Colors.blueGrey.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Cosmic star pattern
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: CustomPaint(
                              painter: _CosmicPatternPainter(_random),
                            ),
                          ),
                        ),

                        // Input field content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: TextFormField(
                            controller: _textController,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              widget.controller(value);
                              if (value.isNotEmpty) setState(() => _showHintExamples = false);
                            },
                            maxLines: 3,
                            minLines: 1,
                            maxLength: widget.maxLength,
                            style: TextStyle(
                              color: Colors.blueGrey[100],
                              fontSize: 16,
                              fontFamily: AppFonts.ComfortaaLight,
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                            cursorColor: const Color(0xFF5A6BC0),
                            cursorWidth: 2,
                            cursorRadius: const Radius.circular(2),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  widget.icon,
                                  color: _isFocused
                                      ? const Color(0xFF5A6BC0)
                                      : Colors.blueGrey[300]!.withOpacity(0.7),
                                  size: 24,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 8),
                              counterText: '',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Tap to enter cosmic notes...',
                              hintStyle: TextStyle(
                                color: Colors.blueGrey[300]!.withOpacity(0.4),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),

                        // Orbital character counter
                        if (_textController.text.isNotEmpty)
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: _buildOrbitalCounter(),
                          ),

                        // Supernova clear button
                        if (_textController.text.isNotEmpty)
                          Positioned(
                            right: 16,
                            top: 16,
                            child: GestureDetector(
                              onTap: () {
                                _textController.clear();
                                widget.controller('');
                                setState(() => _showHintExamples = true);
                                _animateStars();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFF6B6B).withOpacity(0.6),
                                      const Color(0xFFFF6B6B).withOpacity(0.3),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.clear_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Animated cosmic examples
        if (_showHintExamples && _textController.text.isEmpty)
          _buildCosmicExamples(),
      ],
    );
  }

  Widget _buildOrbitalCounter() {
    final length = _textController.text.length;
    final max = widget.maxLength;
    final percent = length / max;
    Color color = Colors.blueGrey[300]!;

    if (percent > 0.9) {
      color = const Color(0xFFFF6B6B);
    } else if (percent > 0.7) {
      color = const Color(0xFFFFD166);
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _OrbitalCounterPainter(percent, color),
        child: Center(
          child: Text(
            '$length',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCosmicExamples() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Cosmic suggestions:',
              style: TextStyle(
                color: Colors.blueGrey[300]!.withOpacity(0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.hintExamples.take(3).map((example) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                _textController.text = example;
                widget.controller(example);
                setState(() => _showHintExamples = false);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated star
                  ScaleTransition(
                    scale: _starControllers[widget.hintExamples.indexOf(example)]
                        .drive(CurveTween(curve: Curves.easeOut)),
                    child: FadeTransition(
                      opacity: _starControllers[widget.hintExamples.indexOf(example)],
                      child: Icon(
                        Icons.star_rounded,
                        color: const Color(0xFF5A6BC0).withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      example,
                      style: TextStyle(
                        color: Colors.blueGrey[200]!.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _OrbitalCounterPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OrbitalCounterPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw orbit path
    final orbitPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, orbitPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw orbiting dot
    final dotAngle = -pi / 2 + sweepAngle;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CosmicPatternPainter extends CustomPainter {
  final Random random;

  _CosmicPatternPainter(this.random);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw stars
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 0.8;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw small nebulae
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 5 + random.nextDouble() * 15;

      canvas.drawCircle(
          Offset(x, y),
          radius,
          paint..color = const Color(0xFF5A6BC0).withOpacity(0.03)
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}