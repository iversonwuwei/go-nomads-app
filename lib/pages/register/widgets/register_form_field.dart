import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/forms/app_input_field.dart';

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
    return AppInputField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      errorText: errorText,
      compactHeight: compactHeight,
    );
  }
}
