import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';

/// 步骤3：设置新密码 / Step 3: Set new password
class ForgotPasswordResetStep extends GetView<ForgotPasswordController> {
  const ForgotPasswordResetStep({super.key});

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
              child:
                  Icon(Icons.vpn_key_outlined, size: 36, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '请设置您的新密码',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 新密码
          Text(
            '新密码',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => TextField(
                controller: controller.newPasswordController,
                obscureText: !controller.newPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: '至少6个字符',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      Icon(Icons.lock_outline, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.newPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => controller.newPasswordVisible.toggle(),
                  ),
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
              )),
          const SizedBox(height: 20),
          // 确认密码
          Text(
            '确认密码',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => TextField(
                controller: controller.confirmPasswordController,
                obscureText: !controller.confirmPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: '再次输入新密码',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      Icon(Icons.lock_outline, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.confirmPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () =>
                        controller.confirmPasswordVisible.toggle(),
                  ),
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
              )),
          const SizedBox(height: 32),
          // 提交按钮
          Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
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
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '确认重置',
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
