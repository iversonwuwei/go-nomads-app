import 'package:get/get.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/i_notification_repository.dart';

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
    loadNotifications();
    loadUnreadCount();
  }

  /// 加载通知列表
  Future<void> loadNotifications({
    bool? isRead,
    NotificationType? type,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getUserNotifications(
      isRead: isRead,
      type: type,
      limit: 50,
    );

    result.fold(
      onSuccess: (data) {
        notifications.value = data;
      },
      onFailure: (error) {
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
  }

  /// 加载未读数量
  Future<void> loadUnreadCount() async {
    final result = await _repository.getUnreadCount();
    
    result.fold(
      onSuccess: (count) {
        unreadCount.value = count;
      },
      onFailure: (_) {
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
    final result = await _repository.sendToAdmins(
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      metadata: metadata,
    );

    return result.fold(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );
  }

  /// 刷新（下拉刷新）
  @override
  Future<void> refresh() async {
    await Future.wait([
      loadNotifications(),
      loadUnreadCount(),
    ]);
  }
}
