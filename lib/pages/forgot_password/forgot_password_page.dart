import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';
import 'package:go_nomads_app/pages/forgot_password/widgets/forgot_password_account_step.dart';
import 'package:go_nomads_app/pages/forgot_password/widgets/forgot_password_code_step.dart';
import 'package:go_nomads_app/pages/forgot_password/widgets/forgot_password_reset_step.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

/// 忘记密码页面 / Forgot password page
class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: AppBackButton(onPressed: controller.goBack),
        title: Obx(() => Text(
              controller.getStepTitle(controller.currentStep.value),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            )),
        centerTitle: true,
      ),
      body: Obx(() => _buildStepContent(controller.currentStep.value)),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const ForgotPasswordAccountStep();
      case 1:
        return const ForgotPasswordCodeStep();
      case 2:
        return const ForgotPasswordResetStep();
      default:
        return const ForgotPasswordAccountStep();
    }
  }
}
