import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/widgets/buttons/app_icon_action_button.dart';

/// 普通 AppBar 的分享按钮
/// 用于不带跑马灯效果的页面
class AppShareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const AppShareButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return AppIconActionButton(
      icon: AppIcons.share,
      iconColor: color ?? Colors.black87,
      size: size,
      onPressed: onPressed,
    );
  }
}

/// 跑马灯 SliverAppBar 的分享按钮
/// 用于带有跑马灯效果的页面，支持根据滚动位置动态改变样式
class SliverShareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double opacity;
  final double size;

  const SliverShareButton({
    super.key,
    required this.onPressed,
    this.opacity = 0.0,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = opacity > 0.5;

    return AppIconActionButton(
      icon: AppIcons.share,
      iconColor: isScrolled ? Colors.black87 : Colors.white,
      size: size,
      onPressed: onPressed,
      backgroundColor:
          isScrolled ? AppColors.surfaceMuted.withValues(alpha: 0.92) : Colors.black.withValues(alpha: 0.28),
    );
  }
}
