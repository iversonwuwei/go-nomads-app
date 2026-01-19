import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_form_field.dart';

/// 邮箱登录表单 - 响应式验证
class LoginEmailForm extends GetView<LoginController> {
  const LoginEmailForm({super.key});

  String? _getErrorText(String? errorKey, AppLocalizations l10n) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'emailRequired':
        return l10n.email;
      case 'emailInvalid':
        return l10n.email;
      case 'passwordRequired':
        return l10n.password;
      default:
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 邮箱输入
        Obx(() {
          // 访问响应式变量以确保 Obx 能正确追踪，同时检查控制器状态
          final disposed = controller.isDisposedRx.value;
          if (disposed) return const SizedBox.shrink();
          return LoginFormField(
            controller: controller.emailController,
            labelText: l10n.email,
            hintText: l10n.email,
            prefixIcon: FontAwesomeIcons.envelope,
            keyboardType: TextInputType.emailAddress,
            errorText:
                controller.showValidationErrors.value ? _getErrorText(controller.emailError.value, l10n) : null,
          );
        }),

        const SizedBox(height: 20),

        // 密码输入
        Obx(() {
          // 访问响应式变量以确保 Obx 能正确追踪，同时检查控制器状态
          final disposed = controller.isDisposedRx.value;
          if (disposed) return const SizedBox.shrink();
          return LoginFormField(
            controller: controller.passwordController,
            labelText: l10n.password,
            hintText: l10n.password,
            prefixIcon: FontAwesomeIcons.lock,
            obscureText: controller.obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            errorText:
                controller.showValidationErrors.value ? _getErrorText(controller.passwordError.value, l10n) : null,
          );
        }),

        const SizedBox(height: 16),

        // 记住我 & 忘记密码
        _RememberMeRow(l10n: l10n),

        const SizedBox(height: 24),

        // 登录按钮
        _LoginButton(l10n: l10n),
      ],
    );
  }
}

/// 记住我和忘记密码行
class _RememberMeRow extends GetView<LoginController> {
  final AppLocalizations l10n;

  const _RememberMeRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Obx(() => Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: (value) => controller.setRememberMe(value ?? false),
                  activeColor: LoginConstants.primaryColor,
                )),
            Text(
              l10n.rememberMe,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: 实现忘记密码功能
          },
          child: Text(
            l10n.forgotPassword,
            style: const TextStyle(
              fontSize: 14,
              color: LoginConstants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 登录按钮
class _LoginButton extends GetView<LoginController> {
  final AppLocalizations l10n;

  const _LoginButton({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.loginWithEmail(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: LoginConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          l10n.login,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
