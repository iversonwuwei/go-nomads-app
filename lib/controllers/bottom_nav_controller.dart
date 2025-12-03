import 'dart:developer';

import 'dart:async';

import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:get/get.dart';

/// 底部导航控制器
/// 管理底部导航栏的状态和页面切换
class BottomNavController extends GetxController {
  // 当前选中的标签索引
  final RxInt currentIndex = 0.obs;

  // 导航栏可见性
  final RxBool isBottomNavVisible = true.obs;

  // 未读消息数量 - 从 NotificationStateController 同步
  final RxInt unreadCount = 0.obs;

  // Worker 用于监听通知控制器的未读数量变化
  Worker? _unreadCountWorker;

  // SignalR 通知订阅
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    // 延迟初始化，确保其他控制器已注册
    Future.delayed(const Duration(milliseconds: 500), () {
      _setupUnreadCountListener();
      _setupSignalRNotificationListener();
      _refreshUnreadCount();
    });
  }

  @override
  void onClose() {
    _unreadCountWorker?.dispose();
    _notificationSubscription?.cancel();
    super.onClose();
  }

  /// 设置未读数量监听器
  void _setupUnreadCountListener() {
    try {
      if (Get.isRegistered<NotificationStateController>()) {
        final notificationController = Get.find<NotificationStateController>();
        // 监听 NotificationStateController 的 unreadCount 变化
        _unreadCountWorker = ever(notificationController.unreadCount, (count) {
          log('🔔 BottomNav: 未读数量更新为 $count');
          unreadCount.value = count;
        });
        // 同步当前值
        unreadCount.value = notificationController.unreadCount.value;
      }
    } catch (e) {
      log('⚠️ BottomNav: 设置未读数量监听器失败: $e');
    }
  }

  /// 设置 SignalR 实时通知监听器
  void _setupSignalRNotificationListener() {
    try {
      final signalRService = SignalRService();
      _notificationSubscription = signalRService.notificationReceivedStream.listen(
        (notification) {
          log('🔔 BottomNav: 收到 SignalR 实时通知!');
          log('   Title: ${notification['title']}');
          log('   Type: ${notification['type']}');

          // 收到新通知时，增加未读数量
          unreadCount.value++;
          log('🔔 BottomNav: 未读数量 +1, 现在是 ${unreadCount.value}');

          // 同时刷新 NotificationStateController 以保持同步
          if (Get.isRegistered<NotificationStateController>()) {
            final notificationController = Get.find<NotificationStateController>();
            notificationController.refreshUnreadCount();
          }
        },
        onError: (error) {
          log('❌ BottomNav: SignalR 通知监听错误: $error');
        },
      );
      log('✅ BottomNav: SignalR 通知监听器已设置');
    } catch (e) {
      log('⚠️ BottomNav: 设置 SignalR 通知监听器失败: $e');
    }
  }

  /// 刷新未读消息数量
  Future<void> _refreshUnreadCount() async {
    try {
      // 检查是否已登录
      final tokenService = TokenStorageService();
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        unreadCount.value = 0;
        return;
      }

      // 如果 NotificationStateController 已注册，调用其刷新方法
      if (Get.isRegistered<NotificationStateController>()) {
        final notificationController = Get.find<NotificationStateController>();
        await notificationController.refreshUnreadCount();
      }
    } catch (e) {
      log('⚠️ BottomNav: 刷新未读数量失败: $e');
    }
  }

  /// 手动刷新未读数量（供外部调用）
  Future<void> refreshUnreadCount() async {
    await _refreshUnreadCount();
  }

  /// 切换标签页
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// 显示底部导航栏
  void showBottomNav() {
    isBottomNavVisible.value = true;
  }

  /// 隐藏底部导航栏
  void hideBottomNav() {
    isBottomNavVisible.value = false;
  }

  /// 重置到首页
  void resetToHome() {
    currentIndex.value = 0;
  }

  /// 根据当前路由更新选中的标签索引
  void updateIndexByRoute() {
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.home) {
      currentIndex.value = 0;
    } else if (currentRoute == AppRoutes.profile) {
      currentIndex.value = 1; // Profile 是索引 1
    } else if (currentRoute == AppRoutes.aiChat) {
      currentIndex.value = 2; // AI助手是索引 2
    } else if (currentRoute == AppRoutes.languageSettings) {
      currentIndex.value = 3; // 设置是索引 3
    }
  }
}
