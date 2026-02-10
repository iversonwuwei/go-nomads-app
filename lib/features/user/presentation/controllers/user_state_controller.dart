import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im.dart';
import 'package:go_nomads_app/features/interest/presentation/controllers/interest_state_controller.dart';
import 'package:go_nomads_app/features/skill/presentation/controllers/skill_state_controller.dart';
import 'package:go_nomads_app/features/travel_history/presentation/controllers/travel_history_controller.dart';
import 'package:go_nomads_app/features/user/application/use_cases/favorite_city_use_cases.dart';
import 'package:go_nomads_app/features/user/application/use_cases/user_use_cases.dart' as user_use_cases;
import 'package:go_nomads_app/features/user/domain/entities/nomad_stats.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 用户状态控制器 V2 (优化版)
///
/// 改进点：
/// 1. 使用 DataEventBus 通知其他组件用户数据的变更
/// 2. 自动响应其他组件的数据变更事件
/// 3. 智能缓存策略
/// 4. 保留所有原有功能
class UserStateController extends GetxController {
  // ==================== Dependencies ====================
  final user_use_cases.GetUserProfileUseCase _getCurrentUserUseCase;
  final user_use_cases.GetUserUseCase _getUserUseCase;
  final user_use_cases.UpdateUserUseCase _updateUserUseCase;
  final AddFavoriteCityUseCase _addFavoriteCityUseCase;
  final RemoveFavoriteCityUseCase _removeFavoriteCityUseCase;
  final IsCityFavoritedUseCase _isCityFavoritedUseCase;
  final GetFavoriteCityIdsUseCase _getFavoriteCityIdsUseCase;
  final ToggleFavoriteCityUseCase _toggleFavoriteCityUseCase;
  final user_use_cases.GetCurrentUserStatsUseCase _getCurrentUserStatsUseCase;

  UserStateController({
    required user_use_cases.GetUserProfileUseCase getCurrentUserUseCase,
    required user_use_cases.GetUserUseCase getUserUseCase,
    required user_use_cases.UpdateUserUseCase updateUserUseCase,
    required AddFavoriteCityUseCase addFavoriteCityUseCase,
    required RemoveFavoriteCityUseCase removeFavoriteCityUseCase,
    required IsCityFavoritedUseCase isCityFavoritedUseCase,
    required GetFavoriteCityIdsUseCase getFavoriteCityIdsUseCase,
    required ToggleFavoriteCityUseCase toggleFavoriteCityUseCase,
    required user_use_cases.GetCurrentUserStatsUseCase getCurrentUserStatsUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _getUserUseCase = getUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _addFavoriteCityUseCase = addFavoriteCityUseCase,
        _removeFavoriteCityUseCase = removeFavoriteCityUseCase,
        _isCityFavoritedUseCase = isCityFavoritedUseCase,
        _getFavoriteCityIdsUseCase = getFavoriteCityIdsUseCase,
        _toggleFavoriteCityUseCase = toggleFavoriteCityUseCase,
        _getCurrentUserStatsUseCase = getCurrentUserStatsUseCase;

  // ==================== 状态 ====================
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<String> favoriteCityIds = <String>{}.obs;
  final Rx<NomadStats?> nomadStats = Rx<NomadStats?>(null);
  final RxBool isLoadingStats = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool loginStateChanged = false.obs;

  // 缓存控制
  DateTime? _lastUserLoadTime;
  DateTime? _lastStatsLoadTime;
  DateTime? _lastFavoritesLoadTime;
  static const _cacheDuration = Duration(minutes: 5);

  // ==================== Getters ====================
  bool get isLoggedIn => currentUser.value != null;
  bool get hasCompletedProfile => currentUser.value?.hasCompletedProfile ?? false;
  bool get isActiveNomad => currentUser.value?.isActiveNomad ?? false;
  int get experienceLevel => currentUser.value?.experienceLevel ?? 1;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    log('🎬 UserStateController 初始化...');
    Future.microtask(() => _initializeIfLoggedIn());
    _setupAuthStateListener();
    _setupDataChangeListeners();
  }

  @override
  void onClose() {
    log('👋 UserStateController 关闭');
    currentUser.value = null;
    isLoading.value = false;
    errorMessage.value = '';
    favoriteCityIds.clear();
    nomadStats.value = null;
    isLoadingStats.value = false;
    isEditMode.value = false;
    loginStateChanged.value = false;
    super.onClose();
  }

  // ==================== 初始化方法 ====================

  void _setupAuthStateListener() {
    try {
      final authController = Get.find<AuthStateController>();
      ever(authController.isAuthenticated, (isAuthenticated) async {
        log('🔔 UserStateController: 认证状态变化 -> $isAuthenticated');
        if (isAuthenticated) {
          log('✅ 用户已登录，加载用户数据...');
          loadCurrentUser();
          loadFavoriteCityIds();
          loadNomadStats();
          _syncTravelHistory();

          // 自动登录腾讯云IM
          _loginTencentIM();
        } else {
          log('⚠️ 用户已退出，清除用户数据');
          _clearAllData();

          // 退出腾讯云IM
          _logoutTencentIM();
        }
      });
    } catch (e) {
      log('⚠️ AuthStateController 未就绪，无法设置监听器');
    }
  }

  /// 登录腾讯云IM
  Future<void> _loginTencentIM() async {
    try {
      if (!Get.isRegistered<TencentIMService>()) {
        log('⚠️ TencentIMService 未注册，跳过IM登录');
        return;
      }

      final imService = Get.find<TencentIMService>();
      if (imService.isLoggedIn) {
        log('ℹ️ 腾讯云IM已登录，跳过');
        return;
      }

      final authController = Get.find<AuthStateController>();
      final user = authController.currentUser.value;
      if (user == null) {
        log('⚠️ 当前用户为空，跳过IM登录');
        return;
      }

      log('🔐 认证状态变化后自动登录腾讯云IM...');

      // 先通过后端API确保当前用户存在于IM系统
      final imApiService = TencentIMApiService();
      await imApiService.ensureUserExists(
        nickname: user.name,
        avatarUrl: user.avatar,
      );

      // 然后登录IM
      await imService.login(user.id);
      log('✅ 腾讯云IM登录成功');
    } catch (e) {
      log('❌ 腾讯云IM登录失败: $e');
    }
  }

  /// 退出腾讯云IM
  Future<void> _logoutTencentIM() async {
    try {
      if (!Get.isRegistered<TencentIMService>()) return;

      final imService = Get.find<TencentIMService>();
      if (imService.isLoggedIn) {
        await imService.logout();
        log('✅ 腾讯云IM已退出');
      }
    } catch (e) {
      log('❌ 腾讯云IM退出失败: $e');
    }
  }

  void _setupDataChangeListeners() {
    // 监听用户相关数据变更
    DataEventBus.instance.on('user', _handleUserDataChanged);
    DataEventBus.instance.on('user_profile', _handleUserDataChanged);
    DataEventBus.instance.on('favorite_city', _handleFavoriteChanged);
    // 同时监听 city_favorite 事件（由城市详情页发送）
    DataEventBus.instance.on('city_favorite', _handleFavoriteChanged);
    DataEventBus.instance.on('skill', _handleSkillInterestChanged);
    DataEventBus.instance.on('interest', _handleSkillInterestChanged);
    // 监听 meetup 变更（影响用户统计数据）
    DataEventBus.instance.on('meetup', _handleMeetupChanged);
    // 监听 meetup RSVP 变更（加入/退出活动）
    DataEventBus.instance.on('meetup_rsvp', _handleMeetupRsvpChanged);
    // 监听旅行历史变更（影响 countries/cities/days/trips 统计）
    DataEventBus.instance.on('travel_history', _handleTravelHistoryChanged);
  }

  void _handleUserDataChanged(DataChangedEvent event) {
    log('🔔 收到用户数据变更通知: ${event.changeType}');
    if (event.entityId == currentUser.value?.id || event.entityId == null) {
      _invalidateUserCache();
      loadCurrentUser(forceRefresh: true);
    }
  }

  void _handleFavoriteChanged(DataChangedEvent event) {
    log('🔔 收到收藏数据变更通知: ${event.changeType}');
    _invalidateFavoritesCache();
    loadFavoriteCityIds(forceRefresh: true);
    // 收藏变更也会影响统计数据
    _invalidateStatsCache();
    loadNomadStats(forceRefresh: true);
  }

  void _handleSkillInterestChanged(DataChangedEvent event) {
    log('🔔 收到技能/兴趣变更通知');
    // 技能或兴趣变更后刷新用户数据
    _invalidateUserCache();
    loadCurrentUser(forceRefresh: true);
  }

  void _handleMeetupChanged(DataChangedEvent event) {
    log('🔔 收到 Meetup 变更通知: ${event.changeType}');
    // Meetup 创建/删除会影响用户统计数据
    if (event.changeType == DataChangeType.created || event.changeType == DataChangeType.deleted) {
      _invalidateStatsCache();
      // 立即重新加载统计数据
      loadNomadStats(forceRefresh: true);
    }
  }

  void _handleMeetupRsvpChanged(DataChangedEvent event) {
    log('🔔 收到 Meetup RSVP 变更通知: ${event.changeType}');
    // 加入/退出活动会影响用户统计数据
    _invalidateStatsCache();
    // 立即重新加载统计数据
    loadNomadStats(forceRefresh: true);
  }

  void _handleTravelHistoryChanged(DataChangedEvent event) {
    log('🔔 收到旅行历史变更通知: ${event.changeType}');
    // 旅行历史变更会影响 countries/cities/days/trips 统计
    _invalidateStatsCache();
    loadNomadStats(forceRefresh: true);
  }

  void _invalidateStatsCache() {
    _lastStatsLoadTime = null;
  }

  void _initializeIfLoggedIn() {
    try {
      final authController = Get.find<AuthStateController>();
      if (authController.isAuthenticated.value) {
        // 延迟加载，避免 token 过期时立即发送请求
      }
    } catch (e) {
      log('⚠️ AuthStateController 未就绪，跳过用户数据加载');
    }
  }

  Future<void> _syncTravelHistory() async {
    try {
      if (Get.isRegistered<TravelHistoryController>()) {
        final travelHistoryController = Get.find<TravelHistoryController>();
        await travelHistoryController.syncWithBackend();
        log('✅ 旅行历史数据同步完成');
      }
    } catch (e) {
      log('⚠️ 同步旅行历史失败: $e');
    }
  }

  // ==================== 缓存控制 ====================

  bool _isUserCacheValid() {
    if (_lastUserLoadTime == null) return false;
    return DateTime.now().difference(_lastUserLoadTime!) < _cacheDuration;
  }

  bool _isStatsCacheValid() {
    if (_lastStatsLoadTime == null) return false;
    return DateTime.now().difference(_lastStatsLoadTime!) < _cacheDuration;
  }

  bool _isFavoritesCacheValid() {
    if (_lastFavoritesLoadTime == null) return false;
    return DateTime.now().difference(_lastFavoritesLoadTime!) < _cacheDuration;
  }

  void _invalidateUserCache() {
    _lastUserLoadTime = null;
  }

  void _invalidateFavoritesCache() {
    _lastFavoritesLoadTime = null;
  }

  void _clearAllData() {
    currentUser.value = null;
    favoriteCityIds.clear();
    nomadStats.value = null;
    _lastUserLoadTime = null;
    _lastStatsLoadTime = null;
    _lastFavoritesLoadTime = null;
    loginStateChanged.toggle();
  }

  // ==================== 用户数据加载 ====================

  /// 加载当前用户信息
  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    // 检查缓存
    if (!forceRefresh && _isUserCacheValid() && currentUser.value != null) {
      log('📦 使用缓存的用户数据');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _getCurrentUserUseCase(const NoParams());

    result.fold(
      onSuccess: (user) {
        currentUser.value = user;
        _lastUserLoadTime = DateTime.now();
        loginStateChanged.toggle();
        log('✅ 用户数据加载成功: ${user.name}');
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        if (exception is UnauthorizedException) {
          log('⚠️ 加载用户数据失败: Token 无效或过期');
          _clearAllData();
          _handleException(exception, silent: true);
        } else {
          _handleException(exception, silent: false);
        }
      },
    );

    isLoading.value = false;
  }

  /// 加载用户资料 (别名方法)
  Future<void> loadUserProfile() => loadCurrentUser();

  /// 刷新用户信息
  @override
  Future<void> refresh() => loadCurrentUser(forceRefresh: true);

  /// 加载用户统计数据
  Future<void> loadNomadStats({bool forceRefresh = false}) async {
    if (!forceRefresh && _isStatsCacheValid() && nomadStats.value != null) {
      log('📦 使用缓存的统计数据');
      return;
    }

    isLoadingStats.value = true;
    log('📊 开始加载用户统计数据 (forceRefresh: $forceRefresh)');

    final result = await _getCurrentUserStatsUseCase(const NoParams());

    result.fold(
      onSuccess: (stats) {
        nomadStats.value = stats;
        _lastStatsLoadTime = DateTime.now();
        log('✅ 成功加载用户统计数据: countries=${stats.countriesVisited}, cities=${stats.citiesLived}, meetups=${stats.meetupsCreated}, favorites=${stats.favoriteCitiesCount}');
      },
      onFailure: (exception) {
        log('⚠️ 加载用户统计数据失败: ${exception.message}');
        if (currentUser.value != null) {
          nomadStats.value = NomadStats.empty(currentUser.value!.id);
        }
      },
    );

    isLoadingStats.value = false;
  }

  // ==================== 用户操作 ====================

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  /// 只更新头像URL
  Future<void> updateAvatarOnly(String avatarUrl) async {
    final user = currentUser.value;
    if (user == null) return;

    await _updateUserUseCase(user_use_cases.UpdateUserParams(
      userId: user.id,
      updates: {'avatarUrl': avatarUrl},
    ));

    currentUser.value = user.copyWith(avatarUrl: avatarUrl);

    // 通知其他组件
    _notifyUserChanged();
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
        _lastUserLoadTime = DateTime.now();
        _showSnackbar('成功', '用户信息已更新');

        // 通知其他组件
        _notifyUserChanged();

        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        _handleException(exception);
        return false;
      },
    );
  }

  /// 按ID获取用户信息
  Future<User?> getUserById(String userId) async {
    if (userId.isEmpty) return null;

    final result = await _getUserUseCase(user_use_cases.GetUserParams(userId: userId));

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
    _clearAllData();
    isEditMode.value = false;
  }

  // ==================== 收藏城市 ====================

  /// 加载用户收藏的城市ID列表
  Future<void> loadFavoriteCityIds({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFavoritesCacheValid() && favoriteCityIds.isNotEmpty) {
      log('📦 使用缓存的收藏城市数据');
      return;
    }

    final result = await _getFavoriteCityIdsUseCase(const NoParams());

    result.fold(
      onSuccess: (ids) {
        favoriteCityIds.clear();
        favoriteCityIds.addAll(ids);
        _lastFavoritesLoadTime = DateTime.now();
        log('✅ 收藏城市加载成功: ${ids.length} 个');
      },
      onFailure: (exception) {
        log('加载收藏列表失败: ${exception.message}');
      },
    );
  }

  /// 检查城市是否已收藏
  Future<bool> isCityFavorited(String cityId) async {
    if (favoriteCityIds.contains(cityId)) {
      return true;
    }

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

          // 通知其他组件
          _notifyFavoriteChanged(cityId, true);
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
    final result = await _removeFavoriteCityUseCase(RemoveFavoriteCityParams(cityId));

    return result.fold(
      onSuccess: (success) {
        if (success) {
          favoriteCityIds.remove(cityId);
          _showSnackbar('成功', '已取消收藏');

          // 通知其他组件
          _notifyFavoriteChanged(cityId, false);
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
    final result = await _toggleFavoriteCityUseCase(ToggleFavoriteCityParams(cityId));

    return result.fold(
      onSuccess: (success) {
        if (success) {
          final wasAdded = !favoriteCityIds.contains(cityId);
          if (wasAdded) {
            favoriteCityIds.add(cityId);
          } else {
            favoriteCityIds.remove(cityId);
          }

          // 通知其他组件
          _notifyFavoriteChanged(cityId, wasAdded);
        }
        return success;
      },
      onFailure: (exception) {
        _handleException(exception);
        return false;
      },
    );
  }

  // ==================== 技能和兴趣管理 ====================

  /// 移除用户技能（乐观更新）
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
        // 乐观更新：立即从本地状态移除，无需等待网络刷新
        final updatedSkills = user.skills.where((s) => s.id != skillId).toList();
        currentUser.value = user.copyWith(skills: updatedSkills);
        log('✅ 技能已从本地状态移除: $skillId');
      }

      return success;
    } catch (e) {
      errorMessage.value = '移除技能失败: $e';
      AppToast.error('移除技能失败');
      return false;
    }
  }

  /// 移除用户兴趣（乐观更新）
  Future<bool> removeInterest(String interestId) async {
    final user = currentUser.value;
    if (user == null) {
      errorMessage.value = '用户未登录';
      return false;
    }

    try {
      final interestController = Get.find<InterestStateController>();
      final success = await interestController.removeUserInterest(user.id, interestId);

      if (success) {
        // 乐观更新：立即从本地状态移除，无需等待网络刷新
        final updatedInterests = user.interests.where((i) => i.id != interestId).toList();
        currentUser.value = user.copyWith(interests: updatedInterests);
        log('✅ 兴趣已从本地状态移除: $interestId');
      }

      return success;
    } catch (e) {
      errorMessage.value = '移除兴趣失败: $e';
      AppToast.error('移除兴趣失败');
      return false;
    }
  }

  // ==================== 事件通知 ====================

  void _notifyUserChanged() {
    DataEventBus.instance.emit(DataChangedEvent(
      entityType: 'user',
      entityId: currentUser.value?.id,
      version: DateTime.now().millisecondsSinceEpoch,
      changeType: DataChangeType.updated,
    ));
  }

  void _notifyFavoriteChanged(String cityId, bool isAdded) {
    DataEventBus.instance.emit(DataChangedEvent(
      entityType: 'favorite_city',
      entityId: cityId,
      version: DateTime.now().millisecondsSinceEpoch,
      changeType: isAdded ? DataChangeType.created : DataChangeType.deleted,
    ));

    // 同时通知城市列表可能需要更新
    DataEventBus.instance.emit(DataChangedEvent(
      entityType: 'city',
      entityId: cityId,
      version: DateTime.now().millisecondsSinceEpoch,
      changeType: DataChangeType.updated,
    ));
  }

  // ==================== 异常处理 ====================

  void _handleException(DomainException exception, {bool silent = false}) {
    String title = '错误';
    String message = exception.message;

    switch (exception) {
      case UnauthorizedException():
        title = '未授权';
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

    if (!silent) {
      try {
        _showSnackbar(title, message);
      } catch (e) {
        log('⚠️ 显示 Snackbar 失败: $e');
        log('   错误: $title - $message');
      }
    }
  }

  void _showSnackbar(String title, String message) {
    if (title == '成功') {
      AppToast.success(message);
    } else {
      AppToast.error(message);
    }
  }
}
