import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.padding,
    this.fontSize,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = backgroundColor ?? AppColors.cityPrimary;
    final effectiveForeground = foregroundColor ?? Colors.white;

    return SizedBox(
      width: double.infinity,
      height: height ?? AppUiTokens.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: effectiveBackground,
          foregroundColor: effectiveForeground,
          disabledBackgroundColor: effectiveBackground.withValues(alpha: 0.5),
          padding: padding ?? EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: effectiveForeground,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: fontSize ?? 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
