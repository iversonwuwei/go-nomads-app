import 'package:go_nomads_app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.arrowLeft,
        color: color ?? AppColors.textPrimary,
        size: size,
      ),
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
    
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isScrolled
            ? Colors.grey.withValues(alpha: 0.1)
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
          FontAwesomeIcons.arrowLeft,
          color: isScrolled ? Colors.black87 : Colors.white,
          size: size,
        ),
        onPressed: onPressed ?? () => Get.back(),
      ),
    );
  }
}
