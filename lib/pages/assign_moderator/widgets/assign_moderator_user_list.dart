import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:go_nomads_app/pages/assign_moderator/widgets/assign_moderator_user_tile.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 指定版主页面的用户列表
class AssignModeratorUserList extends GetView<AssignModeratorController> {
  const AssignModeratorUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 加载中状态
      if (controller.isLoading.value) {
        return const ManageListSkeleton();
      }

      // 空状态
      if (controller.filteredUsers.isEmpty) {
        return _buildEmptyState();
      }

      // 用户列表
      return _buildUserList();
    });
  }

  Widget _buildEmptyState() {
    final hasSearchQuery = controller.hasSearchQuery;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? FontAwesomeIcons.magnifyingGlass : FontAwesomeIcons.users,
            size: 64.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            hasSearchQuery ? '未找到匹配的用户' : '暂无用户',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.sp,
            ),
          ),
          if (hasSearchQuery) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: controller.clearSearch,
              child: Text(AppLocalizations.of(Get.context!)!.dataServiceClearSearch),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: controller.filteredUsers.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 72.w,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final user = controller.filteredUsers[index];
        return AssignModeratorUserTile(
          user: user,
          controller: controller,
        );
      },
    );
  }
}
