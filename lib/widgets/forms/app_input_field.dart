import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLength;
  final double? compactHeight;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const AppInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.maxLength,
    this.compactHeight,
    this.inputFormatters,
    this.enabled = true,
  });

  bool _isControllerValid(TextEditingController? value) {
    if (value == null) return false;
    try {
      value.text;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerValid(controller)) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          ),
        ),
      );
    }

    final hasError = errorText != null && errorText!.isNotEmpty;
    final targetHeight = compactHeight ?? AppUiTokens.inputHeight;
    final decorationConstraints = BoxConstraints(
      minHeight: targetHeight,
      maxHeight: targetHeight,
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        counterText: maxLength != null ? '' : null,
        filled: true,
        fillColor: enabled ? AppColors.surfaceMuted : AppColors.surfaceDisabled,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        constraints: decorationConstraints,
        prefixIcon: Icon(prefixIcon, color: hasError ? AppColors.feedbackError : AppColors.icon),
        prefixIconConstraints: BoxConstraints(
          minWidth: 48.w,
          minHeight: targetHeight,
        ),
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14.sp,
        ),
        labelStyle: TextStyle(
          color: hasError ? AppColors.feedbackError : AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          borderSide: BorderSide(
            color: hasError ? AppColors.feedbackError.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          borderSide: BorderSide(
            color: hasError ? AppColors.feedbackError : AppColors.cityPrimary,
            width: 1.6,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          borderSide: BorderSide(color: AppColors.feedbackError.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.feedbackError, width: 1.6),
        ),
      ),
    );
  }
}
