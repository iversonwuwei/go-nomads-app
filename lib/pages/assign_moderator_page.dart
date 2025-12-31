import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/assign_moderator_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 指定城市版主页面
class AssignModeratorPage extends StatelessWidget {
  final String cityId;
  final String cityName;
  final String _tag;

  AssignModeratorPage({
    super.key,
    required this.cityId,
    required this.cityName,
  }) : _tag = 'AssignModeratorPage-$cityId';

  AssignModeratorPageController get _controller {
    if (!Get.isRegistered<AssignModeratorPageController>(tag: _tag)) {
      Get.put(
        AssignModeratorPageController(cityId: cityId, cityName: cityName),
        tag: _tag,
      );
    }
    return Get.find<AssignModeratorPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: Text('$cityName - 指定版主'),
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => controller.filteredUsers.isNotEmpty
              ? TextButton.icon(
                  onPressed: controller.toggleSelectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    controller.selectedUserIds.length == controller.filteredUsers.length
                        ? FontAwesomeIcons.squareCheck
                        : FontAwesomeIcons.square,
                    size: 20,
                  ),
                  label: Text(
                    controller.selectedUserIds.length == controller.filteredUsers.length ? '取消全选' : '全选',
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          const Divider(height: 1),
          Expanded(child: _buildUserList(controller)),
          _buildBottomBar(controller),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AssignModeratorPageController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: '搜索用户名称或邮箱',
              prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
              suffixIcon: controller.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(FontAwesomeIcons.xmark),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.filterUsers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                '已选择 ${controller.selectedUserIds.length} 个用户',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildUserList(AssignModeratorPageController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.users,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchController.text.isEmpty ? '暂无用户' : '未找到匹配的用户',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.filteredUsers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 72,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final user = controller.filteredUsers[index];
          final userId = user['id'];
          final displayBadge = user['displayBadge'] as String? ?? '';
          final isAdmin = user['isAdmin'] as bool? ?? false;

          return Obx(() {
            final isSelected = controller.selectedUserIds.contains(userId);
            final badgeColor = controller.getBadgeColor(displayBadge, isAdmin);

            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelected ? AppColors.accent : Colors.grey[300],
                    child: Text(
                      user['name'].toString().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      displayBadge,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(user['email']),
              trailing: Checkbox(
                value: isSelected,
                activeColor: AppColors.accent,
                onChanged: (_) => controller.toggleUserSelection(userId),
              ),
              onTap: () => controller.toggleUserSelection(userId),
              selected: isSelected,
              selectedTileColor: AppColors.accent.withValues(alpha: 0.05),
            );
          });
        },
      );
    });
  }

  Widget _buildBottomBar(AssignModeratorPageController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpansionTile(
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
            children: [
              _buildPermissionSwitch('管理城市信息', controller.canEditCity),
              _buildPermissionSwitch('管理共享办公空间', controller.canManageCoworks),
              _buildPermissionSwitch('管理生活成本', controller.canManageCosts),
              _buildPermissionSwitch('管理签证信息', controller.canManageVisas),
              _buildPermissionSwitch('管理聊天室', controller.canModerateChats),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.selectedUserIds.isEmpty || controller.isSubmitting.value
                      ? null
                      : controller.submitAssignModerator,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: controller.selectedUserIds.isEmpty ? 0 : 2,
                  ),
                  icon: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(FontAwesomeIcons.circleCheck),
                  label: Text(
                    controller.isSubmitting.value
                        ? '指定中...'
                        : '确认指定 ${controller.selectedUserIds.length} 个版主',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        ],
      ),
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
        ));
  }
}
