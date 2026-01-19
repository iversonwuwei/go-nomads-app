import 'package:flutter/material.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';

/// 登录页面通用输入框 - 使用响应式错误显示，无需 Form/GlobalKey
class LoginFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLength;

  const LoginFormField({
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
  });

  /// 检查 TextEditingController 是否仍然有效（未被 dispose）
  bool _isControllerValid(TextEditingController? ctrl) {
    if (ctrl == null) return false;
    try {
      // 尝试访问 text 属性，如果已被 dispose 会抛出异常
      ctrl.text;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果控制器无效，返回禁用状态的输入框
    if (!_isControllerValid(controller)) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LoginConstants.inputBorderRadius),
          ),
        ),
      );
    }

    final hasError = errorText != null && errorText!.isNotEmpty;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        errorText: errorText,
        counterText: maxLength != null ? '' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginConstants.inputBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade300 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: hasError ? Colors.red : LoginConstants.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginConstants.inputBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginConstants.inputBorderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
