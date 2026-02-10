import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/sync/refreshable_controller.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/chat/presentation/controllers/conversation_list_controller.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';

/// 底部导航控制器
/// 管理底部导航栏的状态和页面切换
class BottomNavController extends GetxController {
  // ==================== 状态 ====================

  /// 当前选中的标签索引
  final currentIndex = 0.obs;

  /// 导航栏可见性
  final isBottomNavVisible = true.obs;

  /// 未读通知数量 - 从 NotificationStateController 同步
  final unreadCount = 0.obs;

  /// IM 未读消息数量 - 从 ConversationListController 同步
  final imUnreadCount = 0.obs;

  // ==================== 私有变量 ====================

  /// Worker 用于监听通知控制器的未读数量变化
  Worker? _unreadCountWorker;

  /// Worker 用于监听 IM 未读数量变化
  Worker? _imUnreadCountWorker;

  /// SignalR 通知订阅
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    log('🔘 BottomNavController: onInit');

    // 延迟初始化，确保其他控制器已注册
    Future.delayed(const Duration(milliseconds: 500), () {
      _setupUnreadCountListener();
      _setupIMUnreadCountListener();
      _setupSignalRNotificationListener();
      _refreshUnreadCount();
    });
  }

  @override
  void onClose() {
    log('🔘 BottomNavController: onClose');
    _unreadCountWorker?.dispose();
    _imUnreadCountWorker?.dispose();
    _notificationSubscription?.cancel();
    super.onClose();
  }

  // ==================== 导航方法 ====================

  /// 处理导航栏点击
  Future<void> onNavTap(int index) async {
    log('🔘 Bottom Nav 点击: index=$index');

    // 首页不需要验证，直接跳转
    if (index == 0) {
      log('✅ 首页，无需验证');
      await _navigateToHome();
      return;
    }

    // 🔒 其他所有页面都需要验证 token
    if (!await _checkAuthentication()) {
      return;
    }

    // 认证有效，允许跳转
    log('✅ 认证有效，允许跳转');
    changeTab(index);

    // 根据索引跳转到对应页面
    switch (index) {
      case 1: // 消息会话列表 (IM)
        log('   → 消息会话列表页面');
        Get.toNamed(AppRoutes.conversations);
        break;
      case 2: // Profile
        log('   → Profile 页面');
        _navigateToProfile();
        break;
      case 3: // 通知列表
        log('   → 通知列表页面');
        Get.toNamed(AppRoutes.notifications);
        break;
    }
  }

  /// 导航到 Profile 页面并触发数据同步
  Future<void> _navigateToProfile() async {
    // 如果 ProfileController 已存在，触发数据同步
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      // 触发数据同步
      profileController.onRouteResume();
    }

    Get.toNamed(AppRoutes.profile);
  }

  /// 导航到首页
  Future<void> _navigateToHome() async {
    changeTab(0);

    // 如果 HomePageController 已存在，触发数据刷新
    if (Get.isRegistered<HomePageController>()) {
      final homeController = Get.find<HomePageController>();
      // 立即设置加载状态
      homeController.isLoadingLocalCities.value = true;
      if (Get.isRegistered<MeetupStateController>()) {
        final meetupController = Get.find<MeetupStateController>();
        meetupController.isLoading.value = true;
        meetupController.loadState.value = LoadState.loading;
      }
      // 触发数据刷新
      homeController.onRouteResume();
    }

    Get.offAllNamed(AppRoutes.home);
  }

  /// 检查认证状态
  Future<bool> _checkAuthentication() async {
    log('🔒 检查认证状态...');

    final authController = Get.find<AuthStateController>();
    final isAuthenticated = authController.isAuthenticated.value;
    final currentToken = authController.currentToken.value;

    log('   isAuthenticated: $isAuthenticated');
    log('   currentToken: ${currentToken?.accessToken != null ? '${currentToken!.accessToken.substring(0, 20)}...' : 'null'}');
    log('   currentToken.isExpired: ${currentToken?.isExpired ?? 'N/A'}');

    if (!isAuthenticated || currentToken == null) {
      log('❌ 未认证或无 token，跳转登录页');
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // 检查 token 是否过期
    if (currentToken.isExpired) {
      log('❌ Token 已过期，跳转登录页');
      Get.toNamed(AppRoutes.login);
      return false;
    }

    return true;
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
    } else if (currentRoute == AppRoutes.conversations) {
      currentIndex.value = 1;
    } else if (currentRoute == AppRoutes.profile ||
        currentRoute == AppRoutes.profileEdit) {
      currentIndex.value = 2;
    } else if (currentRoute == AppRoutes.notifications) {
      currentIndex.value = 3;
    }
  }

  // ==================== 通知相关 ====================

  /// 设置 IM 未读数量监听器
  void _setupIMUnreadCountListener() {
    try {
      if (Get.isRegistered<ConversationListController>()) {
        final conversationController = Get.find<ConversationListController>();
        _imUnreadCountWorker = ever(conversationController.totalUnreadCount, (count) {
          log('💬 BottomNav: IM 未读数量更新为 $count');
          imUnreadCount.value = count;
        });
        imUnreadCount.value = conversationController.totalUnreadCount.value;
      }
    } catch (e) {
      log('⚠️ BottomNav: 设置 IM 未读数量监听器失败: $e');
    }
  }

  /// 设置未读数量监听器
  void _setupUnreadCountListener() {
    try {
      if (Get.isRegistered<NotificationStateController>()) {
        final notificationController = Get.find<NotificationStateController>();
        _unreadCountWorker = ever(notificationController.unreadCount, (count) {
          log('🔔 BottomNav: 未读数量更新为 $count');
          unreadCount.value = count;
        });
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

          unreadCount.value++;
          log('🔔 BottomNav: 未读数量 +1, 现在是 ${unreadCount.value}');

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
      final tokenService = TokenStorageService();
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        unreadCount.value = 0;
        return;
      }

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
}
