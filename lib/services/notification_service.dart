import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 通知渠道配置
  static const String _channelId = 'guide_generation';
  static const String _channelName = 'Guide Generation';
  static const String _channelDescription =
      'Notifications for guide generation progress';
  static const String _androidIcon = '@mipmap/go_nomads';

  /// 初始化通知服务
  Future<NotificationService> init() async {
    // Android 初始化配置
    const androidSettings = AndroidInitializationSettings(_androidIcon);

    // iOS 初始化配置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 初始化并设置点击回调
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 请求通知权限
    await _requestPermissions();

    return this;
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // Android 13+ 需要运行时权限
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS 权限请求
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 显示 Guide 生成进行中通知
  Future<void> showGuideGenerating(String cityName, {int progress = 0}) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      icon: 'go_nomads',
      ongoing: true, // 持续显示,不可滑动删除
      showProgress: true,
      maxProgress: 100,
      progress: progress, // 使用实际进度值
      playSound: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      cityName.hashCode, // 使用城市名称的 hashCode 作为通知 ID
      '正在生成旅游指南',
      '正在为 $cityName 生成数字游民指南... $progress%',
      details,
    );
  }

  /// 显示 Guide 生成完成通知
  Future<void> showGuideCompleted(String cityId, String cityName) async {
    // 先取消进行中的通知
    await _notifications.cancel(cityName.hashCode);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'go_nomads',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // payload 格式: cityId|cityName
    await _notifications.show(
      cityName.hashCode,
      '旅游指南已生成',
      '$cityName 的数字游民指南已准备就绪,点击查看',
      details,
      payload: '$cityId|$cityName',
    );
  }

  /// 显示 Guide 生成失败通知
  Future<void> showGuideFailed(String cityName, String error) async {
    // 先取消进行中的通知
    await _notifications.cancel(cityName.hashCode);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'go_nomads',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      cityName.hashCode,
      '指南生成失败',
      '$cityName 的指南生成失败: $error',
      details,
    );
  }

  /// 取消通知
  Future<void> cancelNotification(String cityName) async {
    await _notifications.cancel(cityName.hashCode);
  }

  /// 处理通知点击事件
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;

    // 解析 payload: cityId|cityName
    final parts = response.payload!.split('|');
    if (parts.length != 2) return;

    final cityId = parts[0];
    final cityName = parts[1];

    // 导航到城市详情页面的 Guide Tab
    Get.toNamed(
      '/city-detail',
      arguments: {
        'cityId': cityId,
        'cityName': cityName,
        'initialTab': 2, // Guide Tab 的索引
      },
    );
  }
}
