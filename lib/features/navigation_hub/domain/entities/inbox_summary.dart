import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';

class InboxSummary {
  final int unreadNotifications;
  final int totalNotifications;
  final int actionRequiredCount;
  final DateTime? latestNotificationAt;
  final List<AppNotification> recentNotifications;

  const InboxSummary({
    required this.unreadNotifications,
    required this.totalNotifications,
    required this.actionRequiredCount,
    required this.latestNotificationAt,
    required this.recentNotifications,
  });

  factory InboxSummary.fromJson(Map<String, dynamic> json) {
    final recentNotificationsJson =
        (json['recentNotifications'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return InboxSummary(
      unreadNotifications: json['unreadNotifications'] as int? ?? 0,
      totalNotifications: json['totalNotifications'] as int? ?? 0,
      actionRequiredCount: json['actionRequiredCount'] as int? ?? 0,
      latestNotificationAt: json['latestNotificationAt'] != null
          ? DateTime.tryParse(json['latestNotificationAt'] as String)
          : null,
      recentNotifications: recentNotificationsJson.map(AppNotification.fromJson).toList(),
    );
  }
}