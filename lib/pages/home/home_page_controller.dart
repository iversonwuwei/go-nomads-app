import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 首页控制器 - GetX 标准实现（支持 GetView）
/// 管理首页的所有状态和业务逻辑
/// 内部实现路由监听，从其他页面返回时自动刷新数据
class HomePageController extends GetxController with WidgetsBindingObserver implements RouteAware {
  // ==================== 依赖注入 ====================
  final ICityRepository _cityRepository = Get.find<ICityRepository>();
  final IMeetupRepository _meetupRepository = Get.find<IMeetupRepository>();

  // 延迟获取的控制器
  CityStateController get cityController => Get.find<CityStateController>();
  MeetupStateController get meetupController => Get.find<MeetupStateController>();
  UserStateController get userController => Get.find<UserStateController>();
  AuthStateController get authController => Get.find<AuthStateController>();
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  // ==================== UI 控制器 ====================
  final ScrollController scrollController = ScrollController();
  final GlobalKey citiesListKey = GlobalKey();

  // ==================== 路由监听 ====================
  PageRoute<dynamic>? _currentRoute;

  // ==================== 响应式状态 ====================
  /// 本地城市列表（独立于全局 CityStateController）
  final localCities = <City>[].obs;

  /// 是否正在加载城市数据
  final isLoadingLocalCities = true.obs;

  /// 是否已滚动到城市列表
  final hasScrolled = false.obs;

  /// 是否显示网格视图
  final isGridView = true.obs;

  /// 是否正在刷新
  final isRefreshing = false.obs;

  /// 首页活动列表（独立于全局 MeetupStateController）
  final homeMeetups = <Meetup>[].obs;

  /// 首页活动加载状态
  final homeMeetupsLoadState = LoadState.initial.obs;

  /// 首页活动错误信息
  final homeMeetupsErrorMessage = RxnString();

  /// 首页活动是否正在加载更多
  final isLoadingMoreHomeMeetups = false.obs;

  /// 首页活动是否还有更多
  final hasMoreHomeMeetups = true.obs;

  // ==================== 私有变量 ====================
  // 已移除 _cityListWorker，首页数据完全独立

  // SignalR 订阅
  StreamSubscription<Map<String, dynamic>>? _cityImageUpdatedSubscription;

  // EventBus 订阅：监听 meetup 数据变更
  StreamSubscription<DataChangedEvent>? _meetupDataChangedSubscription;

  // 首页可见性检查节流，避免 build 高频触发重复刷新
  DateTime? _lastHomeVisibleCheckAt;

  // 首页活动加载节流与并发控制
  DateTime? _lastHomeMeetupsLoadedAt;
  Completer<void>? _homeMeetupsLoadCompleter;
  int _homeMeetupsCurrentPage = 1;
  static const int _homeMeetupsPageSize = 20;

  // 首页 meetup 调试日志开关（仅 debug 下生效）
  bool _enableHomeMeetupsDebugLogs = true;

  // ==================== 生命周期 ====================
  @override
  void onInit() {
    super.onInit();
    log('🏠 HomePageController: onInit');

    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 设置 SignalR 监听器（城市图片更新）
    _setupSignalRListeners();
    _setupMeetupDataChangeListener();

    // ⭐ 首页使用独立的数据加载，不再监听全局 CityStateController
    // 这样首页和城市列表页面的数据完全独立，互不影响

    // ⭐ 延迟到下一帧再加载数据，避免在 build 期间触发 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _subscribeToRouteObserver();
    });
  }

  @override
  void onClose() {
    log('🏠 HomePageController: onClose');

    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);

    // 取消路由订阅
    _unsubscribeFromRouteObserver();

    // 取消 SignalR 订阅
    _cityImageUpdatedSubscription?.cancel();
    _cityImageUpdatedSubscription = null;

    // 取消 EventBus 订阅
    _meetupDataChangedSubscription?.cancel();
    _meetupDataChangedSubscription = null;

    // 注意：不要在 onClose() 中 dispose TextEditingController / ScrollController
    // GetX 的 onClose() 在 widget 卸载之前调用，此时 TextField 仍在使用 controller，
    // 手动 dispose 会导致 "TextEditingController was used after being disposed" 异常。
    // 这些控制器会随着 HomePageController 实例一起被 GC 回收。

    super.onClose();
  }

  /// 订阅路由观察者
  void _subscribeToRouteObserver() {
    final context = Get.context;
    if (context != null) {
      final route = ModalRoute.of(context);
      if (route is PageRoute && route != _currentRoute) {
        _currentRoute = route;
        appRouteObserver.subscribe(this, route);
        log('🏠 HomePageController: 已订阅路由观察者');
      }
    }
  }

  /// 取消路由订阅
  void _unsubscribeFromRouteObserver() {
    if (_currentRoute != null) {
      appRouteObserver.unsubscribe(this);
      _currentRoute = null;
      log('🏠 HomePageController: 已取消路由订阅');
    }
  }

  // ==================== SignalR 监听 ====================
  /// 设置 SignalR 监听器
  void _setupSignalRListeners() {
    final signalRService = SignalRService();

    // 监听城市图片更新事件
    _cityImageUpdatedSubscription = signalRService.cityImageUpdatedStream.listen((data) {
      log('🖼️ [HomePageController] 收到城市图片更新通知: $data');

      final cityId = data['cityId'] as String?;
      final success = data['success'] as bool? ?? false;

      if (cityId == null || !success) {
        return;
      }

      // 更新本地城市列表中的图片
      _updateCityImageFromSignalR(cityId, data);
    });

    log('✅ [HomePageController] SignalR 监听已设置 (城市图片更新)');
  }

  /// 监听 meetup EventBus 事件，确保首页活动列表自动同步最新数据
  void _setupMeetupDataChangeListener() {
    _meetupDataChangedSubscription?.cancel();
    _meetupDataChangedSubscription = DataEventBus.instance.on('meetup', (event) {
      log('🔔 [HomePageController] 收到 meetup 变更事件: ${event.changeType.name}, id=${event.entityId}');

      switch (event.changeType) {
        case DataChangeType.created:
        case DataChangeType.updated:
        case DataChangeType.deleted:
        case DataChangeType.invalidated:
          unawaited(loadHomeMeetups(forceRefresh: true));
          break;
      }
    });

    log('✅ [HomePageController] EventBus 监听已设置 (meetup 数据变更)');
  }

  /// 从 SignalR 数据更新城市图片
  void _updateCityImageFromSignalR(String cityId, Map<String, dynamic> data) {
    final index = localCities.indexWhere((c) => c.id == cityId);
    if (index == -1) {
      log('⚠️ [HomePageController] 未找到城市: $cityId');
      return;
    }

    final oldCity = localCities[index];

    // 提取图片 URL 并添加缓存破坏参数
    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
    String? portraitUrl = data['portraitImageUrl'] as String?;
    if (portraitUrl != null && portraitUrl.isNotEmpty) {
      portraitUrl = _appendCacheBuster(portraitUrl, cacheBuster);
    }

    List<String>? landscapeUrls;
    final landscapeImages = data['landscapeImageUrls'];
    if (landscapeImages is List && landscapeImages.isNotEmpty) {
      landscapeUrls = landscapeImages.cast<String>().map((url) => _appendCacheBuster(url, cacheBuster)).toList();
    }

    // 使用 copyWith 更新图片字段
    final updatedCity = oldCity.copyWith(
      portraitImageUrl: portraitUrl ?? oldCity.portraitImageUrl,
      landscapeImageUrls: landscapeUrls ?? oldCity.landscapeImageUrls,
      imageUrl: portraitUrl ?? oldCity.imageUrl,
    );

    localCities[index] = updatedCity;
    localCities.refresh(); // 强制触发 Obx 更新
    log('✅ [HomePageController] 城市图片已更新: ${updatedCity.name}, imageUrl: ${updatedCity.imageUrl}');
  }

  /// 添加缓存破坏参数到 URL
  String _appendCacheBuster(String url, String cacheBuster) {
    if (url.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$cacheBuster';
  }

  // ==================== RouteAware 实现 ====================
  @override
  void didPopNext() {
    // 从其他页面返回时重新加载数据
    log('🏠 HomePageController: didPopNext - 从其他页面返回');
    onRouteResume();
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 当应用回到前台时，仅在首页城市数据为空时刷新
    if (state == AppLifecycleState.resumed) {
      if (localCities.isEmpty) {
        log('📱 应用回到前台，首页城市数据为空，刷新数据');
        _loadHomeCitiesIndependent();
      } else {
        log('📱 应用回到前台，已有缓存数据，不刷新');
      }
    }
  }

  // ==================== 数据加载 ====================
  /// 初始化加载数据
  Future<void> _loadInitialData() async {
    log('🏠 首页初始化，独立加载城市和活动数据');

    try {
      // ⭐ 并行加载：首页城市数据 + 首页专属活动数据（互不依赖）
      await Future.wait([
        _loadHomeCitiesIndependent(),
        loadHomeMeetups(forceRefresh: false),
      ]);
    } catch (e) {
      log('⚠️ HomePageController: _loadInitialData 失败: $e');
    }
  }

  /// 独立加载首页城市数据（不影响全局 CityStateController）
  Future<void> _loadHomeCitiesIndependent() async {
    log('🏠 HomePageController: 独立加载首页城市数据');

    // 设置加载状态
    isLoadingLocalCities.value = true;

    try {
      // 直接使用 Repository 加载数据，不经过全局控制器
      final result = await _cityRepository.getCities(
        page: 1,
        pageSize: 20,
      );

      result.fold(
        onSuccess: (data) {
          localCities.assignAll(data);
          log('✅ 首页城市数据加载完成: ${data.length} 个城市');
        },
        onFailure: (error) {
          log('⚠️ 首页城市数据加载失败: ${error.message}');
        },
      );
    } catch (e) {
      log('⚠️ 首页城市数据加载异常: $e');
    } finally {
      isLoadingLocalCities.value = false;
    }
  }

  /// 加载首页城市数据（公开方法，供下拉刷新使用）
  Future<void> loadHomeCities() async {
    await _loadHomeCitiesIndependent();
  }

  /// 刷新首页 meetup 数据
  Future<void> refreshMeetups() async {
    await loadHomeMeetups(forceRefresh: true);
  }

  /// 设置首页 meetup 调试日志开关（仅 debug 下有效）
  void setHomeMeetupsDebugLogsEnabled(bool enabled) {
    _enableHomeMeetupsDebugLogs = enabled;
    _debugHomeMeetups('debug logs ${enabled ? 'enabled' : 'disabled'}');
  }

  void _debugHomeMeetups(String message) {
    if (kDebugMode && _enableHomeMeetupsDebugLogs) {
      log('🏠[HomeMeetups] $message');
    }
  }

  void _setHomeMeetupsState(LoadState nextState, {required String reason}) {
    final prev = homeMeetupsLoadState.value;
    if (prev != nextState) {
      _debugHomeMeetups('state ${prev.name} -> ${nextState.name} ($reason)');
    }
    homeMeetupsLoadState.value = nextState;
  }

  /// 首页活动加载（独立状态机）
  Future<void> loadHomeMeetups({required bool forceRefresh}) async {
    if (_homeMeetupsLoadCompleter != null && !_homeMeetupsLoadCompleter!.isCompleted) {
      _debugHomeMeetups('skip: load already in progress');
      return _homeMeetupsLoadCompleter!.future;
    }

    final now = DateTime.now();
    if (!forceRefresh &&
        _lastHomeMeetupsLoadedAt != null &&
        now.difference(_lastHomeMeetupsLoadedAt!) < const Duration(seconds: 45) &&
        homeMeetupsLoadState.value == LoadState.loaded &&
        homeMeetups.isNotEmpty) {
      _debugHomeMeetups('skip: use warm cache (${homeMeetups.length} items)');
      return;
    }

    _homeMeetupsLoadCompleter = Completer<void>();
    final hasCachedData = homeMeetups.isNotEmpty;
    final startedAt = DateTime.now();
    _debugHomeMeetups('start load: force=$forceRefresh, hasCached=$hasCachedData, page=1');

    _setHomeMeetupsState(
      hasCachedData ? LoadState.refreshing : LoadState.loading,
      reason: hasCachedData ? 'refresh with cached data' : 'initial load',
    );
    homeMeetupsErrorMessage.value = null;

    try {
      final data = await _meetupRepository
          .getMeetups(
            status: 'upcoming',
            page: 1,
            pageSize: _homeMeetupsPageSize,
          )
          .timeout(const Duration(seconds: 15));

      _homeMeetupsCurrentPage = 1;
      homeMeetups.assignAll(data);
      hasMoreHomeMeetups.value = data.length >= _homeMeetupsPageSize;
      _lastHomeMeetupsLoadedAt = DateTime.now();

      // 与共享控制器保持最小同步，确保 RSVP/详情等行为一致。
      meetupController.meetups.assignAll(data);

      _setHomeMeetupsState(
        data.isEmpty ? LoadState.empty : LoadState.loaded,
        reason: data.isEmpty ? 'load success with empty list' : 'load success',
      );
      _debugHomeMeetups(
        'load done: ${data.length} items, hasMore=${hasMoreHomeMeetups.value}, elapsed=${DateTime.now().difference(startedAt).inMilliseconds}ms',
      );
    } catch (e) {
      homeMeetupsErrorMessage.value = e.toString();
      _setHomeMeetupsState(
        hasCachedData ? LoadState.loaded : LoadState.error,
        reason: hasCachedData ? 'load failed but keep old data' : 'load failed without cache',
      );
      _debugHomeMeetups(
        'load failed: $e, elapsed=${DateTime.now().difference(startedAt).inMilliseconds}ms',
      );
    } finally {
      _homeMeetupsLoadCompleter?.complete();
    }
  }

  /// 加载更多首页活动
  Future<void> loadMoreHomeMeetups() async {
    if (isLoadingMoreHomeMeetups.value || !hasMoreHomeMeetups.value) {
      _debugHomeMeetups(
          'skip load more: loadingMore=${isLoadingMoreHomeMeetups.value}, hasMore=${hasMoreHomeMeetups.value}');
      return;
    }

    isLoadingMoreHomeMeetups.value = true;
    final startedAt = DateTime.now();
    try {
      final nextPage = _homeMeetupsCurrentPage + 1;
      _debugHomeMeetups('start load more: page=$nextPage');
      final data = await _meetupRepository
          .getMeetups(
            status: 'upcoming',
            page: nextPage,
            pageSize: _homeMeetupsPageSize,
          )
          .timeout(const Duration(seconds: 15));

      if (data.isEmpty) {
        hasMoreHomeMeetups.value = false;
        _debugHomeMeetups('load more: empty result at page=$nextPage, stop pagination');
        return;
      }

      final existingIds = homeMeetups.map((e) => e.id).toSet();
      final newItems = data.where((item) => !existingIds.contains(item.id)).toList();
      homeMeetups.addAll(newItems);
      meetupController.meetups.assignAll(homeMeetups);

      _homeMeetupsCurrentPage = nextPage;
      hasMoreHomeMeetups.value = data.length >= _homeMeetupsPageSize;
      _setHomeMeetupsState(
        homeMeetups.isEmpty ? LoadState.empty : LoadState.loaded,
        reason: 'load more success',
      );
      _debugHomeMeetups(
        'load more done: +${newItems.length} items (raw=${data.length}), total=${homeMeetups.length}, hasMore=${hasMoreHomeMeetups.value}, elapsed=${DateTime.now().difference(startedAt).inMilliseconds}ms',
      );
    } catch (e) {
      _debugHomeMeetups('load more failed: $e');
    } finally {
      isLoadingMoreHomeMeetups.value = false;
    }
  }

  /// 从其他页面返回时重新加载数据
  Future<void> onRouteResume() async {
    log('🔄 HomePageController: 从其他页面返回，刷新所有列表');

    // ⭐ 每次返回首页都刷新所有列表数据
    // 虽然 SignalR 已处理实时推送，但用户可能在其他页面做了操作（如创建/编辑 meetup），
    // 返回首页时应确保数据为最新
    // refreshMeetups 使用 forceRefresh，HomeMeetupsSection 在刷新时会保留旧数据避免闪屏
    await Future.wait([
      loadHomeCities(),
      refreshMeetups(),
    ]);

    log('✅ HomePageController: 返回首页刷新完成');
  }

  /// 下拉刷新 - 刷新所有数据
  Future<void> refreshAll() async {
    if (isRefreshing.value) return;

    log('🔄 HomePageController: 开始下拉刷新');
    isRefreshing.value = true;

    try {
      // 并行刷新城市和 meetup 数据
      await Future.wait([
        loadHomeCities(),
        refreshMeetups(),
      ]);

      log('✅ HomePageController: 下拉刷新完成');
    } catch (e) {
      log('⚠️ HomePageController: 下拉刷新失败: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// 首页可见时的轻量自愈检查
  ///
  /// 目标：
  /// 1. 首次进入首页时，确保 meetup/city 数据一定会触发加载
  /// 2. 从其他页面返回或底部导航切回首页时，补偿 route 回调遗漏
  /// 3. 避免高频 build 导致重复网络请求
  void onHomeVisible({bool forceRefresh = false}) {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastHomeVisibleCheckAt != null &&
        now.difference(_lastHomeVisibleCheckAt!) < const Duration(seconds: 8)) {
      return;
    }
    _lastHomeVisibleCheckAt = now;
    _debugHomeMeetups(
      'onHomeVisible: force=$forceRefresh, state=${homeMeetupsLoadState.value.name}, count=${homeMeetups.length}',
    );

    // 城市数据为空时自动补拉
    if (localCities.isEmpty && !isLoadingLocalCities.value) {
      unawaited(loadHomeCities());
    }

    if (forceRefresh) {
      _debugHomeMeetups('trigger force refresh from visible hook');
      unawaited(loadHomeMeetups(forceRefresh: true));
      return;
    }

    // 首页活动在初始/错误/空列表时，确保一定触发加载
    if (homeMeetups.isEmpty &&
        (homeMeetupsLoadState.value == LoadState.initial ||
            homeMeetupsLoadState.value == LoadState.error ||
            homeMeetupsLoadState.value == LoadState.empty)) {
      _debugHomeMeetups('trigger load due to empty + state=${homeMeetupsLoadState.value.name}');
      unawaited(loadHomeMeetups(forceRefresh: homeMeetupsLoadState.value == LoadState.error));
      return;
    }

    // 已有数据且超过缓存窗口，后台刷新
    if (homeMeetups.isNotEmpty &&
        (_lastHomeMeetupsLoadedAt == null || now.difference(_lastHomeMeetupsLoadedAt!) > const Duration(minutes: 2))) {
      _debugHomeMeetups('trigger background refresh due to stale cache');
      unawaited(loadHomeMeetups(forceRefresh: true));
    }
  }

  // ==================== 登录验证 ====================
  /// 严格检查登录状态和 Token 有效性
  bool checkLoginAndNavigate(VoidCallback onLoggedIn) {
    log('🔒 [严格验证] 检查登录状态...');

    // 1️⃣ 检查登录状态
    if (!authController.isAuthenticated.value) {
      log('❌ 用户未登录');
      AppToast.warning(
        _l10n.pleaseLogin,
        title: _l10n.loginRequired,
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // 2️⃣ 检查 Token 是否存在
    final token = authController.currentToken.value;
    if (token == null) {
      log('❌ Token 为空，清除登录状态');
      authController.isAuthenticated.value = false;
      authController.currentUser.value = null;

      AppToast.error(
        _l10n.dataServiceInvalidSession,
        title: _l10n.dataServiceAuthenticationError,
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // 3️⃣ 检查 Token 是否过期
    if (token.isExpired) {
      log('❌ Token 已过期');
      log('   ExpiresAt: ${token.expiresAt}');
      log('   Current: ${DateTime.now()}');

      // 立即清除过期状态
      authController.isAuthenticated.value = false;
      authController.currentUser.value = null;
      authController.currentToken.value = null;

      // 异步清除存储
      authController.logout();

      AppToast.error(
        _l10n.dataServiceSessionExpiredMessage,
        title: _l10n.dataServiceSessionExpiredTitle,
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // ✅ 所有检查通过，执行操作
    log('✅ Token 验证通过，允许操作');
    log('   ExpiresAt: ${token.expiresAt}');
    log('   Remaining: ${token.expiresAt!.difference(DateTime.now()).inMinutes} minutes');

    onLoggedIn();
    return true;
  }

  // ==================== 滚动功能 ====================
  /// 滚动到城市列表
  void scrollToCitiesList() {
    if (hasScrolled.value) return;
    hasScrolled.value = true;

    // 等待布局完成后滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final RenderBox? renderBox = citiesListKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && scrollController.hasClients) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final scrollPosition = scrollController.position.pixels + position - 100;

          scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  // ==================== 计算属性 ====================
  /// 获取显示的城市列表（最多显示6个）
  List<City> get displayCities {
    final items = localCities;
    return items.length > 6 ? items.sublist(0, 6) : items.toList();
  }

  /// 是否有更多城市
  bool get hasMoreCities => localCities.length > 6;

  /// 是否正在加载城市
  bool get isLoadingCities => isLoadingLocalCities.value;
}
