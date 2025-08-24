// lib/widgets/quality_section.dart
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

const int kMaxQuality = 10;

class QualitySection extends StatelessWidget {
  const QualitySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('COSMIC SLEEP QUALITY', icon: Icons.star_border),
        SizedBox(height: ScreenUtils.height(16)),
        const _QualityCard(),
      ],
    );
  }
}

class _QualityCard extends StatelessWidget {
  const _QualityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScreenUtils.paddingAll(20),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(-0.5, -0.5),
          radius: 1.2,
          colors: [Color(0xFF0F1B3A), Color(0xFF050A1A)],
          stops: [0.2, 0.8],
        ),
        borderRadius: BorderRadius.circular(ScreenUtils.scale(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const _QualityContent(),
          // Lottie animation wrapped in IgnorePointer so it doesn't block touches
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Lottie.asset(
                    'assets/animations/cosmic_back.json',
                    width: ScreenUtils.width(500),
                    height: ScreenUtils.height(500),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Rest of the file remains unchanged

class _QualityContent extends StatelessWidget {
  const _QualityContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepLog>(
      builder: (context, log, _) {
        final quality = log.quality.clamp(1, kMaxQuality);
        final qualityColor = _colorFor(quality);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: quality >= 8 ? 1.2 : 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [qualityColor.withOpacity(0.1), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    ..._buildStarParticles(quality, scale),
                    Container(
                      padding: EdgeInsets.all(ScreenUtils.scale(8)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [qualityColor.withOpacity(0.3), Colors.transparent],
                          stops: const [0.5, 1.0],
                        ),
                        boxShadow: quality >= 8
                            ? [BoxShadow(color: qualityColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)]
                            : null,
                      ),
                      child: SizedBox(
                        width: ScreenUtils.width(180),
                        height: ScreenUtils.height(180),
                        child: LiquidCircularProgressIndicator(
                          value: quality / kMaxQuality,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
                          borderColor: Colors.transparent,
                          borderWidth: 0,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$quality',
                                style: TextStyle(
                                  fontSize: ScreenUtils.textScale(42),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [Shadow(blurRadius: 15, color: qualityColor.withOpacity(0.7))],
                                ),
                              ),
                              SizedBox(height: ScreenUtils.height(4)),
                              Text(
                                'COSMIC RATING',
                                style: TextStyle(
                                  fontSize: ScreenUtils.textScale(12),
                                  color: Colors.blueGrey[200],
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.height(24)),
                _QualityIndicator(
                  quality: quality,
                  qualityColor: qualityColor,
                  onChanged: (val) {
                    final newQ = val.round();
                    final wasHigh = log.quality >= 8;
                    log.setQuality(newQ);
                    if (newQ >= 8 && !wasHigh) HapticFeedback.vibrate();
                  },
                ),
                SizedBox(height: ScreenUtils.height(24)),
                _SleepTipBox(quality: quality),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildStarParticles(int quality, double scale) {
    final particles = <Widget>[];
    final particleCount = quality * 3;
    final particleColor = _colorFor(quality);
    for (var i = 0; i < particleCount; i++) {
      final angle = 2 * pi * i / particleCount;
      final distance = ScreenUtils.width(90) + ScreenUtils.width(20) * (i % 3);
      final size = ScreenUtils.width(2 + (i % 4));
      final animationDelay = i * 100;
      particles.add(Positioned(
        left: distance * cos(angle),
        top: distance * sin(angle),
        child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + animationDelay),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: particleColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: particleColor, blurRadius: 4, spreadRadius: 1)],
                  ),
                ),
              ),
            );
          },
        ),
      ));
    }
    return particles;
  }

  Color _colorFor(int q) {
    if (q >= 8) return const Color(0xFF5D8BFF);
    if (q >= 6) return const Color(0xFF7C4DFF);
    if (q >= 4) return const Color(0xFFFFA000);
    return const Color(0xFFFF5252);
  }
}

class _SleepTipBox extends StatelessWidget {
  final int quality;
  const _SleepTipBox({required this.quality});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(quality);
    return Container(
      padding: ScreenUtils.symmetric(h: 16, v: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), Colors.black.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtils.scale(16)),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (rect) => RadialGradient(
              center: Alignment.center,
              colors: [color, color.withOpacity(0.7)],
            ).createShader(rect),
            child: Icon(_getSleepTipIcon(quality), color: Colors.white, size: ScreenUtils.textScale(24)),
          ),
          SizedBox(width: ScreenUtils.width(12)),
          Flexible(
            child: AutoSizeText(
    _getSleepTip(quality),
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.blueGrey[100],
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.8,
    fontSize: ScreenUtils.textScale(15),
    ),
    maxLines: 1,
    minFontSize: 10,
    overflow: TextOverflow.ellipsis, // use overflow, avoid overflowReplacement if problematic
            ),
          ),
        ],
      ),
    );
  }


  String _getSleepTip(int q) {
    if (q >= 8) return 'Stellar sleep! Your cosmic rhythm is perfect';
    if (q >= 6) return 'Good orbit! Align with your cosmic sleep cycle';
    if (q >= 4) return 'Interstellar turbulence detected. Seek cosmic balance';
    return 'Black hole sleep. Realign with the cosmic sleep nebula';
  }

  IconData _getSleepTipIcon(int q) {
    if (q >= 8) return Icons.rocket_launch;
    if (q >= 6) return Icons.nights_stay;
    if (q >= 4) return Icons.satellite_alt;
    return Icons.warning_amber_rounded;
  }

  Color _colorFor(int q) {
    if (q >= 8) return const Color(0xFF5D8BFF);
    if (q >= 6) return const Color(0xFF7C4DFF);
    if (q >= 4) return const Color(0xFFFFA000);
    return const Color(0xFFFF5252);
  }
}

class _QualityIndicator extends StatelessWidget {
  final int quality;
  final Color qualityColor;
  final ValueChanged<double> onChanged;

  const _QualityIndicator({required this.quality, required this.qualityColor, required this.onChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: ScreenUtils.symmetric(h: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _QualitySegment(label: 'NEBULA'),
              _QualitySegment(label: 'GALAXY'),
              _QualitySegment(label: 'STAR'),
              _QualitySegment(label: 'COSMOS'),
            ],
          ),
        ),
        SizedBox(height: ScreenUtils.height(16)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: qualityColor,
            inactiveTrackColor: Colors.blueGrey.withOpacity(0.2),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            overlayColor: qualityColor.withOpacity(0.2),
            trackHeight: ScreenUtils.height(6),
            trackShape: const RoundedRectSliderTrackShape(),
            showValueIndicator: ShowValueIndicator.never,
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
          ),
          child: Slider(value: quality.toDouble(), min: 1, max: kMaxQuality.toDouble(), divisions: kMaxQuality - 1, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _QualitySegment extends StatelessWidget {
  final String label;
  const _QualitySegment({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: Colors.blueGrey[300], fontSize: ScreenUtils.textScale(12), fontWeight: FontWeight.w600, letterSpacing: 0.8),
    );
  }
}
