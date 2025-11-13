import '../../../../config/api_config.dart';
import '../../../../core/domain/result.dart';
import '../../../../services/http_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/i_notification_repository.dart';

/// 通知仓储实现
class NotificationRepository implements INotificationRepository {
  final HttpService _httpService;

  NotificationRepository(this._httpService);

  @override
  Future<Result<List<AppNotification>>> getUserNotifications({
    bool? isRead,
    NotificationType? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) queryParams['isRead'] = isRead.toString();
      if (type != null) queryParams['type'] = type.value;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final queryString = queryParams.isEmpty
          ? ''
          : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      final response = await _httpService.get(
        ApiConfig.buildUrl('/notifications$queryString'),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final notifications = data
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(notifications);
    } catch (e) {
      return Result.failure(NetworkException('获取通知列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final response = await _httpService.get(
        ApiConfig.buildUrl('/notifications/unread/count'),
      );

      final count = response.data['count'] as int? ?? 0;
      return Result.success(count);
    } catch (e) {
      return Result.failure(NetworkException('获取未读数量失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> markAsRead(String notificationId) async {
    try {
      await _httpService.put(
        ApiConfig.buildUrl('/notifications/$notificationId/read'),
        data: {},
      );

      return Result.success(true);
    } catch (e) {
      return Result.failure(NetworkException('标记通知已读失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> markMultipleAsRead(List<String> notificationIds) async {
    try {
      await _httpService.put(
        ApiConfig.buildUrl('/notifications/read/batch'),
        data: {'notificationIds': notificationIds},
      );

      return Result.success(true);
    } catch (e) {
      return Result.failure(NetworkException('批量标记已读失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> markAllAsRead() async {
    try {
      await _httpService.put(
        ApiConfig.buildUrl('/notifications/read/all'),
        data: {},
      );

      return Result.success(true);
    } catch (e) {
      return Result.failure(NetworkException('标记全部已读失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> deleteNotification(String notificationId) async {
    try {
      await _httpService.delete(
        ApiConfig.buildUrl('/notifications/$notificationId'),
      );

      return Result.success(true);
    } catch (e) {
      return Result.failure(NetworkException('删除通知失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<AppNotification>> sendNotification({
    required String recipientUserId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.buildUrl('/notifications'),
        data: {
          'recipientUserId': recipientUserId,
          'title': title,
          'message': message,
          'type': type.value,
          'relatedId': relatedId,
          'metadata': metadata,
        },
      );

      final notification = AppNotification.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(notification);
    } catch (e) {
      return Result.failure(NetworkException('发送通知失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<AppNotification>>> sendToAdmins({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.buildUrl('/notifications/admins'),
        data: {
          'title': title,
          'message': message,
          'type': type.value,
          'relatedId': relatedId,
          'metadata': metadata,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final notifications = data
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(notifications);
    } catch (e) {
      return Result.failure(NetworkException('发送管理员通知失败: ${e.toString()}'));
    }
  }
}
