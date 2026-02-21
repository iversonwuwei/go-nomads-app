import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 登录页用户协议勾选框（工信部/腾讯合规要求）
/// Login page terms checkbox (required for Tencent app store compliance)
class LoginTermsCheckbox extends GetView<LoginController> {
  const LoginTermsCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Checkbox(
              value: controller.agreeToTerms.value,
              onChanged: (value) => controller.toggleAgreeToTerms(value),
              activeColor: LoginConstants.primaryColor,
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '${l10n.agreeToTerms} ',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => controller.toggleAgreeToTerms(),
                  ),
                  TextSpan(
                    text: l10n.termsAndConditions,
                    style: const TextStyle(
                      color: LoginConstants.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.toNamed(AppRoutes.termsOfService),
                  ),
                  TextSpan(text: ' ${l10n.and} '),
                  TextSpan(
                    text: l10n.privacyPolicy,
                    style: const TextStyle(
                      color: LoginConstants.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.toNamed(AppRoutes.privacyPolicy),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
