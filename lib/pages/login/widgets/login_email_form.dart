import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_form_field.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';

/// 邮箱登录表单 - 响应式验证
class LoginEmailForm extends GetView<LoginController> {
  final LoginFormCopy? copy;

  const LoginEmailForm({super.key, this.copy});

  String _copyOrFallback(String? remote, String fallback) {
    if (remote == null) return fallback;
    final trimmed = remote.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String? _getErrorText(String? errorKey, AppLocalizations l10n) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'emailRequired':
        return _copyOrFallback(copy?.emailRequiredError, '请输入邮箱');
      case 'emailInvalid':
        return _copyOrFallback(copy?.emailInvalidError, l10n.invalidEmailFormat);
      case 'passwordRequired':
        return _copyOrFallback(copy?.passwordRequiredError, l10n.pleaseEnterPassword);
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
        Obx(() => LoginFormField(
              controller: controller.emailController,
              labelText: copy?.emailLabel ?? l10n.email,
              hintText: copy?.emailHint ?? l10n.email,
              prefixIcon: AppIcons.email,
              keyboardType: TextInputType.emailAddress,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.emailError.value, l10n) : null,
            )),

        SizedBox(height: 20.h),

        // 密码输入
        Obx(() => LoginFormField(
              controller: controller.passwordController,
              labelText: copy?.passwordLabel ?? l10n.password,
              hintText: copy?.passwordHint ?? l10n.password,
              prefixIcon: AppIcons.password,
              obscureText: controller.obscurePassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value ? AppIcons.visibilityOn : AppIcons.visibilityOff,
                  color: AppColors.icon,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.passwordError.value, l10n) : null,
            )),

        SizedBox(height: 16.h),

        // 记住我 & 忘记密码
        _RememberMeRow(
          rememberMeLabel: copy?.rememberMe ?? l10n.rememberMe,
          forgotPasswordLabel: copy?.forgotPassword ?? l10n.forgotPassword,
        ),

        SizedBox(height: 24.h),

        // 登录按钮
        _LoginButton(label: copy?.emailSubmitButton ?? l10n.clickToLoginOrRegister),
      ],
    );
  }
}

/// 记住我和忘记密码行
class _RememberMeRow extends GetView<LoginController> {
  final String rememberMeLabel;
  final String forgotPasswordLabel;

  const _RememberMeRow({
    required this.rememberMeLabel,
    required this.forgotPasswordLabel,
  });

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
              rememberMeLabel,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Get.toNamed(AppRoutes.forgotPassword);
          },
          child: Text(
            forgotPasswordLabel,
            style: TextStyle(
              fontSize: 14.sp,
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
  final String label;

  const _LoginButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: label,
      onPressed: () => controller.loginWithEmail(context),
      fontSize: 18.sp,
    );
  }
}
