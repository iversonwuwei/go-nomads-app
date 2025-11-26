import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:df_admin_mobile/features/moderator/domain/entities/moderator_application.dart';
import 'package:df_admin_mobile/features/moderator/presentation/controllers/moderator_application_controller.dart';

/// 管理员审核版主申请页面
class ModeratorApplicationListPage extends StatelessWidget {
  const ModeratorApplicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ModeratorApplicationController>();

    // 初始加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPendingApplications();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('版主申请审核'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadPendingApplications(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pendingApplications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pendingApplications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '暂无待处理申请',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadPendingApplications(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pendingApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final application = controller.pendingApplications[index];
              return _ApplicationCard(
                application: application,
                onApprove: () => _handleApprove(context, controller, application),
                onReject: () => _handleReject(context, controller, application),
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    ModeratorApplicationController controller,
    ModeratorApplication application,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认通过'),
        content: Text('确定要通过 ${application.userName} 的版主申请吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.handleApplication(
          applicationId: application.id,
          action: 'approve',
        );
        Get.snackbar('成功', '已通过申请', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('失败', '操作失败: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    ModeratorApplicationController controller,
    ModeratorApplication application,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('拒绝申请'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('确定要拒绝 ${application.userName} 的版主申请吗？'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '拒绝原因（可选）',
                hintText: '请输入拒绝原因...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('确认拒绝'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.handleApplication(
          applicationId: application.id,
          action: 'reject',
          rejectionReason: reasonController.text.isNotEmpty ? reasonController.text : null,
        );
        Get.snackbar('成功', '已拒绝申请', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('失败', '操作失败: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }

    reasonController.dispose();
  }
}

class _ApplicationCard extends StatelessWidget {
  final ModeratorApplication application;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: application.userAvatar != null
                      ? NetworkImage(application.userAvatar!)
                      : null,
                  child: application.userAvatar == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.userName ?? '未知用户',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '申请时间: ${_formatDateTime(application.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // 申请城市
            Row(
              children: [
                const Icon(Icons.location_city, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  application.cityName ?? application.cityNameEn ?? '未知城市',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 申请理由
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '申请理由',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    application.reason,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('拒绝'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('通过'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
