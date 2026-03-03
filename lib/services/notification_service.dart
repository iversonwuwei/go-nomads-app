import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/dialogs/permission_purpose_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // 通知启用状态
  final RxBool isEnabled = true.obs;
  static const String _enabledKey = 'notifications_enabled';
  static const String _notificationPurposeShownKey = 'notification_permission_purpose_shown';

  // 通知渠道配置
  static const String _channelId = 'guide_generation';
  static const String _channelName = 'Guide Generation';
  static const String _channelDescription = 'Notifications for guide generation progress';
  static const String _androidIcon = '@mipmap/go_nomads';

  /// 初始化通知服务
  Future<NotificationService> init() async {
    // 加载通知启用状态
    await _loadEnabledState();

    // Android 初始化配置
    const androidSettings = AndroidInitializationSettings(_androidIcon);

    // iOS 初始化配置 - 不在初始化时请求权限，延迟到用户需要时再请求
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
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

    // 如果通知已启用且之前已授权过，静默检查权限状态
    if (isEnabled.value) {
      final prefs = await SharedPreferences.getInstance();
      final hasShownPurpose = prefs.getBool(_notificationPurposeShownKey) ?? false;
      if (hasShownPurpose) {
        // 之前已展示过用途说明并授权过，直接请求（不弹对话框）
        await _requestPermissionsSilent();
      }
      // 否则延迟到用户首次需要通知时再展示用途说明并请求权限
    }

    return this;
  }

  /// 加载通知启用状态
  Future<void> _loadEnabledState() async {
    final prefs = await SharedPreferences.getInstance();
    isEnabled.value = prefs.getBool(_enabledKey) ?? true;
  }

  /// 设置通知启用状态
  Future<void> setEnabled(bool enabled) async {
    isEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      // 启用通知时，展示用途说明后请求权限
      await requestPermissionsWithPurpose();
    } else {
      // 禁用通知时取消所有通知
      await _notifications.cancelAll();
    }
  }

  /// 检查系统通知权限是否已授予
  Future<bool> checkPermissionStatus() async {
    // Android
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.areNotificationsEnabled();
      return granted ?? false;
    }

    // iOS - 默认返回 true，因为 iOS 会在首次请求时弹窗
    return true;
  }

  /// 打开系统通知设置页面
  Future<void> openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  /// 展示用途说明后请求通知权限
  ///
  /// 隐私合规：在请求系统通知权限前，先向用户说明通知的用途。
  Future<bool> requestPermissionsWithPurpose() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownPurpose = prefs.getBool(_notificationPurposeShownKey) ?? false;

    if (!hasShownPurpose) {
      // 首次请求，展示用途说明
      final shouldRequest = await PermissionPurposeDialog.showNotificationPermissionPurpose();
      if (!shouldRequest) {
        log('📋 用户在用途说明对话框中拒绝了通知权限');
        return false;
      }
      await prefs.setBool(_notificationPurposeShownKey, true);
    }

    await _requestPermissionsSilent();
    return true;
  }

  /// 静默请求通知权限（不弹自定义对话框）
  Future<void> _requestPermissionsSilent() async {
    // Android 13+ 需要运行时权限
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS 权限请求
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
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
    // 如果通知已禁用，不显示
    if (!isEnabled.value) return;

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

    // 如果通知已禁用，不显示
    if (!isEnabled.value) return;

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

    // 如果通知已禁用，不显示
    if (!isEnabled.value) return;

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
