import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/auth/auth_step_shell.dart';
import 'package:go_nomads_app/widgets/buttons/app_primary_button.dart';
import 'package:go_nomads_app/widgets/forms/app_input_field.dart';

/// 步骤3：设置新密码 / Step 3: Set new password
class ForgotPasswordResetStep extends GetView<ForgotPasswordController> {
  const ForgotPasswordResetStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: AuthStepShell(
        icon: AppIcons.password,
        description: controller.resetStepDescription,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => AppInputField(
                  controller: controller.newPasswordController,
                  labelText: controller.resetNewPasswordLabel,
                  hintText: l10n.createPassword,
                  prefixIcon: AppIcons.password,
                  obscureText: !controller.newPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.newPasswordVisible.value ? AppIcons.visibilityOn : AppIcons.visibilityOff,
                      color: AppColors.icon,
                    ),
                    onPressed: () => controller.newPasswordVisible.toggle(),
                  ),
                )),
            SizedBox(height: 20.h),
            Obx(() => AppInputField(
                  controller: controller.confirmPasswordController,
                  labelText: controller.resetConfirmPasswordLabel,
                  hintText: l10n.reenterPassword,
                  prefixIcon: AppIcons.password,
                  obscureText: !controller.confirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.confirmPasswordVisible.value ? AppIcons.visibilityOn : AppIcons.visibilityOff,
                      color: AppColors.icon,
                    ),
                    onPressed: () => controller.confirmPasswordVisible.toggle(),
                  ),
                )),
            SizedBox(height: 32.h),
            Obx(() => AppPrimaryButton(
                  label: controller.resetSubmitButton,
                  onPressed: controller.resetPassword,
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }
}
