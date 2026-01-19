import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/features/notification/domain/repositories/i_notification_repository.dart';
import 'package:get/get.dart';

/// 通知状态控制器
class NotificationStateController extends GetxController {
  final INotificationRepository _repository;

  NotificationStateController(this._repository);

  // 通知列表
  final notifications = <AppNotification>[].obs;
  
  // 未读数量
  final unreadCount = 0.obs;
  
  // 加载状态
  final isLoading = false.obs;
  
  // 错误信息
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('🔔 NotificationStateController.onInit() 被调用');
    // 不在这里自动加载，等页面显示时再加载
    // 这样可以确保用户已经登录
  }

  /// 加载通知列表（初始化时调用，一次获取列表和未读数）
  Future<void> loadNotifications({
    bool? isRead,
    NotificationType? type,
  }) async {
    log('🔔 开始加载通知列表: isRead=$isRead');
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getUserNotifications(
      isRead: isRead,
      type: type,
      limit: 50,
    );

    result.fold(
      onSuccess: (response) {
        log('✅ 加载成功: ${response.notifications.length} 条通知, 未读: ${response.unreadCount}');
        notifications.value = response.notifications;
        unreadCount.value = response.unreadCount;
      },
      onFailure: (error) {
        log('❌ 加载失败: ${error.message}');
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
  }

  /// 刷新未读数量（单独调用，用于更新徽章）
  Future<void> refreshUnreadCount() async {
    log('🔔 刷新未读数量');
    final result = await _repository.getUnreadCount();
    
    result.fold(
      onSuccess: (count) {
        log('✅ 未读数量: $count');
        unreadCount.value = count;
      },
      onFailure: (failure) {
        log('❌ 刷新未读数量失败: ${failure.message}');
        // 静默失败
      },
    );
  }

  /// 标记为已读
  Future<bool> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    
    return result.fold(
      onSuccess: (_) {
        // 更新本地状态
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].markAsRead();
          notifications.refresh();
        }
        
        // 更新未读数量
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
        
        return true;
      },
      onFailure: (_) => false,
    );
  }

  /// 标记所有为已读
  Future<bool> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    
    return result.fold(
      onSuccess: (_) {
        // 更新所有通知为已读
        notifications.value = notifications
            .map((n) => n.isRead ? n : n.markAsRead())
            .toList();
        unreadCount.value = 0;
        return true;
      },
      onFailure: (_) => false,
    );
  }

  /// 删除通知
  Future<bool> deleteNotification(String notificationId) async {
    final result = await _repository.deleteNotification(notificationId);
    
    return result.fold(
      onSuccess: (_) {
        // 从列表中移除
        final wasUnread = notifications
            .firstWhere((n) => n.id == notificationId, orElse: () => notifications.first)
            .isRead == false;
        
        notifications.removeWhere((n) => n.id == notificationId);
        
        if (wasUnread && unreadCount.value > 0) {
          unreadCount.value--;
        }
        
        return true;
      },
      onFailure: (_) => false,
    );
  }

  /// 发送通知给管理员（版主申请时使用）
  Future<bool> sendToAdmins({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? metadata,
  }) async {
    log('🔔 Controller.sendToAdmins 开始: title=$title');
    
    final result = await _repository.sendToAdmins(
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      metadata: metadata,
    );

    return result.fold(
      onSuccess: (notifications) {
        log('✅ Controller.sendToAdmins 成功: 发送给 ${notifications.length} 位管理员');
        return true;
      },
      onFailure: (failure) {
        log('❌ Controller.sendToAdmins 失败: ${failure.message}');
        return false;
      },
    );
  }

  /// 响应活动邀请
  Future<bool> respondToEventInvitation({
    required String notificationId,
    required String invitationId,
    required bool accepted,
  }) async {
    log('🔔 响应活动邀请: invitationId=$invitationId, accepted=$accepted');
    
    final result = await _repository.respondToEventInvitation(
      notificationId: notificationId,
      invitationId: invitationId,
      accepted: accepted,
    );

    return result.fold(
      onSuccess: (_) {
        log('✅ 响应活动邀请成功');
        // 更新本地通知状态
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].markAsRead();
          notifications.refresh();
        }
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
        return true;
      },
      onFailure: (failure) {
        log('❌ 响应活动邀请失败: ${failure.message}');
        return false;
      },
    );
  }

  /// 响应版主转让请求
  Future<bool> respondToModeratorTransfer({
    required String notificationId,
    required String transferId,
    required bool accepted,
  }) async {
    log('🔔 响应版主转让: transferId=$transferId, accepted=$accepted');
    
    final result = await _repository.respondToModeratorTransfer(
      notificationId: notificationId,
      transferId: transferId,
      accepted: accepted,
    );

    return result.fold(
      onSuccess: (_) {
        log('✅ 响应版主转让成功');
        // 更新本地通知状态
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].markAsRead();
          notifications.refresh();
        }
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
        return true;
      },
      onFailure: (failure) {
        log('❌ 响应版主转让失败: ${failure.message}');
        return false;
      },
    );
  }

  /// 刷新（下拉刷新）
  @override
  Future<void> refresh() async {
    // 只需要调用一次 loadNotifications，它会同时获取列表和未读数
    await loadNotifications();
  }

  /// 清除所有通知数据（用户登出时调用）
  void clearNotifications() {
    log('🔔 清除通知数据');
    notifications.clear();
    unreadCount.value = 0;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    notifications.clear();
    unreadCount.value = 0;
    isLoading.value = false;
    errorMessage.value = '';
    
    super.onClose();
  }
}
