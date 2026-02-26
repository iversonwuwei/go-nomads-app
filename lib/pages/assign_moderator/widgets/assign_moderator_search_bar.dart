import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 指定版主页面的搜索栏
class AssignModeratorSearchBar extends StatelessWidget {
  final AssignModeratorController controller;

  const AssignModeratorSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          SizedBox(height: 12.h),
          _buildSelectedCount(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: '搜索用户名称或邮箱',
        prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 18.r),
        suffixIcon: Obx(() {
          if (!controller.hasSearchQuery) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: Icon(FontAwesomeIcons.xmark, size: 16.r),
            onPressed: controller.clearSearch,
          );
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildSelectedCount() {
    return Obx(() => Text(
          '已选择 ${controller.selectedCount} 个用户',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ));
  }
}
