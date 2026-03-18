import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/notification_dialogs.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    // 先标记为已读
    markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.moderatorApplication:
        // 版主申请：跳转到审批详情页面
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
        // 版主申请结果：只是通知消息，跳转到城市详情
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

      case NotificationType.moderatorTransfer:
        // 版主转让请求：弹出对话框，同意/拒绝
        _showModeratorTransferDialog(notification);
        break;

      case NotificationType.moderatorTransferResult:
        // 版主转让结果：只是通知消息，跳转到城市详情
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
        // 活动邀请：检查是否已经响应过
        // 如果 metadata 中有 responded 字段或通知已读，说明已经处理过
        final hasResponded = notification.metadata?['responded'] == true || notification.isRead;
        if (hasResponded) {
          // 已响应过，显示提示
          final accepted = notification.metadata?['accepted'] == true;
          AppToast.info(accepted ? '你已接受此邀请' : '你已处理此邀请');
        } else {
          // 未响应，弹出对话框
          _showEventInvitationDialog(notification);
        }
        break;

      case NotificationType.eventInvitationResponse:
        // 活动邀请响应：只是通知消息，用户点击后已通过 _markAsRead 标记已读，无需其他操作
        break;

      case NotificationType.userReport:
      case NotificationType.cityReport:
        // 举报通知：显示举报详情弹窗
        _showReportNotificationDialog(notification);
        break;

      case NotificationType.other:
        break;
    }
  }

  /// 显示活动邀请对话框
  void _showEventInvitationDialog(AppNotification notification) {
    Get.dialog(
      EventInvitationDialog(
        notification: notification,
        onResponse: () => handleRefresh(),
      ),
      barrierDismissible: false,
    );
  }

  /// 显示版主转让对话框
  void _showModeratorTransferDialog(AppNotification notification) {
    Get.dialog(
      ModeratorTransferDialog(
        notification: notification,
        onResponse: () => handleRefresh(),
      ),
      barrierDismissible: false,
    );
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

  /// 显示举报通知详情对话框
  void _showReportNotificationDialog(AppNotification notification) {
    final isCity = notification.type == NotificationType.cityReport;
    final metadata = notification.metadata ?? {};
    final reporterName = metadata['reporterName'] ?? '未知';
    final targetName = metadata['targetName'] ?? '';
    final reasonLabel = metadata['reasonLabel'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Text(isCity ? '🚨' : '⚠️', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            Expanded(child: Text(notification.title, style: TextStyle(fontSize: 16.sp))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            if (targetName.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text('举报对象: $targetName', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
            if (reasonLabel.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text('举报原因: $reasonLabel'),
            ],
            SizedBox(height: 4.h),
            Text('举报人: $reporterName', style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
          ],
        ),
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
