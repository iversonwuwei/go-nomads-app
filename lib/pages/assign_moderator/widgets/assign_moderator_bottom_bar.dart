import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:go_nomads_app/pages/assign_moderator/widgets/assign_moderator_permission_settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 指定版主页面的底部操作栏
class AssignModeratorBottomBar extends StatelessWidget {
  final AssignModeratorController controller;

  const AssignModeratorBottomBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 权限设置（可展开）
          AssignModeratorPermissionSettings(controller: controller),

          SizedBox(height: 16.h),

          // 确认按钮
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        final isDisabled = !controller.hasSelectedUsers || controller.isSubmitting.value;

        return ElevatedButton.icon(
          onPressed: isDisabled ? null : controller.submitAssignModerator,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cityPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: isDisabled ? 0 : 2,
          ),
          icon: controller.isSubmitting.value
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(FontAwesomeIcons.circleCheck),
          label: Text(
            controller.isSubmitting.value ? '指定中...' : '确认指定 ${controller.selectedCount} 个版主',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }
}
