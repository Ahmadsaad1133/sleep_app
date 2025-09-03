import 'package:flutter/material.dart';

/// A responsive container used by each step in the sleep log flow.
/// It constrains the content width and provides consistent paddings
/// and animated transitions.
class StepWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;

  const StepWrapper({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final padding = EdgeInsets.symmetric(
          horizontal: isWide ? 64.0 : 24.0,
          vertical: 24.0,
        );
        final colors = Theme.of(context).colorScheme;


        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface,
                colors.surfaceVariant,
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (icon != null)
                          Icon(icon, size: 28, color: colors.primary),
                        if (icon != null) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
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
        ),/////
            ),
          ),
        );
      },
    );
  }
}