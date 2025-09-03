import 'dart:ui';

import 'package:flutter/material.dart';

/// A responsive container used by each step in the sleep log flow.
/// It constrains the content width and provides consistent paddings
/// and animated transitions.
class StepWrapper extends StatelessWidget {
  final String title;
  /// Optional subtitle shown below the title for additional context.
  final String? subtitle;

  /// The main content of the step.
  final Widget child;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  /// Maximum width of the content inside the wrapper.
  final double maxContentWidth;

  const StepWrapper({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.subtitle,
    this.padding,
    this.maxContentWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final resolvedPadding = padding ??
            EdgeInsets.symmetric(
              horizontal: isWide ? 64.0 : 24.0,
              vertical: 24.0,
            );
        final colors = Theme.of(context).colorScheme;

        return ClipRRect(
            borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: resolvedPadding,
        decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline.withOpacity(0.2)),
        boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 24,
        offset: const Offset(0, 8),
        ),
        ],
              ),
        child: Center(
        child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
        Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        if (icon != null)
        Icon(icon, size: 24, color: colors.primary),
        if (icon != null) const SizedBox(width: 8),
        Expanded(
        child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
        ),
        ),
        ],
                        ),
            if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            ],
            const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                          child: child,
                        ),
        ],
                    ),
                  ],
                ),
              ),
            ),
          ),
                )));

      },
    );
  }
}
