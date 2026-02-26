import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 密码输入框组件 / Password input field widget
class ChangePasswordField extends StatelessWidget {
  final TextEditingController textController;
  final String label;
  final String hint;
  final RxBool isVisible;
  final VoidCallback onToggleVisible;

  const ChangePasswordField({
    super.key,
    required this.textController,
    required this.label,
    required this.hint,
    required this.isVisible,
    required this.onToggleVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => TextField(
              controller: textController,
              obscureText: !isVisible.value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isVisible.value
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 16.r,
                    color: AppColors.iconLight,
                  ),
                  onPressed: onToggleVisible,
                ),
              ),
            )),
      ],
    );
  }
}
