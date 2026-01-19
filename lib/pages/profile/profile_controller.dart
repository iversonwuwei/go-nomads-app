import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Profile 页面控制器
///
/// 负责协调用户、会员、旅行计划等状态
class ProfileController extends GetxController {
  // ==================== 依赖控制器 ====================

  UserStateController get userController => Get.find<UserStateController>();
  AuthStateController get authController => Get.find<AuthStateController>();

  MembershipStateController? get membershipController {
    if (Get.isRegistered<MembershipStateController>()) {
      return Get.find<MembershipStateController>();
    }
    return null;
  }

  AiStateController? get aiController {
    if (Get.isRegistered<AiStateController>()) {
      return Get.find<AiStateController>();
    }
    return null;
  }

  // ==================== 可观察状态 ====================

  /// 页面是否正在加载
  final _isPageLoading = true.obs;

  /// 是否已初始化
  final _isInitialized = false.obs;

  // ==================== Getters ====================

  /// 当前用户
  User? get currentUser => userController.currentUser.value;
  Rx<User?> get currentUserRx => userController.currentUser;

  /// 用户是否已登录
  bool get isLoggedIn => userController.isLoggedIn;

  /// 是否正在加载用户数据
  bool get isLoadingUser => userController.isLoading.value;
  RxBool get isLoadingUserRx => userController.isLoading;

  /// 页面是否正在加载
  bool get isPageLoading => _isPageLoading.value;
  RxBool get isPageLoadingRx => _isPageLoading;

  /// 是否已认证
  bool get isAuthenticated => authController.isAuthenticated.value;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    log('🎬 ProfileController 初始化');
  }

  @override
  void onReady() {
    super.onReady();
    // 页面准备好后加载数据
    loadProfileData();
  }

  // ==================== 业务方法 ====================

  /// 加载 Profile 页面数据
  Future<void> loadProfileData() async {
    log('📦 ProfileController: 开始加载数据');
    _isPageLoading.value = true;

    try {
      // 检查认证状态
      if (!isAuthenticated) {
        log('⚠️ 用户未登录，跳转到登录页');
        AppToast.info('Please login to view your profile', title: 'Login Required');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // 加载用户数据
      await userController.loadUserProfile();

      if (currentUser == null && userController.errorMessage.value.isNotEmpty) {
        log('⚠️ 加载用户数据失败，跳转到登录页');
        AppToast.info('Please login again', title: 'Session Expired');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // 并行加载其他数据
      await Future.wait([
        _loadNomadStats(),
        _loadFavoriteCityIds(),
        _loadTravelPlans(),
        _ensureMembershipLoaded(),
      ]);

      // 后端已经在 /users/me/stats 接口中返回 meetupsJoined
      // 无需前端单独获取

      _isInitialized.value = true;
      log('✅ ProfileController: 数据加载完成');
    } catch (e) {
      log('❌ ProfileController: 加载数据失败: $e');
    } finally {
      _isPageLoading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    log('🔄 ProfileController: 刷新数据');
    await loadProfileData();
  }

  /// 路由恢复时调用 - 强制刷新关键数据
  ///
  /// 当用户从其他页面返回 Profile 时调用此方法，
  /// 确保收藏、统计等数据与服务器同步
  Future<void> onRouteResume() async {
    log('🔄 ProfileController: 路由恢复，同步数据');

    // 只有在已初始化的情况下才执行刷新
    if (!_isInitialized.value) {
      log('⚠️ ProfileController 未初始化，跳过 onRouteResume');
      return;
    }

    // 并行刷新可能变化的数据（强制刷新）
    await Future.wait([
      _refreshNomadStats(),
      _refreshFavoriteCities(),
    ]);

    // 后端已经在 /users/me/stats 接口中返回 meetupsJoined
    // 无需前端单独获取

    log('✅ ProfileController: 数据同步完成');
  }

  /// 强制刷新 Nomad 统计数据
  Future<void> _refreshNomadStats() async {
    try {
      await userController.loadNomadStats(forceRefresh: true);
    } catch (e) {
      log('⚠️ 刷新 Nomad 统计失败: $e');
    }
  }

  /// 强制刷新收藏城市数据
  Future<void> _refreshFavoriteCities() async {
    try {
      await userController.loadFavoriteCityIds(forceRefresh: true);
    } catch (e) {
      log('⚠️ 刷新收藏城市失败: $e');
    }
  }

  /// 加载 Nomad 统计
  Future<void> _loadNomadStats() async {
    try {
      await userController.loadNomadStats();
    } catch (e) {
      log('⚠️ 加载 Nomad 统计失败: $e');
    }
  }

  /// 加载收藏城市ID列表
  Future<void> _loadFavoriteCityIds() async {
    try {
      await userController.loadFavoriteCityIds();
    } catch (e) {
      log('⚠️ 加载收藏城市失败: $e');
    }
  }

  /// 加载旅行计划
  Future<void> _loadTravelPlans() async {
    try {
      await aiController?.loadUserTravelPlans(page: 1, pageSize: 1);
    } catch (e) {
      log('⚠️ 加载旅行计划失败: $e');
    }
  }

  /// 确保会员信息已加载
  Future<void> _ensureMembershipLoaded() async {
    try {
      // 如果会员控制器存在但没有数据，尝试加载
      final controller = membershipController;
      if (controller != null && controller.membership == null) {
        log('📦 ProfileController: 加载会员信息');
        await controller.loadMembership();
      }
    } catch (e) {
      log('⚠️ 加载会员信息失败: $e');
    }
  }

  /// 处理退出登录
  Future<void> logout() async {
    try {
      log('🚪 开始执行退出登录...');
      log('   当前用户: ${currentUser?.name ?? "Unknown"}');

      // 执行登出
      await authController.logout();

      // 清除用户数据
      userController.clearUser();

      // 清除会员数据
      membershipController?.clearMembership();

      // 清除通知数据
      if (Get.isRegistered<NotificationStateController>()) {
        Get.find<NotificationStateController>().clearNotifications();
      }

      log('✅ 用户状态已清除');

      AppToast.success(
        'You have been logged out successfully',
        title: 'Logout Success',
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('❌ 退出登录失败: $e');
      AppToast.error(
        'An error occurred during logout',
        title: 'Error',
      );
    }
  }
}
