import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';

/// 通知数据响应（包含列表和未读数量）
class NotificationDataResponse {
  final List<AppNotification> notifications;
  final int totalCount;
  final int unreadCount;

  NotificationDataResponse({
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
  });
}

/// 通知仓储接口
abstract class INotificationRepository {
  /// 获取用户的所有通知（包含未读数量）
  Future<Result<NotificationDataResponse>> getUserNotifications({
    bool? isRead,
    NotificationType? type,
    int? limit,
    int? offset,
  });

  /// 获取未读通知数量（单独调用，用于刷新徽章）
  Future<Result<int>> getUnreadCount();

  /// 标记通知为已读
  Future<Result<bool>> markAsRead(String notificationId);

  /// 更新通知元数据
  Future<Result<bool>> updateMetadata(String notificationId, Map<String, dynamic> metadata);

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

  /// 响应活动邀请
  Future<Result<bool>> respondToEventInvitation({
    required String notificationId,
    required String invitationId,
    required bool accepted,
  });

  /// 响应版主转让请求
  Future<Result<bool>> respondToModeratorTransfer({
    required String notificationId,
    required String transferId,
    required bool accepted,
  });
}
