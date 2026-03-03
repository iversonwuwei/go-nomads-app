import 'dart:async';

import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:get/get.dart';

/// MemberDetailPage 控制器
class MemberDetailPageController extends GetxController {
  final models.User? initialUser;
  final String? userId;

  MemberDetailPageController({
    this.initialUser,
    this.userId,
  });

  late final UserStateController _userController;
  late final AuthStateController _authController;

  final Rxn<models.User> user = Rxn<models.User>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  /// 判断当前显示的是否是登录用户自己
  bool get isCurrentUser {
    final currentUserId = _authController.currentUser.value?.id;
    final displayUserId = user.value?.id ?? userId;
    return currentUserId != null && displayUserId != null && currentUserId == displayUserId;
  }

  @override
  void onInit() {
    super.onInit();
    _userController = Get.find<UserStateController>();
    _authController = Get.find<AuthStateController>();
    user.value = initialUser;
    _setupDataChangeListeners();
    loadUserDetails();
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    super.onClose();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('user', _handleDataChanged);
    // 也监听 user_profile 事件
    DataEventBus.instance.on('user_profile', _handleDataChanged);
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前用户的变更
    final targetUserId = userId ?? initialUser?.id;
    if (event.entityId != targetUserId) {
      return;
    }

    switch (event.changeType) {
      case DataChangeType.updated:
        // 用户数据更新，重新加载详情
        loadUserDetails();
        break;
      case DataChangeType.deleted:
        // 用户被删除
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        loadUserDetails();
        break;
      case DataChangeType.created:
        // 新建用户通常不影响详情页
        break;
    }
  }

  /// 从后端获取完整的用户信息
  Future<void> loadUserDetails() async {
    final targetUserId = userId ?? initialUser?.id;
    if (targetUserId == null) {
      isLoading.value = false;
      errorMessage.value = '无法获取用户信息';
      return;
    }

    try {
      final loadedUser = await _userController.getUserById(targetUserId);
      if (loadedUser != null) {
        user.value = loadedUser;
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载用户信息失败';
    }
  }

  /// 重试加载
  void retry() {
    isLoading.value = true;
    errorMessage.value = null;
    loadUserDetails();
  }
}
