import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/change_password_page_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 邮箱信息区域 / Email info section
class ChangePasswordEmailSection extends GetView<ChangePasswordController> {
  const ChangePasswordEmailSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.envelope,
            color: AppColors.icon,
            size: 18.r,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '账号邮箱',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Obx(() => Text(
                    controller.userEmail.value.isNotEmpty
                        ? controller.userEmail.value
                        : '未绑定邮箱',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
