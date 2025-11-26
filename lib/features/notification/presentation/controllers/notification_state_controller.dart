import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/domain/repositories/i_notification_repository.dart';
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
    print('🔔 NotificationStateController.onInit() 被调用');
    // 不在这里自动加载，等页面显示时再加载
    // 这样可以确保用户已经登录
  }

  /// 加载通知列表（初始化时调用，一次获取列表和未读数）
  Future<void> loadNotifications({
    bool? isRead,
    NotificationType? type,
  }) async {
    print('🔔 开始加载通知列表: isRead=$isRead');
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getUserNotifications(
      isRead: isRead,
      type: type,
      limit: 50,
    );

    result.fold(
      onSuccess: (response) {
        print('✅ 加载成功: ${response.notifications.length} 条通知, 未读: ${response.unreadCount}');
        notifications.value = response.notifications;
        unreadCount.value = response.unreadCount;
      },
      onFailure: (error) {
        print('❌ 加载失败: ${error.message}');
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
  }

  /// 刷新未读数量（单独调用，用于更新徽章）
  Future<void> refreshUnreadCount() async {
    print('🔔 刷新未读数量');
    final result = await _repository.getUnreadCount();
    
    result.fold(
      onSuccess: (count) {
        print('✅ 未读数量: $count');
        unreadCount.value = count;
      },
      onFailure: (failure) {
        print('❌ 刷新未读数量失败: ${failure.message}');
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
    print('🔔 Controller.sendToAdmins 开始: title=$title');
    
    final result = await _repository.sendToAdmins(
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      metadata: metadata,
    );

    return result.fold(
      onSuccess: (notifications) {
        print('✅ Controller.sendToAdmins 成功: 发送给 ${notifications.length} 位管理员');
        return true;
      },
      onFailure: (failure) {
        print('❌ Controller.sendToAdmins 失败: ${failure.message}');
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
