import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';

/// 注册提交按钮
class RegisterSubmitButton extends GetView<RegisterController> {
  final RegisterFormCopy? copy;

  const RegisterSubmitButton({super.key, this.copy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => AppPrimaryButton(
          label: copy?.submitButton ?? l10n.joinNomads,
          isLoading: controller.isRegistering.value,
          onPressed: () => controller.register(
            termsRequiredTitle: copy?.termsRequiredTitle ?? l10n.termsRequired,
            pleaseAgreeToTerms: copy?.termsRequiredMessage ?? l10n.pleaseAgreeToTerms,
            welcomeToCommunity: copy?.welcomeToastMessage ?? l10n.welcomeToCommunity,
            successTitle: copy?.successTitle ?? l10n.success,
          ),
          fontSize: 18.sp,
        ));
  }
}
