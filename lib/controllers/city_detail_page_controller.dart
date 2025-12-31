import 'dart:developer';

import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_rating_item.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/features/weather/presentation/controllers/weather_state_controller.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 城市详情页面控制器
///
/// 管理页面级别的 UI 状态，包括 Tab、滚动、刷新等
class CityDetailPageController extends GetxController
    with GetTickerProviderStateMixin {
  // ==================== 页面参数 ====================
  late final String cityId;
  late final String cityName;
  late final String cityImage;
  late final double overallScore;
  late final int reviewCount;
  late final int initialTab;

  // ==================== 控制器 ====================
  late final PageController pageController;
  late final TabController tabController;
  late final ScrollController scrollController;

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
      if (tabController.index == 6) {
        final weatherController = Get.find<WeatherStateController>();
        weatherController.loadCityWeather(
          cityId,
          includeForecast: true,
          days: 7,
        );
      }

      // Coworking tab (索引 9)
      if (tabController.index == 9) {
        final coworkingController = Get.find<CoworkingStateController>();
        if (coworkingController.currentCityId.value != cityId) {
          coworkingController.loadCoworkingSpacesByCity(cityId);
          log('🔄 [TabSwitch] 切换到 Coworking tab，加载新城市数据');
        }
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

  Future<void> _loadInitialData() async {
    final cityDetailController = Get.find<CityDetailStateController>();
    final userContentController = Get.find<UserCityContentStateController>();
    final prosConsController = Get.find<ProsConsStateController>();

    // 加载城市详情
    cityDetailController.loadCityDetail(cityId);

    // 检查登录状态
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
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

  // ==================== 公共方法 ====================

  /// 生成评分 ID
  String generateRatingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'rating_${timestamp}_${customRatingItems.length}';
  }

  /// 添加自定义评分项
  void addCustomRatingItem(CityRatingItem item) {
    customRatingItems.add(item);
  }

  /// 刷新城市详情
  Future<void> refreshCityDetail() async {
    final cityDetailController = Get.find<CityDetailStateController>();
    final userContentController = Get.find<UserCityContentStateController>();
    final prosConsController = Get.find<ProsConsStateController>();

    // 重新加载城市详情（强制刷新）
    await cityDetailController.loadCityDetail(cityId, forceRefresh: true);

    // 检查登录状态
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
      userContentController.loadCityPhotos(cityId);
      userContentController.loadCityExpenses(cityId);
      userContentController.loadCityReviews(cityId);
      userContentController.loadCityCostSummary(cityId);
      prosConsController.loadCityProsCons(cityId);
    } else {
      prosConsController.loadCityProsCons(cityId);
    }
  }

  /// 刷新评论
  Future<void> refreshReviews() async {
    if (isRefreshingReviews.value) return;
    isRefreshingReviews.value = true;

    final userContentController = Get.find<UserCityContentStateController>();
    await userContentController.loadCityReviews(cityId);

    isRefreshingReviews.value = false;
  }

  /// 刷新照片
  Future<void> refreshPhotos() async {
    if (isRefreshingPhotos.value) return;
    isRefreshingPhotos.value = true;

    final userContentController = Get.find<UserCityContentStateController>();
    await userContentController.loadCityPhotos(cityId);

    isRefreshingPhotos.value = false;
  }

  // ==================== 生命周期 ====================

  @override
  void onClose() {
    scrollController.dispose();
    pageController.dispose();
    tabController.removeListener(_onTabChanged);
    tabController.dispose();

    // 清空指南状态
    try {
      final aiController = Get.find<AiStateController>();
      aiController.resetGuideState();
      log('🧹 [CityDetailPageController] 控制器销毁，已清空指南状态');
    } catch (e) {
      log('⚠️ [CityDetailPageController] 清空指南状态失败: $e');
    }

    // 清空评分数据
    try {
      final ratingController = Get.find<CityRatingController>();
      ratingController.statistics.clear();
      ratingController.categories.clear();
      ratingController.overallScore.value = 0.0;
      log('🧹 [CityDetailPageController] 控制器销毁，已清空评分数据');
    } catch (e) {
      log('⚠️ [CityDetailPageController] 清空评分数据失败: $e');
    }

    super.onClose();
  }
}
