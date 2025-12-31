import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/notifications_page_controller.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 通知列表页面
/// 注意: 由于 TabController 需要 TickerProvider，保持 StatefulWidget 结构
/// 但业务逻辑已移至 NotificationsPageController
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  static const String _tag = 'NotificationsPage';
  late TabController _tabController;
  late NotificationsPageController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = _useController();
  }

  NotificationsPageController _useController() {
    if (Get.isRegistered<NotificationsPageController>(tag: _tag)) {
      return Get.find<NotificationsPageController>(tag: _tag);
    }
    return Get.put(NotificationsPageController(), tag: _tag);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('📱 NotificationsPage.build() 开始');

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // TabBar 区域
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // TabBar 和操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.accent,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.accent,
                          tabs: const [
                            Tab(text: '全部'),
                            Tab(text: '未读'),
                            Tab(text: '已读'),
                          ],
                          onTap: (index) => _controller.loadNotificationsByTab(index),
                        ),
                      ),
                      // 全部标记为已读按钮
                      Obx(() {
                        final hasUnread = _controller.notificationController.unreadCount.value > 0;
                        return hasUnread
                            ? IconButton(
                                icon: const Icon(FontAwesomeIcons.checkDouble),
                                tooltip: '全部标记为已读',
                                onPressed: () => _controller.markAllAsRead(),
                              )
                            : const SizedBox(width: 48);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(isMobile, null),
                _buildNotificationList(isMobile, false),
                _buildNotificationList(isMobile, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(bool isMobile, bool? isRead) {
    return Obx(() {
      final notificationController = _controller.notificationController;

      // 首次加载时显示中间加载指示器
      if (notificationController.isLoading.value &&
          notificationController.notifications.isEmpty &&
          !_controller.isRefreshing.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (notificationController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.circleExclamation, size: 64, color: AppColors.iconSecondary),
              const SizedBox(height: 16),
              Text(
                notificationController.errorMessage.value,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notificationController.loadNotifications(isRead: isRead),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }

      final notifications =
          notificationController.notifications.where((n) => isRead == null || n.isRead == isRead).toList();

      if (notifications.isEmpty) {
        return RefreshIndicator(
          onRefresh: _controller.handleRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.bell, size: 64, color: AppColors.iconSecondary),
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
                  ),
                ),
              );
            },
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: notificationController.refresh,
        child: ListView.separated(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, isMobile);
          },
        ),
      );
    });
  }

  Widget _buildNotificationCard(AppNotification notification, bool isMobile) {
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
        child: const Icon(FontAwesomeIcons.trash, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _controller.deleteNotification(notification.id),
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await _controller.markAsRead(notification.id);
          }
          _controller.handleNotificationTap(notification);
        },
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.2),
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
                  color: color.withValues(alpha: 0.1),
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
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
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
                      _controller.formatTime(notification.createdAt),
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
}
