import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/app_colors.dart';
import '../../../features/notification/domain/entities/app_notification.dart';
import '../../../features/notification/presentation/controllers/notification_state_controller.dart';
import '../../../widgets/app_toast.dart';

/// 通知列表页面
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 设置中文 timeago
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationStateController>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('通知'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '未读'),
            Tab(text: '已读'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                controller.loadNotifications();
                break;
              case 1:
                controller.loadNotifications(isRead: false);
                break;
              case 2:
                controller.loadNotifications(isRead: true);
                break;
            }
          },
        ),
        actions: [
          // 全部标记为已读
          Obx(() {
            final hasUnread = controller.unreadCount.value > 0;
            return hasUnread
                ? IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: '全部标记为已读',
                    onPressed: () async {
                      final success = await controller.markAllAsRead();
                      if (success) {
                        AppToast.success('已全部标记为已读');
                      }
                    },
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(controller, isMobile, null),
          _buildNotificationList(controller, isMobile, false),
          _buildNotificationList(controller, isMobile, true),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    NotificationStateController controller,
    bool isMobile,
    bool? isRead,
  ) {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.iconSecondary),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadNotifications(isRead: isRead),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }

      final notifications = controller.notifications
          .where((n) => isRead == null || n.isRead == isRead)
          .toList();

      if (notifications.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 64, color: AppColors.iconSecondary),
              const SizedBox(height: 16),
              Text(
                isRead == null
                    ? '暂无通知'
                    : isRead
                        ? '暂无已读通知'
                        : '暂无未读通知',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.separated(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, controller, isMobile);
          },
        ),
      );
    });
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    NotificationStateController controller,
    bool isMobile,
  ) {
    final color = Color(
      int.parse(notification.type.colorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        controller.deleteNotification(notification.id);
        AppToast.info('通知已删除');
      },
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await controller.markAsRead(notification.id);
          }
          
          // 导航到相关页面
          _handleNotificationTap(notification);
        },
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.accent.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notification.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        
                        // 未读指示器
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 消息内容
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 时间
                    Text(
                      timeago.format(notification.createdAt, locale: 'zh_CN'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.moderatorApplication:
        // 管理员：跳转到审核页面（待实现）
        // Get.toNamed('/admin/moderator-applications');
        AppToast.info('审核功能开发中');
        break;
        
      case NotificationType.moderatorApproved:
      case NotificationType.moderatorRejected:
        // 跳转到相关城市页面
        if (notification.relatedId != null) {
          Get.toNamed('/city/${notification.relatedId}');
        }
        break;
        
      case NotificationType.cityUpdate:
        if (notification.relatedId != null) {
          Get.toNamed('/city/${notification.relatedId}');
        }
        break;
        
      case NotificationType.systemAnnouncement:
        // 显示详情对话框
        _showAnnouncementDialog(notification);
        break;
        
      case NotificationType.other:
        break;
    }
  }

  void _showAnnouncementDialog(AppNotification notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
