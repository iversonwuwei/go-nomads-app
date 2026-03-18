import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 注册提交按钮
class RegisterSubmitButton extends GetView<RegisterController> {
  const RegisterSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => ElevatedButton(
          onPressed: controller.isRegistering.value
              ? null
              : () => controller.register(
                    termsRequiredTitle: l10n.termsRequired,
                    pleaseAgreeToTerms: l10n.pleaseAgreeToTerms,
                    welcomeToCommunity: l10n.welcomeToCommunity,
                    successTitle: l10n.success,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: RegisterConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RegisterConstants.buttonBorderRadius),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: controller.isRegistering.value
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  l10n.joinNomads,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
        ));
  }
}
