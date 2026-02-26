import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_rating_item.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/features/weather/presentation/controllers/weather_state_controller.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';

/// 城市详情页面控制器
///
/// 管理页面级别的 UI 状态，包括 Tab、滚动、刷新等
class CityDetailController extends GetxController with GetTickerProviderStateMixin {
  // ==================== 页面参数 ====================
  late String cityId;
  late String cityName;
  late List<String> cityImages;
  late double overallScore;
  late int reviewCount;
  late int initialTab;

  // ==================== 控制器 ====================
  late PageController pageController;
  late TabController tabController;
  late ScrollController scrollController;

  // ==================== 响应式状态 ====================
  final RxInt currentPage = 0.obs;
  final RxDouble appBarOpacity = 0.0.obs;
  final RxBool isRefreshingReviews = false.obs;
  final RxBool isRefreshingPhotos = false.obs;
  final RxBool hasInitializedGuide = false.obs;
  final RxBool hasInitializedNearbyCities = false.obs;
  final Rx<String?> lastGuideLoadedCityId = Rx<String?>(null);
  final Rx<String?> lastNearbyCitiesLoadedCityId = Rx<String?>(null);
  final RxList<CityRatingItem> customRatingItems = <CityRatingItem>[].obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isAdmin = false.obs;
  final RxBool isModerator = false.obs;

  // Tab 索引常量
  static const int tabScores = 0;
  static const int tabGuide = 1;
  static const int tabProsCons = 2;
  static const int tabReviews = 3;
  static const int tabCost = 4;
  static const int tabPhotos = 5;
  static const int tabWeather = 6;
  static const int tabHotels = 7;
  static const int tabNeighborhoods = 8;
  static const int tabCoworking = 9;

  // 首次加载标记，避免重复请求
  bool _loadedGuide = false;
  bool _loadedProsCons = false;
  bool _loadedReviews = false;
  bool _loadedPhotos = false;
  bool _loadedCost = false;
  bool _loadedWeather = false;
  bool _loadedCoworking = false;

  // ==================== 初始化方法 ====================

  /// 使用参数初始化控制器
  void initWithParams({
    required String cityId,
    required String cityName,
    required List<String> cityImages,
    required double overallScore,
    required int reviewCount,
    int initialTab = 0,
  }) {
    this.cityId = cityId;
    this.cityName = cityName;
    this.cityImages = cityImages.isNotEmpty ? cityImages : [''];
    this.overallScore = overallScore;
    this.reviewCount = reviewCount;
    this.initialTab = initialTab;

    _initControllers();
    _loadInitialData();
    _checkUserStatus();
  }

  void _initControllers() {
    pageController = PageController();
    scrollController = ScrollController();

    // 初始化 TabController (10个tab)
    tabController = TabController(
      length: 10,
      vsync: this,
      initialIndex: initialTab,
    );

    // 监听 Tab 切换
    tabController.addListener(_onTabChanged);

    // 监听滚动
    scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      currentPage.value = tabController.index;
      _loadTabDataIfNeeded(tabController.index);
    }
  }

  void _onScroll() {
    final offset = scrollController.offset;
    final newOpacity = (offset / 200).clamp(0.0, 1.0);

    if (appBarOpacity.value != newOpacity) {
      appBarOpacity.value = newOpacity;
    }
  }

  Future<void> _checkUserStatus() async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    isLoggedIn.value = token != null && token.isNotEmpty;

    if (isLoggedIn.value) {
      final role = await tokenService.getUserRole();
      isAdmin.value = role == 'admin' || role == 'super_admin';
      isModerator.value = role == 'moderator' || role == 'city_moderator';
    }
  }

  Future<void> _loadInitialData() async {
    final cityDetailController = Get.find<CityDetailStateController>();

    // 重置 tab 索引
    cityDetailController.currentTabIndex.value = initialTab;

    // 先加载页面通用数据（城市详情）
    await cityDetailController.loadCityDetail(cityId);

    // 城市详情加载完毕后，再按需加载首屏 Tab 数据
    _loadTabDataIfNeeded(initialTab);
  }

  void _loadTabDataIfNeeded(int index) async {
    switch (index) {
      case tabGuide:
        if (!_loadedGuide) {
          _loadedGuide = true;
          Get.find<AiStateController>().loadCityGuide(cityId: cityId, cityName: cityName);
        }
        break;
      case tabProsCons:
        if (!_loadedProsCons) {
          _loadedProsCons = true;
          Get.find<ProsConsStateController>().loadCityProsCons(cityId);
        }
        break;
      case tabReviews:
        if (!_loadedReviews) {
          _loadedReviews = true;
          Get.find<UserCityContentStateController>().loadCityReviews(cityId);
        }
        break;
      case tabCost:
        if (!_loadedCost) {
          _loadedCost = true;
          final userContentController = Get.find<UserCityContentStateController>();
          userContentController.loadCityExpenses(cityId);
          userContentController.loadCityCostSummary(cityId);
        }
        break;
      case tabPhotos:
        if (!_loadedPhotos) {
          _loadedPhotos = true;
          Get.find<UserCityContentStateController>().loadCityPhotos(cityId);
        }
        break;
      case tabWeather:
        if (!_loadedWeather) {
          _loadedWeather = true;
          _loadWeatherData();
        }
        break;
      case tabCoworking:
        if (!_loadedCoworking) {
          _loadedCoworking = true;
          _loadCoworkingData();
        }
        break;
      default:
        // 评分/酒店/社区等保持现有懒加载行为
        break;
    }
  }

  void _loadWeatherData() {
    final weatherController = Get.find<WeatherStateController>();
    weatherController.loadCityWeather(
      cityId,
      includeForecast: true,
      days: 7,
    );
  }

  void _loadCoworkingData() {
    final coworkingController = Get.find<CoworkingStateController>();
    if (coworkingController.currentCityId.value != cityId) {
      coworkingController.loadCoworkingSpacesByCity(cityId);
      log('🔄 [TabSwitch] 切换到 Coworking tab，加载新城市数据');
    }
  }

  // ==================== 公共方法 ====================

  /// 生成评分 ID
  String generateRatingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'rating_${timestamp}_${customRatingItems.length}';
  }

  /// 刷新当前 Tab 数据
  Future<void> refreshCurrentTab() async {
    switch (tabController.index) {
      case tabScores:
        Get.find<CityDetailStateController>().loadCityDetail(cityId);
        break;
      case tabGuide:
        Get.find<AiStateController>().loadCityGuide(cityId: cityId, cityName: cityName);
        break;
      case tabProsCons:
        Get.find<ProsConsStateController>().loadCityProsCons(cityId);
        break;
      case tabReviews:
        isRefreshingReviews.value = true;
        await Get.find<UserCityContentStateController>().loadCityReviews(cityId);
        isRefreshingReviews.value = false;
        break;
      case tabCost:
        final controller = Get.find<UserCityContentStateController>();
        controller.loadCityExpenses(cityId);
        controller.loadCityCostSummary(cityId);
        break;
      case tabPhotos:
        isRefreshingPhotos.value = true;
        await Get.find<UserCityContentStateController>().loadCityPhotos(cityId);
        isRefreshingPhotos.value = false;
        break;
      case tabWeather:
        _loadWeatherData();
        break;
      case tabNeighborhoods:
        Get.find<AiStateController>().loadNearbyCities(cityId: cityId);
        break;
      case tabCoworking:
        _loadCoworkingData();
        break;
    }
  }

  /// 检查是否为管理员或版主
  bool get isAdminOrModerator => isAdmin.value || isModerator.value;

  /// 酒店列表 tag
  String get hotelListTag => 'hotel_list_$cityId';

  /// 删除城市（仅管理员）
  Future<bool> deleteCity() async {
    try {
      final cityDetailController = Get.find<CityDetailStateController>();
      final result = await cityDetailController.deleteCity(cityId);
      return result;
    } catch (e) {
      log('❌ 删除城市失败: $e');
      return false;
    }
  }

  /// 重置所有加载标记和页面状态
  void _resetAllState() {
    _loadedGuide = false;
    _loadedProsCons = false;
    _loadedReviews = false;
    _loadedPhotos = false;
    _loadedCost = false;
    _loadedWeather = false;
    _loadedCoworking = false;
    currentPage.value = 0;
    appBarOpacity.value = 0.0;
    isRefreshingReviews.value = false;
    isRefreshingPhotos.value = false;
    hasInitializedGuide.value = false;
    hasInitializedNearbyCities.value = false;
    lastGuideLoadedCityId.value = null;
    lastNearbyCitiesLoadedCityId.value = null;
    customRatingItems.clear();
    log('🧹 [CityDetailController] 所有页面状态已重置');
  }

  @override
  void onClose() {
    _resetAllState();
    pageController.dispose();
    scrollController.dispose();
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
