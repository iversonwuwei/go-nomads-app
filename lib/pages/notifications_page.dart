import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/notifications_page_controller.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

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
                          tabs: [
                            Tab(text: AppLocalizations.of(context)!.allNotifications),
                            Tab(text: AppLocalizations.of(context)!.unread),
                            Tab(text: AppLocalizations.of(context)!.read),
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
                                tooltip: AppLocalizations.of(context)!.markAllAsRead,
                                onPressed: () => _controller.markAllAsRead(),
                              )
                            : SizedBox(width: 48.w);
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
      final isLoading = notificationController.isLoading.value &&
          notificationController.notifications.isEmpty &&
          !_controller.isRefreshing.value;

      Widget content;
      if (notificationController.errorMessage.value.isNotEmpty) {
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.circleExclamation, size: 64.r, color: AppColors.iconSecondary),
              SizedBox(height: 16.h),
              Text(
                notificationController.errorMessage.value,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => notificationController.loadNotifications(isRead: isRead),
                child: Text(AppLocalizations.of(Get.context!)!.retry),
              ),
            ],
          ),
        );
      } else {
        final notifications =
            notificationController.notifications.where((n) => isRead == null || n.isRead == isRead).toList();

        if (notifications.isEmpty) {
          content = RefreshIndicator(
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
                          Icon(FontAwesomeIcons.bell, size: 64.r, color: AppColors.iconSecondary),
                          SizedBox(height: 16.h),
                          Text(
                            isRead == null
                                ? AppLocalizations.of(context)!.noNotifications
                                : isRead
                                    ? AppLocalizations.of(context)!.noReadNotifications
                                    : AppLocalizations.of(context)!.noUnreadNotifications,
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
        } else {
          content = RefreshIndicator(
            onRefresh: notificationController.refresh,
            child: ListView.separated(
              padding: EdgeInsets.all(isMobile ? 8 : 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification, isMobile);
              },
            ),
          );
        }
      }

      return AppLoadingSwitcher(
        isLoading: isLoading,
        loading: const NotificationListSkeleton(),
        child: content,
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
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
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
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notification.type.icon,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

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
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4.h),

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

                    SizedBox(height: 8.h),

                    // 时间
                    Text(
                      _controller.formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
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
