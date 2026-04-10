import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

class AppIconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final double size;
  final String? tooltip;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;

  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.iconColor,
    this.size = 20,
    this.tooltip,
    this.backgroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, color: iconColor, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.all(8.w),
      constraints: const BoxConstraints(),
    );

    if (backgroundColor == null) {
      return button;
    }

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: button,
    );
  }
}
