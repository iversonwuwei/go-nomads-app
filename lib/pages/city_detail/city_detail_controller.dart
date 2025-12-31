import 'dart:developer';

import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_rating_item.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/features/weather/presentation/controllers/weather_state_controller.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 城市详情页面控制器
///
/// 管理页面级别的 UI 状态，包括 Tab、滚动、刷新等
class CityDetailController extends GetxController with GetTickerProviderStateMixin {
  // ==================== 页面参数 ====================
  late String cityId;
  late String cityName;
  late String cityImage;
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

  // ==================== 初始化方法 ====================

  /// 使用参数初始化控制器
  void initWithParams({
    required String cityId,
    required String cityName,
    required String cityImage,
    required double overallScore,
    required int reviewCount,
    int initialTab = 0,
  }) {
    this.cityId = cityId;
    this.cityName = cityName;
    this.cityImage = cityImage;
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

      // Weather tab (索引 6)
      if (tabController.index == tabWeather) {
        _loadWeatherData();
      }

      // Coworking tab (索引 9)
      if (tabController.index == tabCoworking) {
        _loadCoworkingData();
      }
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
    final userContentController = Get.find<UserCityContentStateController>();
    final prosConsController = Get.find<ProsConsStateController>();

    // 加载城市详情
    cityDetailController.loadCityDetail(cityId);

    // 检查登录状态
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    final loggedIn = token != null && token.isNotEmpty;

    if (loggedIn) {
      // 登录用户: 加载所有用户生成内容
      userContentController.loadCityPhotos(cityId);
      userContentController.loadCityExpenses(cityId);
      userContentController.loadCityReviews(cityId);
      userContentController.loadCityCostSummary(cityId);
      prosConsController.loadCityProsCons(cityId);
    } else {
      // 游客用户: 只加载城市公开内容
      prosConsController.loadCityProsCons(cityId);
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

  @override
  void onClose() {
    pageController.dispose();
    scrollController.dispose();
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
