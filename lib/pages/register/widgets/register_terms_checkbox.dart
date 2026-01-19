import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';

/// 服务条款复选框
class RegisterTermsCheckbox extends GetView<RegisterController> {
  const RegisterTermsCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Checkbox(
              value: controller.agreeToTerms.value,
              onChanged: (value) => controller.toggleAgreeToTerms(value),
              activeColor: RegisterConstants.primaryColor,
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () => controller.toggleAgreeToTerms(),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    TextSpan(text: '${l10n.agreeToTerms} '),
                    TextSpan(
                      text: l10n.termsOfService,
                      style: const TextStyle(
                        color: RegisterConstants.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' ${l10n.and} '),
                    TextSpan(
                      text: l10n.communityGuidelines,
                      style: const TextStyle(
                        color: RegisterConstants.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
