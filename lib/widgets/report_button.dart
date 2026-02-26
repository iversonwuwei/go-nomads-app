import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 普通 AppBar 的举报按钮
/// Normal AppBar report button
class AppReportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const AppReportButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.flag,
        color: color ?? Colors.orange,
        size: size,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// 跑马灯 SliverAppBar 的举报按钮
/// Sliver AppBar report button with matching share button style
class SliverReportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double opacity;
  final double size;
  final String? tooltip;

  const SliverReportButton({
    super.key,
    required this.onPressed,
    this.opacity = 0.0,
    this.size = 18,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = opacity > 0.5;

    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isScrolled
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.flag,
          color: isScrolled ? Colors.orange : Colors.white,
          size: size,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
