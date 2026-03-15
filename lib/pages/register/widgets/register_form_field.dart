import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';

/// 注册页面通用输入框 - 使用响应式错误显示，无需 Form/GlobalKey
class RegisterFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText; // 直接传入错误文本
  final double? compactHeight;

  const RegisterFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.compactHeight,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final decorationConstraints =
        compactHeight != null ? BoxConstraints(minHeight: compactHeight!, maxHeight: compactHeight!) : null;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        prefixIconConstraints: compactHeight != null
            ? BoxConstraints(
                minWidth: 48.w,
                minHeight: compactHeight!,
              )
            : null,
        suffixIcon: suffixIcon,
        errorText: errorText,
        isDense: compactHeight != null,
        contentPadding: compactHeight != null ? EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h) : null,
        constraints: decorationConstraints,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterConstants.inputBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade300 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: hasError ? Colors.red : RegisterConstants.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterConstants.inputBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterConstants.inputBorderRadius),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
