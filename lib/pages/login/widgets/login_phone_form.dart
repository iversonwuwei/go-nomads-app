import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 手机号登录表单 - 响应式验证
class LoginPhoneForm extends GetView<LoginController> {
  const LoginPhoneForm({super.key});

  String? _getErrorText(String? errorKey, AppLocalizations l10n) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'phoneRequired':
        return l10n.loginPhoneRequired;
      case 'phoneInvalid':
        return l10n.loginPhoneInvalid;
      case 'smsCodeRequired':
        return l10n.enterVerificationCode;
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
              labelText: l10n.phoneNumber,
              hintText: l10n.enterPhoneNumber,
              prefixIcon: FontAwesomeIcons.phone,
              keyboardType: TextInputType.phone,
              errorText:
                  controller.showValidationErrors.value ? _getErrorText(controller.phoneError.value, l10n) : null,
            )),

        SizedBox(height: 20.h),

        // 验证码输入 + 发送按钮
        _SmsCodeRow(getErrorText: _getErrorText),

        SizedBox(height: 24.h),

        // 手机登录按钮
        _PhoneLoginButton(),
      ],
    );
  }
}

/// 验证码输入行
class _SmsCodeRow extends GetView<LoginController> {
  final String? Function(String?, AppLocalizations) getErrorText;

  const _SmsCodeRow({required this.getErrorText});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(() => LoginFormField(
                controller: controller.smsCodeController,
                labelText: l10n.verificationCode,
                hintText: l10n.enterVerificationCode,
                prefixIcon: FontAwesomeIcons.message,
                keyboardType: TextInputType.number,
                maxLength: 6,
                errorText:
                    controller.showValidationErrors.value ? getErrorText(controller.smsCodeError.value, l10n) : null,
              )),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          height: 56.h,
          child: Obx(() => ElevatedButton(
                onPressed: controller.countdown.value > 0 ? null : controller.sendSmsCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LoginConstants.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  controller.countdown.value > 0 ? '${controller.countdown.value}s' : l10n.sendCode,
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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.loginWithPhone(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: LoginConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          l10n.loginPhoneAction,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
