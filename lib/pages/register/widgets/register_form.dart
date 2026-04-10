import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';
import 'package:go_nomads_app/pages/register/widgets/register_form_field.dart';
import 'package:go_nomads_app/services/app_config_service.dart';

/// 注册表单 - 使用响应式验证，无需 Form/GlobalKey
class RegisterForm extends GetView<RegisterController> {
  final RegisterFormCopy? copy;

  const RegisterForm({super.key, this.copy});

  String _copyOrFallback(String? remote, String fallback) {
    if (remote == null) return fallback;
    final trimmed = remote.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _formatCountdown(int seconds) {
    final template = _copyOrFallback(copy?.verificationCodeCountdownTemplate, '{seconds}s');
    return template.replaceAll('{seconds}', seconds.toString());
  }

  /// 根据错误key获取本地化错误文本
  String? _getErrorText(String? errorKey, AppLocalizations l10n) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'usernameRequired':
        return _copyOrFallback(copy?.usernameRequiredError, l10n.usernameRequired);
      case 'usernameMinLength':
        return _copyOrFallback(copy?.usernameMinLengthError, l10n.usernameMinLength);
      case 'emailRequired':
        return _copyOrFallback(copy?.emailRequiredError, '请输入邮箱');
      case 'emailInvalid':
        return _copyOrFallback(copy?.emailInvalidError, l10n.invalidEmailFormat);
      case 'passwordRequired':
        return _copyOrFallback(copy?.passwordRequiredError, l10n.pleaseEnterPassword);
      case 'passwordMinLength':
        return _copyOrFallback(copy?.passwordMinLengthError, l10n.passwordMinLength);
      case 'confirmPasswordRequired':
        return _copyOrFallback(copy?.confirmPasswordRequiredError, l10n.confirmPasswordRequired);
      case 'passwordsNotMatch':
        return _copyOrFallback(copy?.passwordsNotMatchError, l10n.passwordsNotMatch);
      case 'verificationCodeRequired':
        return _copyOrFallback(copy?.verificationCodeRequiredError, l10n.verificationCodeRequired);
      case 'verificationCodeLength':
        return _copyOrFallback(copy?.verificationCodeLengthError, l10n.verificationCodeLength);
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
              labelText: copy?.usernameLabel ?? l10n.username,
              hintText: copy?.usernameHint ?? l10n.chooseUsername,
              prefixIcon: AppIcons.account,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.usernameError.value, l10n) : null,
            )),

        SizedBox(height: 20.h),

        // 邮箱输入
        Obx(() => RegisterFormField(
              controller: controller.emailController,
              labelText: copy?.emailLabel ?? l10n.email,
              hintText: copy?.emailHint ?? l10n.email,
              prefixIcon: AppIcons.email,
              keyboardType: TextInputType.emailAddress,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.emailError.value, l10n) : null,
            )),

        SizedBox(height: 20.h),

        // 邮箱验证码输入
        Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RegisterFormField(
                    controller: controller.verificationCodeController,
                    labelText: copy?.verificationCodeLabel ?? l10n.verificationCode,
                    hintText: copy?.verificationCodeHint ?? l10n.enterVerificationCode,
                    prefixIcon: AppIcons.verificationCode,
                    keyboardType: TextInputType.number,
                    compactHeight: _registerCodeRowHeight.h,
                    errorText: controller.showValidationErrors.value
                        ? _getErrorText(controller.verificationCodeError.value, l10n)
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: _registerCodeRowHeight.h,
                  child: FilledButton(
                    onPressed: controller.isSendingCode.value || controller.countdown.value > 0
                        ? null
                        : () => controller.sendVerificationCode(),
                    style: FilledButton.styleFrom(
                      backgroundColor: RegisterConstants.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: RegisterConstants.primaryColor.withValues(alpha: 0.5),
                      minimumSize: Size(88.w, _registerCodeRowHeight.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RegisterConstants.inputBorderRadius),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: controller.isSendingCode.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.countdown.value > 0
                                ? _formatCountdown(controller.countdown.value)
                                : (controller.codeSent.value
                                    ? (copy?.verificationCodeResendButton ?? l10n.resend)
                                    : (copy?.verificationCodeSendButton ?? l10n.sendCode)),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                  ),
                ),
              ],
            )),

        SizedBox(height: 20.h),

        // 密码输入
        _PasswordField(
          controller: controller.passwordController,
          labelText: copy?.passwordLabel ?? l10n.password,
          hintText: copy?.passwordHint ?? l10n.createPassword,
          obscureValue: controller.obscurePassword,
          onToggle: controller.toggleObscurePassword,
          errorText: controller.showValidationErrors.value ? _getErrorText(controller.passwordError.value, l10n) : null,
          showValidationErrors: controller.showValidationErrors,
          errorValue: controller.passwordError,
          getErrorText: (key) => _getErrorText(key, l10n),
        ),

        SizedBox(height: 20.h),

        // 确认密码输入
        _PasswordField(
          controller: controller.confirmPasswordController,
          labelText: copy?.confirmPasswordLabel ?? l10n.confirmPassword,
          hintText: copy?.confirmPasswordHint ?? l10n.reenterPassword,
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

const double _registerCodeRowHeight = 56;

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
          prefixIcon: AppIcons.password,
          obscureText: obscureValue.value,
          suffixIcon: IconButton(
            icon: Icon(
              obscureValue.value ? AppIcons.visibilityOn : AppIcons.visibilityOff,
              color: AppColors.icon,
            ),
            onPressed: onToggle,
          ),
          errorText: showValidationErrors.value ? getErrorText(errorValue.value) : null,
        ));
  }
}
