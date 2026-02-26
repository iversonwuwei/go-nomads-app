import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/change_password_page_controller.dart';
import 'package:go_nomads_app/pages/change_password/widgets/change_password_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 密码表单区域 / Password form section
class ChangePasswordForm extends GetView<ChangePasswordController> {
  const ChangePasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.hasPassword.value ? '修改密码' : '设置密码',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                controller.hasPassword.value
                    ? '请输入原密码和新密码'
                    : '您尚未设置密码，请设置登录密码',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // 原密码（仅已设置密码的用户显示）
              if (controller.hasPassword.value) ...[
                ChangePasswordField(
                  textController: controller.oldPasswordController,
                  label: '原密码',
                  hint: '请输入原密码',
                  isVisible: controller.oldPasswordVisible,
                  onToggleVisible: controller.toggleOldPasswordVisible,
                ),
                SizedBox(height: 16.h),
              ],

              // 新密码
              ChangePasswordField(
                textController: controller.newPasswordController,
                label: '新密码',
                hint: '请输入新密码（至少6个字符）',
                isVisible: controller.newPasswordVisible,
                onToggleVisible: controller.toggleNewPasswordVisible,
              ),
              SizedBox(height: 16.h),

              // 确认新密码
              ChangePasswordField(
                textController: controller.confirmPasswordController,
                label: '确认新密码',
                hint: '请再次输入新密码',
                isVisible: controller.confirmPasswordVisible,
                onToggleVisible: controller.toggleConfirmPasswordVisible,
              ),
            ],
          )),
    );
  }
}
