import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_toast.dart';

/// 管理员删除按钮组件
///
/// 只对管理员显示，点击后弹出确认对话框
class AdminDeleteButton extends StatelessWidget {
  /// 是否是管理员
  final bool isAdmin;

  /// 删除操作 - 返回 true 表示删除成功
  final Future<bool> Function() onDelete;

  /// 删除成功后的回调（可选）
  /// 如果提供，则在删除成功后调用此回调而不是默认的 Get.back()
  final VoidCallback? onDeleteSuccess;

  /// 实体名称（用于确认对话框）
  final String entityName;

  /// 按钮透明度（用于 SliverAppBar）
  final double opacity;

  /// 图标大小
  final double iconSize;

  const AdminDeleteButton({
    super.key,
    required this.isAdmin,
    required this.onDelete,
    required this.entityName,
    this.onDeleteSuccess,
    this.opacity = 0.0,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: opacity > 0.5 ? Colors.transparent : Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.delete_outline,
          color: opacity > 0.5 ? Colors.red : Colors.white,
          size: iconSize,
        ),
        tooltip: '删除$entityName',
        onPressed: () => _handleDelete(),
      ),
    );
  }

  Future<void> _handleDelete() async {
    // 显示确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这个$entityName吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 显示加载指示器
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await onDelete();

      // 关闭加载指示器
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (success) {
        AppToast.success('$entityName已删除');
        // 如果提供了自定义回调则使用，否则使用默认的返回逻辑
        if (onDeleteSuccess != null) {
          onDeleteSuccess!();
        } else {
          Get.back(result: 'deleted');
        }
      }
    } catch (e) {
      // 关闭加载指示器
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      AppToast.error('删除失败: $e');
    }
  }
}
