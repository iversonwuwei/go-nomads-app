import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';

class NomadCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;
  final BoxBorder? border;

  const NomadCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final content = CockpitPanel(
      padding: padding ?? const EdgeInsets.all(16.0),
      backgroundColor: color ?? (isDarkMode ? const Color(0xFF1E1E1E).withValues(alpha: 0.68) : Colors.white.withValues(alpha: 0.68)),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius ?? 24.0),
            onTap: onTap,
            child: content,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: content,
    );
  }
}
