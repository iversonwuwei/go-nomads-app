import 'dart:developer';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/domain/repositories/i_notification_repository.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller_v2.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:get/get.dart';

/// 通知仓储实现
class NotificationRepository implements INotificationRepository {
  final HttpService _httpService;

  NotificationRepository(this._httpService);

  /// 获取当前用户ID
  String? get _currentUserId {
    try {
      final userController = Get.find<UserStateControllerV2>();
      final userId = userController.currentUser.value?.id;
      log('📋 NotificationRepository._currentUserId: $userId');
      log('📋 currentUser 对象: ${userController.currentUser.value}');
      return userId;
    } catch (e) {
      log('❌ 获取当前用户ID失败: $e');
      return null;
    }
  }

  @override
  Future<Result<NotificationDataResponse>> getUserNotifications({
    bool? isRead,
    NotificationType? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure(const UnauthorizedException('用户未登录'));
      }

      // 构建查询参数
      final params = <String, dynamic>{
        'userId': userId,
        'page': (offset ?? 0) ~/ (limit ?? 20) + 1,
        'pageSize': limit ?? 20,
      };

      if (isRead != null) {
        params['isRead'] = isRead;
      }

      final response = await _httpService.get(
        '${ApiConfig.apiBaseUrl}/notifications',
        queryParameters: params,
      );

      log('📦 Repository 收到响应: statusCode=${response.statusCode}');
      log('📦 response.data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data == null) {
          log('❌ response.data 为 null');
          return Result.failure(const NetworkException('响应数据为空'));
        }

        // HttpService 已经解包了外层的 {success, message, data, errors}
        // 所以 response.data 直接就是 {notifications: [], totalCount: 0, unreadCount: 0, ...}
        final notificationsList = response.data['notifications'];
        final totalCount = response.data['totalCount'] as int? ?? 0;
        final unreadCount = response.data['unreadCount'] as int? ?? 0;

        if (notificationsList == null || notificationsList is! List) {
          log('⚠️ notificationsList 为空或不是 List 类型');
          return Result.success(NotificationDataResponse(
            notifications: [],
            totalCount: 0,
            unreadCount: unreadCount,
          ));
        }

        final notifications = notificationsList.map((json) => _mapFromJson(json)).toList();

        log('✅ 成功解析 ${notifications.length} 条通知, 未读: $unreadCount');
        return Result.success(NotificationDataResponse(
          notifications: notifications,
          totalCount: totalCount,
          unreadCount: unreadCount,
        ));
      } else {
        log('❌ HTTP 状态码非 200: ${response.statusCode}');
        return Result.failure(NetworkException(response.data?['message'] ?? '获取通知列表失败'));
      }
    } catch (e, stackTrace) {
      log('❌ Repository 异常: $e');
      log('❌ 堆栈: $stackTrace');
      return Result.failure(NetworkException('获取通知列表失败: $e'));
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure(const UnauthorizedException('用户未登录'));
      }

      final response = await _httpService.get(
        '${ApiConfig.apiBaseUrl}/notifications/unread/count',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final count = response.data['data']['unreadCount'] as int? ?? 0;
        return Result.success(count);
      } else {
        return Result.failure(NetworkException(response.data['message'] ?? '获取未读数量失败'));
      }
    } catch (e) {
      return Result.failure(NetworkException('获取未读数量失败: $e'));
    }
  }

  @override
  Future<Result<bool>> markAsRead(String notificationId) async {
    try {
      final response = await _httpService.put(
        '${ApiConfig.apiBaseUrl}/notifications/$notificationId/read',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Result.success(true);
      } else {
        return Result.failure(NetworkException(response.data['message'] ?? '标记已读失败'));
      }
    } catch (e) {
      return Result.failure(NetworkException('标记已读失败: $e'));
    }
  }

  @override
  Future<Result<bool>> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure(const UnauthorizedException('用户未登录'));
      }

      final response = await _httpService.put(
        '${ApiConfig.apiBaseUrl}/notifications/read/batch?userId=$userId',
        data: {
          'notificationIds': notificationIds,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Result.success(true);
      } else {
        return Result.failure(NetworkException(response.data['message'] ?? '批量标记已读失败'));
      }
    } catch (e) {
      return Result.failure(NetworkException('批量标记已读失败: $e'));
    }
  }

  @override
  Future<Result<bool>> markAllAsRead() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure(const UnauthorizedException('用户未登录'));
      }

      final response = await _httpService.put(
        '${ApiConfig.apiBaseUrl}/notifications/read/all?userId=$userId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Result.success(true);
      } else {
        return Result.failure(NetworkException(response.data['message'] ?? '标记所有已读失败'));
      }
    } catch (e) {
      return Result.failure(NetworkException('标记所有已读失败: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteNotification(String notificationId) async {
    try {
      final response = await _httpService.delete(
        '${ApiConfig.apiBaseUrl}/notifications/$notificationId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Result.success(true);
      } else {
        return Result.failure(NetworkException(response.data['message'] ?? '删除通知失败'));
      }
    } catch (e) {
      return Result.failure(NetworkException('删除通知失败: $e'));
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
        '${ApiConfig.apiBaseUrl}/notifications',
        data: {
          'userId': recipientUserId,
          'title': title,
          'message': message,
          'type': _typeToString(type),
          if (relatedId != null) 'relatedId': relatedId,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.statusCode == 200) {
        final notification = _mapFromJson(response.data['data']);
        return Result.success(notification);
      } else {
        return Result.failure(NetworkException(response.data['message'] ?? '发送通知失败'));
      }
    } catch (e) {
      return Result.failure(NetworkException('发送通知失败: $e'));
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
      log('📤 发送通知给管理员: title=$title, type=${_typeToString(type)}');

      final response = await _httpService.post(
        '${ApiConfig.apiBaseUrl}/notifications/admins',
        data: {
          'title': title,
          'message': message,
          'type': _typeToString(type),
          if (relatedId != null) 'relatedId': relatedId,
          if (metadata != null) 'metadata': metadata,
        },
      );

      log('📤 SendToAdmins 响应: statusCode=${response.statusCode}');
      log('📤 response.data 类型: ${response.data?.runtimeType}');
      log('📤 response.data: ${response.data}');

      if (response.statusCode == 200) {
        // HttpService 已经解包了响应，response.data 直接是数据数组
        if (response.data == null) {
          log('⚠️ response.data 为 null，返回空列表');
          return Result.success([]);
        }

        if (response.data is! List) {
          log('❌ response.data 不是 List 类型: ${response.data.runtimeType}');
          return Result.failure(const NetworkException('响应数据格式错误'));
        }

        final notifications =
            (response.data as List).map((json) => _mapFromJson(json as Map<String, dynamic>)).toList();

        log('✅ 成功发送通知给 ${notifications.length} 位管理员');
        return Result.success(notifications);
      } else {
        log('❌ 发送失败: statusCode=${response.statusCode}');
        return Result.failure(NetworkException(response.data?['message'] ?? '发送通知给管理员失败'));
      }
    } catch (e, stackTrace) {
      log('❌ 发送通知给管理员异常: $e');
      log('❌ 堆栈: $stackTrace');
      return Result.failure(NetworkException('发送通知给管理员失败: $e'));
    }
  }

  /// 将 JSON 映射为 AppNotification 对象
  AppNotification _mapFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _stringToType(json['type'] as String),
      relatedId: json['relatedId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
    );
  }

  /// 将 NotificationType 转换为字符串
  String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.moderatorApplication:
        return 'moderator_application';
      case NotificationType.moderatorApproved:
        return 'moderator_approved';
      case NotificationType.moderatorRejected:
        return 'moderator_rejected';
      case NotificationType.cityUpdate:
        return 'city_update';
      case NotificationType.systemAnnouncement:
        return 'system_announcement';
      case NotificationType.eventInvitation:
        return 'event_invitation';
      case NotificationType.eventInvitationResponse:
        return 'event_invitation_response';
      case NotificationType.other:
        return 'other';
    }
  }

  /// 将字符串转换为 NotificationType
  NotificationType _stringToType(String type) {
    switch (type) {
      case 'moderator_application':
        return NotificationType.moderatorApplication;
      case 'moderator_approved':
        return NotificationType.moderatorApproved;
      case 'moderator_rejected':
        return NotificationType.moderatorRejected;
      case 'city_update':
        return NotificationType.cityUpdate;
      case 'system_announcement':
        return NotificationType.systemAnnouncement;
      case 'event_invitation':
        return NotificationType.eventInvitation;
      case 'event_invitation_response':
        return NotificationType.eventInvitationResponse;
      default:
        return NotificationType.other;
    }
  }
}
