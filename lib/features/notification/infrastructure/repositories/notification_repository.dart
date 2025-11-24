import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/domain/repositories/i_notification_repository.dart';
import 'package:df_admin_mobile/services/http_service.dart';

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
    // TODO: 临时使用测试数据，后续替换为真实 API 调用
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟

    final testNotifications = [
      // 系统消息
      AppNotification(
        id: '1',
        userId: 'current-user-id',
        type: NotificationType.systemAnnouncement,
        title: '🎉 欢迎加入 Nomads 社区',
        message: '感谢您注册成为 Nomads 平台的一员！在这里，您可以探索全球数字游民热门城市，结识志同道合的朋友，分享您的远程工作经验。',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        metadata: {'priority': 'high', 'category': 'welcome'},
      ),
      AppNotification(
        id: '2',
        userId: 'current-user-id',
        type: NotificationType.systemAnnouncement,
        title: '📢 系统维护通知',
        message: '系统将于今晚 23:00 - 24:00 进行例行维护，届时部分功能可能暂时无法使用，敬请谅解。',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        metadata: {'priority': 'medium', 'maintenanceTime': '23:00-24:00'},
      ),

      // 版主申请消息
      AppNotification(
        id: '3',
        userId: 'current-user-id',
        type: NotificationType.moderatorApplication,
        title: '📝 新的城市版主申请',
        message: '用户 @张伟 申请成为「清迈」的城市版主。请审核申请人的资料和申请理由。',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        relatedId: 'chiang-mai',
        metadata: {
          'applicantName': '张伟',
          'applicantId': 'user-123',
          'cityName': '清迈',
          'applicationReason': '我在清迈生活工作2年，熟悉当地数字游民社区'
        },
      ),
      AppNotification(
        id: '4',
        userId: 'current-user-id',
        type: NotificationType.moderatorApproved,
        title: '✅ 版主申请已通过',
        message: '恭喜！您申请的「巴厘岛」城市版主已通过审核。现在您可以管理该城市的内容，帮助更多数字游民了解巴厘岛。',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        relatedId: 'bali',
        metadata: {
          'cityName': '巴厘岛',
          'approvedBy': 'admin-001',
          'approvedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()
        },
      ),
      AppNotification(
        id: '5',
        userId: 'current-user-id',
        type: NotificationType.moderatorRejected,
        title: '❌ 版主申请未通过',
        message: '很遗憾，您申请的「东京」城市版主未通过审核。原因：需要更多在该城市的实际居住经验。欢迎在积累更多经验后再次申请。',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        relatedId: 'tokyo',
        metadata: {'cityName': '东京', 'rejectionReason': '需要更多在该城市的实际居住经验', 'rejectedBy': 'admin-002'},
      ),

      // 聊天提醒消息
      AppNotification(
        id: '6',
        userId: 'current-user-id',
        type: NotificationType.cityUpdate,
        title: '💬 曼谷聊天室有新消息',
        message: '@李明 在曼谷聊天室提到了你：「@你 周末一起去 Hubba 共享办公空间看看？」',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        relatedId: 'bangkok-chat',
        metadata: {
          'chatRoomId': 'bangkok',
          'chatRoomName': '曼谷数字游民',
          'senderName': '李明',
          'senderId': 'user-456',
          'messagePreview': '周末一起去 Hubba 共享办公空间看看？'
        },
      ),
      AppNotification(
        id: '7',
        userId: 'current-user-id',
        type: NotificationType.cityUpdate,
        title: '💬 清迈聊天室消息',
        message: '清迈聊天室有 3 条新消息未读。快来看看大家都在聊什么吧！',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        relatedId: 'chiang-mai-chat',
        metadata: {'chatRoomId': 'chiang-mai', 'chatRoomName': '清迈数字游民', 'unreadCount': 3},
      ),
      AppNotification(
        id: '8',
        userId: 'current-user-id',
        type: NotificationType.other,
        title: '👥 新的活动邀请',
        message: '@Sarah 邀请您参加「曼谷数字游民周末聚会」。时间：本周六下午 3:00，地点：Sukhumvit 路 The Commons。',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        relatedId: 'meetup-001',
        metadata: {
          'eventName': '曼谷数字游民周末聚会',
          'eventTime': '本周六 15:00',
          'eventLocation': 'The Commons, Sukhumvit',
          'inviterName': 'Sarah',
          'inviterId': 'user-789'
        },
      ),
    ];

    // 应用过滤条件
    var filtered = testNotifications;

    if (isRead != null) {
      filtered = filtered.where((n) => n.isRead == isRead).toList();
    }

    if (type != null) {
      filtered = filtered.where((n) => n.type == type).toList();
    }

    // 按时间倒序排序
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 应用分页
    if (offset != null) {
      filtered = filtered.skip(offset).toList();
    }

    if (limit != null) {
      filtered = filtered.take(limit).toList();
    }

    return Result.success(filtered);

    /* 真实 API 调用代码（暂时注释）
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
    */
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    // TODO: 临时返回测试数据中的未读数量
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(5); // 5条未读消息

    /* 真实 API 调用代码（暂时注释）
    try {
      final response = await _httpService.get(
        ApiConfig.buildUrl('/notifications/unread/count'),
      );

      final count = response.data['count'] as int? ?? 0;
      return Result.success(count);
    } catch (e) {
      return Result.failure(NetworkException('获取未读数量失败: ${e.toString()}'));
    }
    */
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
