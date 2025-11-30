import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.shareNodes,
        color: color ?? Colors.black87,
        size: size,
      ),
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

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isScrolled
            ? Colors.grey.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.shareNodes,
          color: isScrolled ? Colors.black87 : Colors.white,
          size: size,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
