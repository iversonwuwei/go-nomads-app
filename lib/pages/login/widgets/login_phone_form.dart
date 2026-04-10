import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_form_field.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';

/// 手机号登录表单 - 响应式验证
class LoginPhoneForm extends GetView<LoginController> {
  final LoginFormCopy? copy;

  const LoginPhoneForm({super.key, this.copy});

  String _copyOrFallback(String? remote, String fallback) {
    if (remote == null) return fallback;
    final trimmed = remote.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String? _getErrorText(String? errorKey, AppLocalizations l10n) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'phoneRequired':
        return _copyOrFallback(copy?.phoneRequiredError, l10n.loginPhoneRequired);
      case 'phoneInvalid':
        return _copyOrFallback(copy?.phoneInvalidError, l10n.loginPhoneInvalid);
      case 'smsCodeRequired':
        return _copyOrFallback(copy?.smsCodeRequiredError, l10n.enterVerificationCode);
      default:
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // 手机号输入
        Obx(() => LoginFormField(
              controller: controller.phoneController,
              labelText: copy?.phoneLabel ?? l10n.phoneNumber,
              hintText: copy?.phoneHint ?? l10n.enterPhoneNumber,
              prefixIcon: AppIcons.phone,
              keyboardType: TextInputType.phone,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.phoneError.value, l10n) : null,
            )),

        SizedBox(height: 20.h),

        // 验证码输入 + 发送按钮
        _SmsCodeRow(getErrorText: _getErrorText, copy: copy),

        SizedBox(height: 24.h),

        // 手机登录按钮
        _PhoneLoginButton(copy: copy),
      ],
    );
  }
}

/// 验证码输入行
class _SmsCodeRow extends GetView<LoginController> {
  final String? Function(String?, AppLocalizations) getErrorText;
  final LoginFormCopy? copy;
  static const double _codeFieldHeight = 56;

  const _SmsCodeRow({required this.getErrorText, this.copy});

  String _copyOrFallback(String? remote, String fallback) {
    if (remote == null) return fallback;
    final trimmed = remote.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _formatCountdown(int seconds) {
    final template = _copyOrFallback(copy?.smsCodeCountdownTemplate, '{seconds}s');
    return template.replaceAll('{seconds}', seconds.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(() => LoginFormField(
                controller: controller.smsCodeController,
                labelText: copy?.smsCodeLabel ?? l10n.verificationCode,
                hintText: copy?.smsCodeHint ?? l10n.enterVerificationCode,
                prefixIcon: AppIcons.verificationCode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                compactHeight: _codeFieldHeight.h,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                errorText:
                    controller.showValidationErrors.value ? getErrorText(controller.smsCodeError.value, l10n) : null,
              )),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          height: _codeFieldHeight.h,
          child: Obx(() => ElevatedButton(
                onPressed: controller.countdown.value > 0 ? null : controller.sendSmsCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LoginConstants.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  minimumSize: Size(88.w, _codeFieldHeight.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  controller.countdown.value > 0
                      ? _formatCountdown(controller.countdown.value)
                      : (copy?.smsCodeSendButton ?? l10n.sendCode),
                  style: TextStyle(fontSize: 14.sp),
                ),
              )),
        ),
      ],
    );
  }
}

/// 手机登录按钮
class _PhoneLoginButton extends GetView<LoginController> {
  final LoginFormCopy? copy;

  const _PhoneLoginButton({this.copy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppPrimaryButton(
      label: copy?.phoneSubmitButton ?? l10n.loginPhoneAction,
      onPressed: () => controller.loginWithPhone(context),
      fontSize: 18.sp,
    );
  }
}
