import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 版主权限设置组件
class AssignModeratorPermissionSettings extends StatelessWidget {
  final AssignModeratorController controller;

  const AssignModeratorPermissionSettings({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        '版主权限设置（可选）',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '展开设置批量权限',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      children: [
        _buildPermissionSwitch('管理城市信息', controller.canEditCity),
        _buildPermissionSwitch('管理共享办公空间', controller.canManageCoworks),
        _buildPermissionSwitch('管理生活成本', controller.canManageCosts),
        _buildPermissionSwitch('管理签证信息', controller.canManageVisas),
        _buildPermissionSwitch('管理聊天室', controller.canModerateChats),
      ],
    );
  }

  Widget _buildPermissionSwitch(String title, RxBool value) {
    return Obx(() => CheckboxListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          value: value.value,
          activeColor: AppColors.accent,
          dense: true,
          onChanged: (newValue) => value.value = newValue ?? false,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ));
  }
}
