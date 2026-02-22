import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';

/// 步骤2：输入验证码 / Step 2: Enter verification code
class ForgotPasswordCodeStep extends GetView<ForgotPasswordController> {
  const ForgotPasswordCodeStep({super.key});

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
              child: Icon(Icons.email_outlined, size: 36, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          // 提示信息
          Obx(() => Center(
                child: Text(
                  '验证码已发送至\n${controller.maskedTarget.value}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              )),
          const SizedBox(height: 32),
          // 验证码输入
          Text(
            '验证码',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: '请输入6位验证码',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              prefixIcon: Icon(Icons.pin_outlined, color: AppColors.textTertiary),
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
          const SizedBox(height: 16),
          // 重新发送
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              if (controller.countdown.value > 0) {
                return Text(
                  '${controller.countdown.value}s 后重新发送',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                );
              }
              return TextButton(
                onPressed: controller.resendCode,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  '重新发送验证码',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // 下一步按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.goToResetStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '下一步',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
