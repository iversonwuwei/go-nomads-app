import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';

class AppCardSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AppCardSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.border,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final shape = borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : BorderRadius.circular(24.r);
    final decoratedChild = Ink(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border ?? Border.all(color: AppColors.borderLight),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap == null && onLongPress == null) {
      return decoratedChild;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: shape,
        child: decoratedChild,
      ),
    );
  }
}
