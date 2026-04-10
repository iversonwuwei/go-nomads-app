import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/widgets/buttons/app_icon_action_button.dart';

/// 普通 AppBar 的回退按钮
/// 用于不带跑马灯效果的页面
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return AppIconActionButton(
      icon: AppIcons.back,
      iconColor: color ?? AppColors.textPrimary,
      size: size,
      onPressed: onPressed ?? () => Get.back(),
    );
  }
}

/// 跑马灯 SliverAppBar 的回退按钮
/// 用于带有跑马灯效果的页面，支持根据滚动位置动态改变样式
class SliverBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double opacity;
  final double size;

  const SliverBackButton({
    super.key,
    this.onPressed,
    this.opacity = 0.0,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = opacity > 0.5;

    return AppIconActionButton(
      icon: AppIcons.back,
      iconColor: isScrolled ? Colors.black87 : Colors.white,
      size: size,
      onPressed: onPressed ?? () => Get.back(),
      backgroundColor:
          isScrolled ? AppColors.surfaceMuted.withValues(alpha: 0.92) : Colors.black.withValues(alpha: 0.28),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.w),
    );
  }
}
