import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 指定版主页面的 AppBar
class AssignModeratorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AssignModeratorController controller;

  const AssignModeratorAppBar({
    super.key,
    required this.controller,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('${controller.cityName} - 指定版主'),
      backgroundColor: AppColors.cityPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        _buildSelectAllButton(),
      ],
    );
  }

  Widget _buildSelectAllButton() {
    return Obx(() {
      if (controller.filteredUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return TextButton.icon(
        onPressed: controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        icon: Icon(
          controller.isAllSelected ? FontAwesomeIcons.squareCheck : FontAwesomeIcons.square,
          size: 20,
        ),
        label: Text(
          controller.isAllSelected ? '取消全选' : '全选',
        ),
      );
    });
  }
}
