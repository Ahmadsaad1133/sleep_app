// 2025 Futuristic Connected Design System (single-file, no extra packages needed)
// Drop in the same folder as your section files and import with:  import './future_design.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ---------- Palette & Tokens ----------
class NeoPalette {
  // deep space base + accent plasma
  static const Color base = Color(0xFF060814);
  static const Color surface = Color(0xFF0B0F22);
  static const Color glass = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x55A9B8FF);
  static const Color neonBlue = Color(0xFF76A5FF);
  static const Color neonPurple = Color(0xFFB07CFF);
  static const Color neonCyan = Color(0xFF59F6FF);
  static const Color good = Color(0xFF7CFFB0);
  static const Color warn = Color(0xFFFFE37C);
  static const Color bad = Color(0xFFFF8D7C);

  static const List<Color> plasma = [
    Color(0xFF76A5FF),
    Color(0xFFB07CFF),
    Color(0xFF59F6FF),
  ];
}

class NeoText {
  static TextStyle h1(BuildContext c) => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: Colors.white,
  );

  static TextStyle h2(BuildContext c) => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle sub(BuildContext c) => TextStyle(
    fontSize: 12.sp,
    height: 1.35,
    color: Colors.white.withOpacity(.75),
  );

  static TextStyle numXL(BuildContext c) => TextStyle(
    fontSize: 30.sp,
    fontFeatures: const [ui.FontFeature.tabularFigures()],
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle numM(BuildContext c) => TextStyle(
    fontSize: 14.sp,
    fontFeatures: const [ui.FontFeature.tabularFigures()],
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

// ---------- Background Aurora ----------
class AuroraBackground extends StatelessWidget {
  final Widget child;
  final double blur;
  const AuroraBackground({super.key, required this.child, this.blur = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NeoPalette.base, NeoPalette.surface],
        ),
      ),
      child: Stack(
        children: [
          // soft aurora blobs
          Positioned(
            left: -120.w,
            top: -90.h,
            child: _AuroraBlob(size: 260.w, colors: const [NeoPalette.neonPurple, NeoPalette.neonBlue]),
          ),
          Positioned(
            right: -140.w,
            bottom: -120.h,
            child: _AuroraBlob(size: 320.w, colors: const [NeoPalette.neonCyan, NeoPalette.neonBlue]),
          ),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(color: Colors.transparent),
          ),
          child
        ],
      ),
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _AuroraBlob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors.map((c) => c.withOpacity(.35)).toList(),
        ),
      ),
    );
  }
}

// ---------- Glass Card ----------
class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final GestureTapCallback? onTap;
  final bool glow;

  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: NeoPalette.glass,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: NeoPalette.glassBorder.withOpacity(.5),
          width: 1,
        ),
        boxShadow: glow
            ? [
          BoxShadow(
            color: NeoPalette.neonBlue.withOpacity(.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: onTap != null ? InkWell(onTap: onTap, child: card) : card,
      ),
    );
  }
}

// ---------- Section header ----------
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  const SectionHeader({super.key, required this.title, this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: NeoText.h2(context)),
              if (subtitle != null) SizedBox(height: 6.h),
              if (subtitle != null) Text(subtitle!, style: NeoText.sub(context)),
            ],
          ),
        ),
        if (actions != null) Row(children: actions!),
      ],
    );
  }
}

// ---------- Pills & Bars ----------
class MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const MetricPill({super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (color ?? Colors.white).withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: NeoText.sub(context)),
          SizedBox(width: 8.w),
          Text(value, style: NeoText.numM(context)),
        ],
      ),
    );
  }
}

class PlasmaBar extends StatelessWidget {
  final double ratio; // 0..1
  final String label;
  const PlasmaBar({super.key, required this.ratio, required this.label});

  @override
  Widget build(BuildContext context) {
    final clamped = ratio.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 10.h,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withOpacity(.07)),
                      FractionallySizedBox(
                        widthFactor: clamped,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [NeoPalette.neonBlue, NeoPalette.neonPurple, NeoPalette.neonCyan],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text("${(clamped * 100).round()}%", style: NeoText.sub(context)),
          ],
        ),
        SizedBox(height: 6.h),
        Text(label, style: NeoText.sub(context)),
      ],
    );
  }
}

// ---------- Simple orb gauge ----------
class OrbitalGauge extends StatelessWidget {
  final double score; // 0..10
  final String label;
  final double size;
  const OrbitalGauge({super.key, required this.score, required this.label, this.size = 140});

  Color get _scoreColor {
    if (score >= 8) return NeoPalette.good;
    if (score >= 5) return NeoPalette.warn;
    return NeoPalette.bad;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (score / 10).clamp(0.0, 1.0);
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background ring
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [NeoPalette.neonBlue, NeoPalette.neonPurple, NeoPalette.neonCyan, NeoPalette.neonBlue],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NeoPalette.surface.withOpacity(.8),
                ),
              ),
            ),
          ),
          // progress arc (simple)
          SizedBox(
            width: (size - 16).w,
            height: (size - 16).w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ArcPainter(value, _scoreColor),
                );
              },
            ),
          ),
          // center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(score.toStringAsFixed(1), style: NeoText.numXL(context)),
              SizedBox(height: 4.h),
              Text(label, style: NeoText.sub(context)),
            ],
          )
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double pct; final Color color;
  _ArcPainter(this.pct, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.white.withOpacity(.08);
    canvas.drawArc(rect.deflate(2), -pi/2, 2*pi, false, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..shader = ui.Gradient.linear(
        const Offset(0, 0), Offset(size.width, 0),
        [color.withOpacity(.9), Colors.white.withOpacity(.9)],
      );
    canvas.drawArc(rect.deflate(2), -pi/2, 2*pi * pct, false, fg);
  }
  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.pct != pct || old.color != color;
}

// ---------- Helpers ----------
Color scoreColor(double s) {
  if (s >= 8) return NeoPalette.good;
  if (s >= 5) return NeoPalette.warn;
  return NeoPalette.bad;
}