import 'dart:developer';

import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 通知列表页面控制器
class NotificationsPageController extends GetxController {
  late final NotificationStateController notificationController;

  final RxBool isRefreshing = false.obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 设置中文 timeago
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());

    // 获取通知控制器
    notificationController = Get.find<NotificationStateController>();

    // 延迟加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isInitialized.value) {
        isInitialized.value = true;
        log('📱 页面初始化完成，开始加载通知数据');
        notificationController.loadNotifications();
      }
    });
  }

  /// 下拉刷新
  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    await notificationController.refresh();
    isRefreshing.value = false;
  }

  /// 根据 tab 加载通知
  void loadNotificationsByTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        notificationController.loadNotifications();
        break;
      case 1:
        notificationController.loadNotifications(isRead: false);
        break;
      case 2:
        notificationController.loadNotifications(isRead: true);
        break;
    }
  }

  /// 全部标记为已读
  Future<void> markAllAsRead() async {
    final success = await notificationController.markAllAsRead();
    if (success) {
      AppToast.success('已全部标记为已读');
    }
  }

  /// 标记单个为已读
  Future<void> markAsRead(String id) async {
    await notificationController.markAsRead(id);
  }

  /// 删除通知
  void deleteNotification(String id) {
    notificationController.deleteNotification(id);
    AppToast.info('通知已删除');
  }

  /// 处理通知点击
  void handleNotificationTap(AppNotification notification) {
    log('🔔 _handleNotificationTap: type=${notification.type}');
    log('   relatedId: ${notification.relatedId}');
    log('   metadata: ${notification.metadata}');

    switch (notification.type) {
      case NotificationType.moderatorApplication:
        final applicationId = notification.metadata?['applicationId'] ?? notification.relatedId;
        log('   applicationId to use: $applicationId');

        if (applicationId != null && applicationId.toString().isNotEmpty) {
          Get.toNamed(
            AppRoutes.moderatorApplicationDetail,
            arguments: {'applicationId': applicationId.toString()},
          );
        } else {
          AppToast.error('无法获取申请ID，请刷新通知列表');
        }
        break;

      case NotificationType.moderatorApproved:
      case NotificationType.moderatorRejected:
        final cityId = notification.metadata?['cityId'] ?? notification.relatedId;
        if (cityId != null) {
          Get.toNamed(
            AppRoutes.cityDetail,
            arguments: {
              'cityId': cityId,
              'cityName': notification.metadata?['cityName'] ?? '',
            },
          );
        }
        break;

      case NotificationType.cityUpdate:
        if (notification.relatedId != null) {
          Get.toNamed(
            AppRoutes.cityDetail,
            arguments: {
              'cityId': notification.relatedId,
              'cityName': notification.metadata?['cityName'] ?? '',
            },
          );
        }
        break;

      case NotificationType.systemAnnouncement:
        _showAnnouncementDialog(notification);
        break;

      case NotificationType.eventInvitation:
        final eventId = notification.metadata?['eventId'] ?? notification.relatedId;
        if (eventId != null) {
          Get.toNamed(
            AppRoutes.meetupDetail,
            arguments: {'meetupId': eventId.toString()},
          );
        }
        break;

      case NotificationType.eventInvitationResponse:
        final eventId = notification.metadata?['eventId'] ?? notification.relatedId;
        if (eventId != null) {
          Get.toNamed(
            AppRoutes.meetupDetail,
            arguments: {'meetupId': eventId.toString()},
          );
        }
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

  /// 格式化时间
  String formatTime(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'zh_CN');
  }
}
