import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/auth/auth_step_shell.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';
import 'package:go_nomads_app/widgets/forms/app_input_field.dart';

/// 步骤1：输入邮箱或手机号 / Step 1: Enter email or phone
class ForgotPasswordAccountStep extends GetView<ForgotPasswordController> {
  const ForgotPasswordAccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: AuthStepShell(
        icon: AppIcons.passwordReset,
        description: controller.accountStepDescription,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppInputField(
              controller: controller.accountController,
              labelText: controller.accountInputLabel,
              hintText: l10n.email,
              prefixIcon: AppIcons.account,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24.h),
            Obx(() => AppPrimaryButton(
                  label: controller.accountSendCodeButton,
                  onPressed: controller.sendCode,
                  isLoading: controller.isSendingCode.value,
                )),
          ],
        ),
      ),
    );
  }
}
