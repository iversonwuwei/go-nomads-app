import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/services/search_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 首页控制器 - GetX 标准实现（支持 GetView）
/// 管理首页的所有状态和业务逻辑
/// 内部实现路由监听，从其他页面返回时自动刷新数据
class HomePageController extends GetxController with WidgetsBindingObserver implements RouteAware {
  // ==================== 依赖注入 ====================
  final ICityRepository _cityRepository = Get.find<ICityRepository>();
  // 🔍 搜索服务 - 通过 Elasticsearch 提供高效搜索
  final SearchService _searchService = Get.find<SearchService>();

  // 延迟获取的控制器
  CityStateController get cityController => Get.find<CityStateController>();
  MeetupStateController get meetupController => Get.find<MeetupStateController>();
  UserStateController get userController => Get.find<UserStateController>();
  AuthStateController get authController => Get.find<AuthStateController>();

  // ==================== UI 控制器 ====================
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey citiesListKey = GlobalKey();

  // ==================== 路由监听 ====================
  PageRoute<dynamic>? _currentRoute;

  // ==================== 响应式状态 ====================
  /// 本地搜索关键词
  final localSearchQuery = ''.obs;

  /// 本地城市列表（独立于全局 CityStateController）
  final localCities = <City>[].obs;

  /// 是否正在加载城市数据
  final isLoadingLocalCities = true.obs;

  /// 是否正在进行本地搜索
  final isLocalSearching = false.obs;

  /// 是否已滚动到城市列表
  final hasScrolled = false.obs;

  /// 是否显示网格视图
  final isGridView = true.obs;

  /// 是否正在刷新
  final isRefreshing = false.obs;

  // ==================== 私有变量 ====================
  // 已移除 _cityListWorker，首页数据完全独立

  // SignalR 订阅
  StreamSubscription<Map<String, dynamic>>? _cityImageUpdatedSubscription;

  // ==================== 生命周期 ====================
  @override
  void onInit() {
    super.onInit();
    log('🏠 HomePageController: onInit');

    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 设置 SignalR 监听器（城市图片更新）
    _setupSignalRListeners();

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

    // 清理资源
    scrollController.dispose();
    searchController.dispose();

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

    // ⭐ 并行加载：首页城市数据（独立）+ Meetup 数据
    await Future.wait([
      _loadHomeCitiesIndependent(),
      meetupController.ensureDataLoaded(),
    ]);
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

  /// 刷新 meetup 数据（重新加载，显示加载状态）
  /// 参照 city 的独立加载逻辑，使用 forceRefresh 让控制器正确管理状态
  Future<void> refreshMeetups() async {
    try {
      log('🔄 HomePageController: 刷新 meetup 数据');
      // 使用 forceRefresh，让 MeetupStateController 正确管理状态
      // forceRefresh 会: 1. 先 invalidateCache 2. 然后调用 refresh()
      // refresh() 会设置 isRefreshing=true，然后调用 loadData()
      // loadData() 会重置分页状态并重新加载第一页数据
      await meetupController.forceRefresh();
    } catch (e) {
      log('⚠️ HomePageController: meetup 数据刷新失败: $e');
    }
  }

  /// 从其他页面返回时重新加载数据
  Future<void> onRouteResume() async {
    log('🔄 HomePageController: 从其他页面返回，重新加载数据');

    // ⭐ 立即设置 city 加载状态
    isLoadingLocalCities.value = true;
    localCities.clear();

    clearSearchOnReturn();

    // 并行加载城市和活动数据
    // meetup 的状态由 forceRefresh 内部管理（设置 isRefreshing=true）
    await Future.wait([
      loadHomeCities(),
      refreshMeetups(),
    ]);
  }

  /// 下拉刷新 - 刷新所有数据
  Future<void> refreshAll() async {
    if (isRefreshing.value) return;

    log('🔄 HomePageController: 开始下拉刷新');
    isRefreshing.value = true;

    try {
      // 清除搜索状态
      clearSearchOnReturn();

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

  // ==================== 搜索功能 ====================
  /// 执行城市搜索（使用 Elasticsearch SearchService）
  Future<void> performSearch(String query) async {
    log('🔍 [首页] 开始使用 Elasticsearch 搜索城市: $query');

    localSearchQuery.value = query;
    isLocalSearching.value = true;

    // 🔍 使用 SearchService 进行 Elasticsearch 搜索
    final searchResult = await _searchService.searchCities(
      query: query,
      pageSize: 20,
    );

    searchResult.fold(
      onSuccess: (data) {
        // 将 CitySearchDocument 转换为 City 对象
        final cities = data.items.map((item) => _convertSearchDocToCity(item.document)).toList();
        localCities.assignAll(cities);
        log('✅ [首页] Elasticsearch 搜索成功: ${cities.length} 个城市 (共 ${data.totalCount} 个)');
        AppToast.success(
          'Found ${cities.length} cities',
          title: 'Search',
        );
      },
      onFailure: (exception) {
        log('⚠️ [首页] Elasticsearch 搜索失败，回退到传统搜索: ${exception.message}');
        // 搜索失败时回退到传统方式
        _fallbackSearch(query);
      },
    );
  }

  /// 将 CitySearchDocument 转换为 City 对象
  City _convertSearchDocToCity(CitySearchDocument doc) {
    return City(
      id: doc.id,
      name: doc.name,
      nameEn: doc.nameEn,
      country: doc.country,
      region: doc.region,
      description: doc.description,
      latitude: doc.latitude,
      longitude: doc.longitude,
      imageUrl: doc.imageUrl,
      portraitImageUrl: doc.portraitImageUrl,
      timezone: doc.timeZone,
      currency: doc.currency,
      overallScore: doc.overallScore,
      internetScore: doc.internetQualityScore,
      safetyScore: doc.safetyScore,
      costScore: doc.costScore,
      communityScore: doc.communityScore,
      weatherScore: doc.weatherScore,
      tags: doc.tags,
      // 扩展字段 - 从 ES 同步
      averageCost: doc.averageCost,
      meetupCount: doc.meetupCount,
      coworkingCount: doc.coworkingCount,
      reviewCount: doc.reviewCount,
      moderatorId: doc.moderatorId,
    );
  }

  /// Elasticsearch 搜索失败时的回退方案
  Future<void> _fallbackSearch(String query) async {
    // 使用 Repository 直接搜索
    final result = await _cityRepository.searchCities(name: query, pageSize: 20);

    result.fold(
      onSuccess: (data) {
        localCities.assignAll(data);
        AppToast.success(
          'Found ${data.length} cities',
          title: 'Search',
        );
      },
      onFailure: (exception) {
        AppToast.error(exception.message, title: 'Search Failed');
      },
    );
  }

  /// 清除搜索（仅清除本页面的搜索状态）
  Future<void> clearSearch() async {
    searchController.clear();
    log('🧹 [首页] 清除搜索，重新加载全部城市');

    localSearchQuery.value = '';
    isLocalSearching.value = false;

    // 重新加载全部城市到本地
    await loadHomeCities();
  }

  /// 清除搜索状态（从 detail 页面返回时调用）
  void clearSearchOnReturn() {
    log('🔍 HomePageController: 清除搜索状态，当前 localSearchQuery=${localSearchQuery.value}');
    localSearchQuery.value = '';
    isLocalSearching.value = false;
    searchController.clear();
    log('🔍 HomePageController: 本地搜索状态已清除');
  }

  // ==================== 登录验证 ====================
  /// 严格检查登录状态和 Token 有效性
  bool checkLoginAndNavigate(VoidCallback onLoggedIn) {
    log('🔒 [严格验证] 检查登录状态...');

    // 1️⃣ 检查登录状态
    if (!authController.isAuthenticated.value) {
      log('❌ 用户未登录');
      AppToast.warning(
        'Please login to access this feature',
        title: 'Login Required',
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
        'Invalid session. Please login again.',
        title: 'Authentication Error',
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
        'Your session has expired. Please login again.',
        title: 'Session Expired',
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
