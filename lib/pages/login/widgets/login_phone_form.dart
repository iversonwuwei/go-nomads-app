import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_form_field.dart';

/// 手机号登录表单 - 响应式验证
class LoginPhoneForm extends GetView<LoginController> {
  const LoginPhoneForm({super.key});

  String? _getErrorText(String? errorKey) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'phoneRequired':
        return '请输入手机号';
      case 'phoneInvalid':
        return '请输入正确的手机号';
      case 'smsCodeRequired':
        return '请输入验证码';
      default:
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 手机号输入
        Obx(() => LoginFormField(
              controller: controller.phoneController,
              labelText: '手机号',
              hintText: '请输入手机号',
              prefixIcon: FontAwesomeIcons.phone,
              keyboardType: TextInputType.phone,
              errorText: controller.showValidationErrors.value ? _getErrorText(controller.phoneError.value) : null,
            )),

        const SizedBox(height: 20),

        // 验证码输入 + 发送按钮
        _SmsCodeRow(getErrorText: _getErrorText),

        const SizedBox(height: 24),

        // 手机登录按钮
        _PhoneLoginButton(),
      ],
    );
  }
}

/// 验证码输入行
class _SmsCodeRow extends GetView<LoginController> {
  final String? Function(String?) getErrorText;

  const _SmsCodeRow({required this.getErrorText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(() => LoginFormField(
                controller: controller.smsCodeController,
                labelText: '验证码',
                hintText: '请输入验证码',
                prefixIcon: FontAwesomeIcons.message,
                keyboardType: TextInputType.number,
                maxLength: 6,
                errorText: controller.showValidationErrors.value ? getErrorText(controller.smsCodeError.value) : null,
              )),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
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
                  controller.countdown.value > 0 ? '${controller.countdown.value}s' : '发送验证码',
                  style: const TextStyle(fontSize: 14),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.loginWithPhone(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: LoginConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
          ),
          elevation: 0,
        ),
        child: const Text(
          '登录',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
