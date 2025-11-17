import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../auth/presentation/controllers/auth_state_controller.dart';
import '../../../interest/presentation/controllers/interest_state_controller.dart';
import '../../../skill/presentation/controllers/skill_state_controller.dart';
import '../../application/use_cases/favorite_city_use_cases.dart';
import '../../application/use_cases/user_use_cases.dart' as user_use_cases;
import '../../domain/entities/user.dart';

/// 用户状态控制器 (重构版 - DDD)
///
/// 职责:
/// - 管理UI状态
/// - 调用Use Cases
/// - 处理UI交互
class UserStateController extends GetxController {
  // Use Cases注入 - 基础用户操作
  final user_use_cases.GetUserProfileUseCase _getCurrentUserUseCase;
  final user_use_cases.GetUserUseCase _getUserUseCase;
  final user_use_cases.UpdateUserUseCase _updateUserUseCase;

  // Use Cases注入 - 收藏城市
  final AddFavoriteCityUseCase _addFavoriteCityUseCase;
  final RemoveFavoriteCityUseCase _removeFavoriteCityUseCase;
  final IsCityFavoritedUseCase _isCityFavoritedUseCase;
  final GetFavoriteCityIdsUseCase _getFavoriteCityIdsUseCase;
  final ToggleFavoriteCityUseCase _toggleFavoriteCityUseCase;

  UserStateController({
    required user_use_cases.GetUserProfileUseCase getCurrentUserUseCase,
    required user_use_cases.GetUserUseCase getUserUseCase,
    required user_use_cases.UpdateUserUseCase updateUserUseCase,
    required AddFavoriteCityUseCase addFavoriteCityUseCase,
    required RemoveFavoriteCityUseCase removeFavoriteCityUseCase,
    required IsCityFavoritedUseCase isCityFavoritedUseCase,
    required GetFavoriteCityIdsUseCase getFavoriteCityIdsUseCase,
    required ToggleFavoriteCityUseCase toggleFavoriteCityUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _getUserUseCase = getUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _addFavoriteCityUseCase = addFavoriteCityUseCase,
        _removeFavoriteCityUseCase = removeFavoriteCityUseCase,
        _isCityFavoritedUseCase = isCityFavoritedUseCase,
        _getFavoriteCityIdsUseCase = getFavoriteCityIdsUseCase,
        _toggleFavoriteCityUseCase = toggleFavoriteCityUseCase;

  // 状态
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 收藏城市状态
  final RxSet<String> favoriteCityIds = <String>{}.obs;

  // 编辑模式状态 (从 UserProfileController 合并)
  final RxBool isEditMode = false.obs;

  // 登录状态变化通知 (用于监听)
  final RxBool loginStateChanged = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 延迟初始化，等待 AuthStateController 准备好
    Future.microtask(() => _initializeIfLoggedIn());

    // 监听登录状态变化
    _setupAuthStateListener();
  }

  /// 设置认证状态监听器
  void _setupAuthStateListener() {
    try {
      final authController = Get.find<AuthStateController>();

      // 监听认证状态变化
      ever(authController.isAuthenticated, (isAuthenticated) {
        print('🔔 UserStateController: 认证状态变化 -> $isAuthenticated');

        if (isAuthenticated) {
          // 登录成功，加载用户数据
          print('✅ 用户已登录，加载用户数据...');
          loadCurrentUser();
          loadFavoriteCityIds();
        } else {
          // 退出登录，清除用户数据
          print('⚠️ 用户已退出，清除用户数据');
          currentUser.value = null;
          favoriteCityIds.clear();
        }
      });
    } catch (e) {
      print('⚠️ AuthStateController 未就绪，无法设置监听器');
    }
  }

  /// 如果用户已登录，则初始化数据
  void _initializeIfLoggedIn() {
    try {
      final authController = Get.find<AuthStateController>();
      if (authController.isAuthenticated.value) {
        // ❌ 不在这里自动加载任何需要 API 请求的数据
        // 避免 token 过期时发送 401 请求并触发全局跳转登录
        // 由各个页面根据需要手动调用：
        // - loadCurrentUser() - 加载用户信息
        // - loadFavoriteCityIds() - 加载收藏列表
      }
    } catch (e) {
      // AuthStateController 未初始化，跳过
      print('⚠️ AuthStateController 未就绪，跳过用户数据加载');
    }
  }

  /// 加载当前用户信息
  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _getCurrentUserUseCase(const NoParams());

    result.fold(
      onSuccess: (user) {
        currentUser.value = user;
        // 触发登录状态变化通知
        loginStateChanged.toggle();
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;

        // 如果是未授权错误，清除用户数据并静默处理
        if (exception is UnauthorizedException) {
          print('⚠️ 加载用户数据失败: Token 无效或过期');
          print('   清除用户状态...');
          currentUser.value = null; // 清除无效的用户数据
          favoriteCityIds.clear();
          loginStateChanged.toggle();
        } else {
          // 其他错误显示提示
          _handleException(exception, silent: false);
        }
      },
    );

    isLoading.value = false;
  }

  /// 加载用户资料 (从 UserProfileController 合并的别名方法)
  Future<void> loadUserProfile() => loadCurrentUser();

  /// 切换编辑模式 (从 UserProfileController 合并)
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  /// 更新用户信息
  Future<bool> updateUser(Map<String, dynamic> updates) async {
    final user = currentUser.value;
    if (user == null) {
      errorMessage.value = '用户未登录';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _updateUserUseCase(user_use_cases.UpdateUserParams(
      userId: user.id,
      updates: updates,
    ));

    isLoading.value = false;

    return result.fold(
      onSuccess: (updatedUser) {
        currentUser.value = updatedUser;
        _showSnackbar('成功', '用户信息已更新');
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        _handleException(exception);
        return false;
      },
    );
  }

  /// 刷新用户信息
  @override
  Future<void> refresh() => loadCurrentUser();

  /// 按ID获取用户信息（用于查看其他用户资料）
  Future<User?> getUserById(String userId) async {
    if (userId.isEmpty) {
      return null;
    }

    final result =
        await _getUserUseCase(user_use_cases.GetUserParams(userId: userId));

    return result.fold(
      onSuccess: (user) => user,
      onFailure: (exception) {
        _handleException(exception, silent: true);
        return null;
      },
    );
  }

  /// 清除用户状态
  void clearUser() {
    currentUser.value = null;
    errorMessage.value = '';
    favoriteCityIds.clear();
    isEditMode.value = false;
    // 触发登录状态变化通知
    loginStateChanged.toggle();
  }

  // ==================== 收藏城市相关方法 ====================

  /// 加载用户收藏的城市ID列表
  Future<void> loadFavoriteCityIds() async {
    final result = await _getFavoriteCityIdsUseCase(const NoParams());

    result.fold(
      onSuccess: (ids) {
        favoriteCityIds.clear();
        favoriteCityIds.addAll(ids);
      },
      onFailure: (exception) {
        print('加载收藏列表失败: ${exception.message}');
      },
    );
  }

  /// 检查城市是否已收藏
  Future<bool> isCityFavorited(String cityId) async {
    // 先从本地缓存检查
    if (favoriteCityIds.contains(cityId)) {
      return true;
    }

    // 从服务器检查
    final result = await _isCityFavoritedUseCase(IsCityFavoritedParams(cityId));

    return result.fold(
      onSuccess: (isFavorited) {
        if (isFavorited) {
          favoriteCityIds.add(cityId);
        }
        return isFavorited;
      },
      onFailure: (_) => false,
    );
  }

  /// 添加收藏城市
  Future<bool> addFavoriteCity(String cityId) async {
    final result = await _addFavoriteCityUseCase(AddFavoriteCityParams(cityId));

    return result.fold(
      onSuccess: (success) {
        if (success) {
          favoriteCityIds.add(cityId);
          _showSnackbar('成功', '已添加到收藏');
        }
        return success;
      },
      onFailure: (exception) {
        _handleException(exception);
        return false;
      },
    );
  }

  /// 移除收藏城市
  Future<bool> removeFavoriteCity(String cityId) async {
    final result =
        await _removeFavoriteCityUseCase(RemoveFavoriteCityParams(cityId));

    return result.fold(
      onSuccess: (success) {
        if (success) {
          favoriteCityIds.remove(cityId);
          _showSnackbar('成功', '已取消收藏');
        }
        return success;
      },
      onFailure: (exception) {
        _handleException(exception);
        return false;
      },
    );
  }

  /// 切换收藏状态
  Future<bool> toggleFavoriteCity(String cityId) async {
    final result =
        await _toggleFavoriteCityUseCase(ToggleFavoriteCityParams(cityId));

    return result.fold(
      onSuccess: (success) {
        if (success) {
          if (favoriteCityIds.contains(cityId)) {
            favoriteCityIds.remove(cityId);
          } else {
            favoriteCityIds.add(cityId);
          }
        }
        return success;
      },
      onFailure: (exception) {
        _handleException(exception);
        return false;
      },
    );
  }

  /// 统一异常处理
  void _handleException(DomainException exception, {bool silent = false}) {
    String title = '错误';
    String message = exception.message;

    switch (exception) {
      case UnauthorizedException():
        title = '未授权';
        // 可以在这里触发跳转到登录页
        break;
      case NetworkException():
        title = '网络错误';
        break;
      case ServerException():
        title = '服务器错误';
        break;
      case ValidationException():
        title = '验证失败';
        break;
      default:
        title = '未知错误';
    }

    // 如果是静默模式，或者 Get context 还不可用，则不显示 Snackbar
    if (!silent) {
      try {
        _showSnackbar(title, message);
      } catch (e) {
        print('⚠️ 显示 Snackbar 失败: $e');
        print('   错误: $title - $message');
      }
    }
  }

  // ==================== 技能和兴趣管理方法 ====================

  /// 移除用户技能
  /// 这是一个便捷方法,委托给 SkillStateController
  Future<bool> removeSkill(String skillId) async {
    final user = currentUser.value;
    if (user == null) {
      errorMessage.value = '用户未登录';
      return false;
    }

    try {
      final skillController = Get.find<SkillStateController>();
      final success = await skillController.removeUserSkill(user.id, skillId);

      if (success) {
        // 刷新用户信息以更新技能列表
        await loadCurrentUser();
      }

      return success;
    } catch (e) {
      errorMessage.value = '移除技能失败: $e';
      Get.snackbar('错误', '移除技能失败');
      return false;
    }
  }

  /// 移除用户兴趣
  /// 这是一个便捷方法,委托给 InterestStateController
  Future<bool> removeInterest(String interestId) async {
    final user = currentUser.value;
    if (user == null) {
      errorMessage.value = '用户未登录';
      return false;
    }

    try {
      final interestController = Get.find<InterestStateController>();
      final success =
          await interestController.removeUserInterest(user.id, interestId);

      if (success) {
        // 刷新用户信息以更新兴趣列表
        await loadCurrentUser();
      }

      return success;
    } catch (e) {
      errorMessage.value = '移除兴趣失败: $e';
      Get.snackbar('错误', '移除兴趣失败');
      return false;
    }
  }

  // Getters - 业务逻辑委托给领域实体
  bool get isLoggedIn => currentUser.value != null;
  bool get hasCompletedProfile =>
      currentUser.value?.hasCompletedProfile ?? false;
  bool get isActiveNomad => currentUser.value?.isActiveNomad ?? false;
  int get experienceLevel => currentUser.value?.experienceLevel ?? 1;

  @override
  void onClose() {
    // 清空所有响应式变量
    currentUser.value = null;
    isLoading.value = false;
    errorMessage.value = '';

    // 清空收藏城市状态
    favoriteCityIds.clear();

    // 重置编辑模式状态
    isEditMode.value = false;
    loginStateChanged.value = false;

    super.onClose();
  }

  /// Safely displays a snackbar only after the overlay/navigator is ready.
  void _showSnackbar(String title, String message) {
    if (_canAccessOverlay) {
      Get.snackbar(title, message);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_canAccessOverlay) {
        Get.snackbar(title, message);
      } else {
        print('⚠️ 无法显示 Snackbar: Overlay 未就绪');
        print('   信息: $title - $message');
      }
    });
  }

  bool get _canAccessOverlay {
    if (Get.overlayContext != null) {
      return true;
    }

    final navigatorState = Get.key.currentState;
    return navigatorState?.overlay != null;
  }
}
