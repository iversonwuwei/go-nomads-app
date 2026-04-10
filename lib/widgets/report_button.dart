import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/widgets/buttons/app_icon_action_button.dart';

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
    return AppIconActionButton(
      icon: AppIcons.report,
      iconColor: color ?? AppColors.feedbackWarningDark,
      size: size,
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

    return AppIconActionButton(
      icon: AppIcons.report,
      iconColor: isScrolled ? AppColors.feedbackWarningDark : Colors.white,
      size: size,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor:
          isScrolled ? AppColors.feedbackWarning.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.28),
    );
  }
}
