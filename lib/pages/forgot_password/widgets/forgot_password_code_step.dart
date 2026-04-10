import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/auth/auth_step_shell.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';
import 'package:go_nomads_app/widgets/forms/app_input_field.dart';

/// 步骤2：输入验证码 / Step 2: Enter verification code
class ForgotPasswordCodeStep extends GetView<ForgotPasswordController> {
  const ForgotPasswordCodeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: AuthStepShell(
        icon: AppIcons.email,
        description: controller.getVerifyDescription(controller.maskedTarget.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppInputField(
              controller: controller.codeController,
              labelText: controller.verifyCodeLabel,
              hintText: l10n.enterVerificationCode,
              prefixIcon: AppIcons.verificationCode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              maxLength: 6,
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() {
                if (controller.countdown.value > 0) {
                  return Text(
                    controller.getResendCountdownLabel(controller.countdown.value),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textTertiary,
                    ),
                  );
                }
                return TextButton(
                  onPressed: controller.resendCode,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    controller.verifyResendButton,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.cityPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),
            AppPrimaryButton(
              label: controller.verifyNextButton,
              onPressed: controller.goToResetStep,
            ),
          ],
        ),
      ),
    );
  }
}
