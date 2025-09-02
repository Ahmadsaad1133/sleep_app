// lib/widgets/mini_pc_panel.dart
// v8 — PC-screen style panel
// - Progress can be derived from dots: if `externalProgress` is null,
//   we compute progress = (activeStepIndex + stepSubProgress) / steps.length.
// - Optional `stepSubProgress` (0..1) for smooth fill between dots.
// - Uses flutter_screenutil for responsive sizes (expects ScreenUtil to be initialized).

import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniPCPanel extends StatefulWidget {
  final double panelWidth;
  final double? panelHeight;
  final double? externalProgress;
  final double? stepSubProgress; // 0..1 (progress within the active step)
  final String? externalLabel;
  final String? title;
  final String? description;
  final bool cameraSweep;
  final bool dense;

  /// Show text label inside the screen
  final bool showLabel;

  /// Show numeric percent inside the screen
  final bool showPercent;

  /// Optional step labels for dot indicators inside the screen
  final List<String>? steps;

  /// Active step index (0-based)
  final int? activeStepIndex;

  const MiniPCPanel({
    super.key,
    required this.panelWidth,
    this.panelHeight,
    this.externalProgress,
    this.stepSubProgress,
    this.externalLabel,
    this.title,
    this.description,
    this.cameraSweep = true,
    this.dense = false,
    this.showLabel = true,
    this.showPercent = true,
    this.steps,
    this.activeStepIndex,
  });

  @override
  State<MiniPCPanel> createState() => _MiniPCPanelState();
}

class _MiniPCPanelState extends State<MiniPCPanel> {
  @override
  Widget build(BuildContext context) {
    final w = widget.panelWidth.clamp(220.0, 1600.0);
    final h = (widget.panelHeight ?? (w * 0.68)).clamp(180.0, 1800.0);
    final dense = widget.dense || w < 320;

    return SizedBox(
      width: w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null && widget.title!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: dense ? 6.h : 10.h),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          _MonitorBody(
            width: w,
            height: h,
            progress: widget.externalProgress,
            stepSubProgress: widget.stepSubProgress,
            label: widget.externalLabel,
            cameraSweep: widget.cameraSweep,
            dense: dense,
            showLabel: widget.showLabel,
            showPercent: widget.showPercent,
            steps: widget.steps,
            activeStepIndex: widget.activeStepIndex,
          ),
          _Stand(width: w, dense: dense),
          if (widget.description != null &&
              widget.description!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: dense ? 6.h : 10.h),
              child: Text(
                widget.description!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonitorBody extends StatelessWidget {
  final double width;
  final double height;
  final double? progress;
  final double? stepSubProgress;
  final String? label;
  final bool cameraSweep;
  final bool dense;
  final bool showLabel;
  final bool showPercent;
  final List<String>? steps;
  final int? activeStepIndex;

  const _MonitorBody({
    required this.width,
    required this.height,
    required this.progress,
    required this.stepSubProgress,
    required this.label,
    required this.cameraSweep,
    required this.dense,
    required this.showLabel,
    required this.showPercent,
    this.steps,
    this.activeStepIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bezel = math.max(10.0, width * 0.018);
    final radius = math.max(14.0, width * 0.025);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F14),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 18.r,
            offset: Offset(0, 12.h),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Inner screen
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(bezel),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius * 0.6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // subtle gradient background
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF151A27), Color(0xFF0F1320)],
                        ),
                      ),
                    ),
                    // scanline
                    CustomPaint(painter: _ScanlinePainter(opacity: 0.05)),
                    // Loading contents
                    _LoadingContents(
                      progress: progress,
                      stepSubProgress: stepSubProgress,
                      label: label,
                      dense: dense,
                      showLabel: showLabel,
                      showPercent: showPercent,
                      steps: steps,
                      activeStepIndex: activeStepIndex,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (cameraSweep)
            const Positioned(
              top: 6,
              left: 0,
              right: 0,
              child: _CameraBar(),
            ),
        ],
      ),
    );
  }
}

class _LoadingContents extends StatelessWidget {
  final double? progress;
  final double? stepSubProgress;
  final String? label;
  final bool dense;
  final bool showLabel;
  final bool showPercent;
  final List<String>? steps;
  final int? activeStepIndex;

  const _LoadingContents({
    this.progress,
    this.stepSubProgress,
    this.label,
    required this.dense,
    this.showLabel = true,
    this.showPercent = true,
    this.steps,
    this.activeStepIndex,
  });

  double _derivedProgress() {
    if (progress != null) return progress!.clamp(0.0, 1.0);
    final total = steps?.length ?? 0;
    if (total <= 0 || activeStepIndex == null) return 0.0;
    final idx = activeStepIndex!.clamp(0, total - 1);
    final sub = (stepSubProgress ?? 0.0).clamp(0.0, 1.0);
    return ((idx + sub) / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final pct = _derivedProgress();
    final hasDots = steps != null && steps!.isNotEmpty && activeStepIndex != null;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 6.w : 10.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Icon
              Icon(
                Icons.nightlight_round,
                size: (dense ? 18.sp : 22.sp), // much smaller
                color: Colors.white.withOpacity(0.9),
              ),

              if (!dense) ...[
                SizedBox(height: 4.h),
                Text(
                  'AI Sleep Analysis',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp, // smaller
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Harnessing cosmic patterns and dream insights to decode your nightly journey.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 9.sp, // compact
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),

                /// Pills
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _InfoPill(icon: Icons.psychology_alt, label: 'Dreams', dense: true),
                    _InfoPill(icon: Icons.eco, label: 'Environment', dense: true),
                    _InfoPill(icon: Icons.bedtime, label: 'Quality', dense: true),
                    _InfoPill(icon: Icons.auto_graph, label: 'Forecast', dense: true),
                  ],
                ),
              ],

              if (showLabel) ...[
                SizedBox(height: 6.h),
                Text(
                  label ?? 'Preparing your Sleep Analysis…',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp, // smaller
                  ),
                ),
              ],

              if (hasDots) ...[
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(steps!.length, (i) {
                    final isActive = i == activeStepIndex;
                    final isCompleted = i < (activeStepIndex ?? 0);
                    final Color color = isCompleted
                        ? const Color(0xFF6FA8FF)
                        : (isActive ? Colors.white : Colors.white24);
                    return Container(
                      width: (dense ? 6.w : 8.w), // smaller dots
                      height: (dense ? 6.w : 8.w),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 0.6,
                        ),
                      ),
                    );
                  }),
                ),
              ],

              SizedBox(height: 8.h),
              _ProgressBar(value: pct),

              if (showPercent) ...[
                SizedBox(height: 4.h),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.2,
                    fontSize: 10.sp, // compact
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final filled = (width * value).clamp(0.0, width);
        return Container(
          width: width,
          height: 10.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: filled,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF5B8CFF), Color(0xFF8F6BFF)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CameraBar extends StatelessWidget {
  const _CameraBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.6),
                  blurRadius: 6.r,
                  spreadRadius: 0.5,
                )
              ],
            ),
          ),
          Positioned(left: 20.w, child: _micHoleRow()),
          Positioned(right: 20.w, child: _micHoleRow()),
        ],
      ),
    );
  }

  Widget _micHoleRow() {
    return Row(
      children: List.generate(
        3,
            (_) => Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3.r),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
          ),
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  const _ScanlinePainter({this.opacity = 0.04});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    const spacing = 3.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

class _Stand extends StatelessWidget {
  final double width;
  final bool dense;
  const _Stand({required this.width, required this.dense});

  @override
  Widget build(BuildContext context) {
    final baseW = width * 0.34;
    final neckH = math.max(16.0, width * 0.05);
    final neckW = math.max(8.0, width * 0.025);
    return Column(
      children: [
        SizedBox(height: dense ? 8.h : 12.h),
        Container(
          width: neckW,
          height: neckH,
          decoration: BoxDecoration(
            color: const Color(0xFF151822),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
              )
            ],
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        SizedBox(height: dense ? 6.h : 8.h),
        Container(
          width: baseW,
          height: math.max(10.0, width * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFF151822),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10.r,
                offset: Offset(0, 6.h),
              )
            ],
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
        ),
      ],
    );
  }
}
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dense;

  const _InfoPill({
    required this.icon,
    required this.label,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8.w : 12.w,
        vertical: dense ? 4.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 14.sp : 18.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: dense ? 11.sp : 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}



