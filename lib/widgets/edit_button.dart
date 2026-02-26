import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 普通 AppBar 的编辑按钮
/// 用于不带跑马灯效果的页面，带有渐变背景和阴影
class AppEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final IconData? icon;
  final String? tooltip;
  final bool mini;

  const AppEditButton({
    super.key,
    required this.onPressed,
    this.size = 18,
    this.icon,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = mini ? 8.0 : 10.0;
    final borderRadius = mini ? 10.0 : 12.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: mini ? 4 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: FaIcon(
              icon ?? FontAwesomeIcons.penToSquare,
              color: const Color(0xFF4CAF50),
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

/// 带主题色的编辑按钮
/// 用于强调编辑操作的场景
class AppEditButtonPrimary extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final IconData? icon;
  final String? tooltip;

  const AppEditButtonPrimary({
    super.key,
    required this.onPressed,
    this.size = 18,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: FaIcon(
              icon ?? FontAwesomeIcons.penToSquare,
              color: Colors.white,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

/// 跑马灯 SliverAppBar 的编辑按钮
/// 用于带有跑马灯效果的页面，支持根据滚动位置动态改变样式
class SliverEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double opacity;
  final double size;
  final IconData? icon;
  final String? tooltip;

  const SliverEditButton({
    super.key,
    required this.onPressed,
    this.opacity = 0.0,
    this.size = 20,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = opacity > 0.5;

    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isScrolled ? Colors.grey.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.3),
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
          icon ?? FontAwesomeIcons.penToSquare,
          color: isScrolled ? Colors.black87 : Colors.white,
          size: size,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

/// 通用的 SliverAppBar 操作按钮
/// 支持自定义图标，用于需要动态切换图标的场景
class SliverActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double opacity;
  final double size;
  final IconData icon;
  final String? tooltip;

  const SliverActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.opacity = 0.0,
    this.size = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = opacity > 0.5;

    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isScrolled ? Colors.grey.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.3),
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
        icon: Icon(
          icon,
          color: isScrolled ? Colors.black87 : Colors.white,
          size: size,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
