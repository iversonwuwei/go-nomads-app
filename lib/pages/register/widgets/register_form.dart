import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';
import 'package:go_nomads_app/pages/register/widgets/register_form_field.dart';

/// 注册表单 - 使用响应式验证，无需 Form/GlobalKey
class RegisterForm extends GetView<RegisterController> {
  const RegisterForm({super.key});

  /// 根据错误key获取本地化错误文本
  String? _getErrorText(String? errorKey, AppLocalizations l10n) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'usernameRequired':
        return l10n.usernameRequired;
      case 'usernameMinLength':
        return l10n.usernameMinLength;
      case 'emailRequired':
        return l10n.email;
      case 'emailInvalid':
        return l10n.email;
      case 'passwordRequired':
        return l10n.password;
      case 'passwordMinLength':
        return l10n.password;
      case 'confirmPasswordRequired':
        return l10n.confirmPasswordRequired;
      case 'passwordsNotMatch':
        return l10n.passwordsNotMatch;
      default:
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 用户名输入
        Obx(() => RegisterFormField(
              controller: controller.usernameController,
              labelText: l10n.username,
              hintText: l10n.chooseUsername,
              prefixIcon: FontAwesomeIcons.user,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.usernameError.value, l10n) : null,
            )),

        const SizedBox(height: 20),

        // 邮箱输入
        Obx(() => RegisterFormField(
              controller: controller.emailController,
              labelText: l10n.email,
              hintText: l10n.email,
              prefixIcon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.emailError.value, l10n) : null,
            )),

        const SizedBox(height: 20),

        // 密码输入
        _PasswordField(
          controller: controller.passwordController,
          labelText: l10n.password,
          hintText: l10n.createPassword,
          obscureValue: controller.obscurePassword,
          onToggle: controller.toggleObscurePassword,
          errorText: controller.showValidationErrors.value ? _getErrorText(controller.passwordError.value, l10n) : null,
          showValidationErrors: controller.showValidationErrors,
          errorValue: controller.passwordError,
          getErrorText: (key) => _getErrorText(key, l10n),
        ),

        const SizedBox(height: 20),

        // 确认密码输入
        _PasswordField(
          controller: controller.confirmPasswordController,
          labelText: l10n.confirmPassword,
          hintText: l10n.reenterPassword,
          obscureValue: controller.obscureConfirmPassword,
          onToggle: controller.toggleObscureConfirmPassword,
          errorText:
              controller.showValidationErrors.value ? _getErrorText(controller.confirmPasswordError.value, l10n) : null,
          showValidationErrors: controller.showValidationErrors,
          errorValue: controller.confirmPasswordError,
          getErrorText: (key) => _getErrorText(key, l10n),
        ),
      ],
    );
  }
}

/// 密码输入框 - 使用响应式验证
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final RxBool obscureValue;
  final VoidCallback onToggle;
  final String? errorText;
  final RxBool showValidationErrors;
  final RxnString errorValue;
  final String? Function(String?) getErrorText;

  const _PasswordField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.obscureValue,
    required this.onToggle,
    this.errorText,
    required this.showValidationErrors,
    required this.errorValue,
    required this.getErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => RegisterFormField(
          controller: controller,
          labelText: labelText,
          hintText: hintText,
          prefixIcon: FontAwesomeIcons.lock,
          obscureText: obscureValue.value,
          suffixIcon: IconButton(
            icon: Icon(
              obscureValue.value ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            ),
            onPressed: onToggle,
          ),
          errorText: showValidationErrors.value ? getErrorText(errorValue.value) : null,
        ));
  }
}
