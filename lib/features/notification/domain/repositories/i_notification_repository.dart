import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';

/// 通知仓储接口
abstract class INotificationRepository {
  /// 获取用户的所有通知
  Future<Result<List<AppNotification>>> getUserNotifications({
    bool? isRead,
    NotificationType? type,
    int? limit,
    int? offset,
  });

  /// 获取未读通知数量
  Future<Result<int>> getUnreadCount();

  /// 标记通知为已读
  Future<Result<bool>> markAsRead(String notificationId);

  /// 批量标记为已读
  Future<Result<bool>> markMultipleAsRead(List<String> notificationIds);

  /// 标记所有通知为已读
  Future<Result<bool>> markAllAsRead();

  /// 删除通知
  Future<Result<bool>> deleteNotification(String notificationId);

  /// 发送通知（用于版主申请等）
  Future<Result<AppNotification>> sendNotification({
    required String recipientUserId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? metadata,
  });

  /// 发送给所有管理员
  Future<Result<List<AppNotification>>> sendToAdmins({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? metadata,
  });
}
