import 'package:flutter/material.dart';
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
              _stepTitle(controller.currentStep.value),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )),
        centerTitle: true,
      ),
      body: Obx(() => _buildStepContent(controller.currentStep.value)),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return '找回密码';
      case 1:
        return '验证身份';
      case 2:
        return '设置新密码';
      default:
        return '找回密码';
    }
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
