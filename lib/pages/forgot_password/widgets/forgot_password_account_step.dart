import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';

/// 步骤1：输入邮箱或手机号 / Step 1: Enter email or phone
class ForgotPasswordAccountStep extends GetView<ForgotPasswordController> {
  const ForgotPasswordAccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 图标
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset, size: 36, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          // 说明文字
          Center(
            child: Text(
              '请输入您的邮箱或手机号\n我们将发送验证码帮助您重置密码',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 输入框
          Text(
            '邮箱或手机号',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.accountController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: '请输入邮箱地址或手机号码',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              prefixIcon:
                  Icon(Icons.person_outline, color: AppColors.textTertiary),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 发送验证码按钮
          Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isSendingCode.value
                      ? null
                      : controller.sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.accent.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSendingCode.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '发送验证码',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              )),
        ],
      ),
    );
  }
}
