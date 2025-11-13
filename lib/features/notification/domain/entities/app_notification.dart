import 'package:equatable/equatable.dart';

/// 应用内通知实体
class AppNotification extends Equatable {
  final String id;
  final String userId; // 接收者ID
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId; // 关联的ID（如城市ID、申请ID等）
  final Map<String, dynamic>? metadata; // 额外数据
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  /// 从 JSON 创建
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromString(json['type'] as String),
      relatedId: json['relatedId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'relatedId': relatedId,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// 标记为已读
  AppNotification markAsRead() {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      metadata: metadata,
      isRead: true,
      createdAt: createdAt,
      readAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        relatedId,
        metadata,
        isRead,
        createdAt,
        readAt,
      ];
}

/// 通知类型
enum NotificationType {
  moderatorApplication('moderator_application'), // 版主申请
  moderatorApproved('moderator_approved'), // 版主申请通过
  moderatorRejected('moderator_rejected'), // 版主申请被拒
  cityUpdate('city_update'), // 城市信息更新
  systemAnnouncement('system_announcement'), // 系统公告
  other('other'); // 其他

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.other,
    );
  }

  /// 获取图标
  String get icon {
    switch (this) {
      case NotificationType.moderatorApplication:
        return '📝';
      case NotificationType.moderatorApproved:
        return '✅';
      case NotificationType.moderatorRejected:
        return '❌';
      case NotificationType.cityUpdate:
        return '🌆';
      case NotificationType.systemAnnouncement:
        return '📢';
      case NotificationType.other:
        return '🔔';
    }
  }

  /// 获取颜色（返回颜色代码字符串）
  String get colorHex {
    switch (this) {
      case NotificationType.moderatorApplication:
        return '#FF9800'; // 橙色
      case NotificationType.moderatorApproved:
        return '#4CAF50'; // 绿色
      case NotificationType.moderatorRejected:
        return '#F44336'; // 红色
      case NotificationType.cityUpdate:
        return '#2196F3'; // 蓝色
      case NotificationType.systemAnnouncement:
        return '#9C27B0'; // 紫色
      case NotificationType.other:
        return '#757575'; // 灰色
    }
  }
}
