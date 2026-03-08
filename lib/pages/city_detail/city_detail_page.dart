import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';

import '../../features/ai/presentation/controllers/ai_state_controller.dart';
import '../../features/city/application/state_controllers/pros_cons_state_controller.dart';
import '../../features/city/presentation/controllers/city_detail_state_controller.dart';
import '../../features/membership/presentation/services/ai_quota_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/share_bottom_sheet.dart';
import '../add_coworking/add_coworking_page.dart';
import '../city_photo_submission_page.dart';
import '../manage_pros_cons_page.dart';
import '../pros_and_cons_add_page.dart';
import 'city_detail_controller.dart';
import 'widgets/ai_travel_plan_fab.dart';
import 'widgets/city_detail_app_bar.dart';
import 'widgets/city_detail_tab_bar.dart';
import 'widgets/moderator_info_card.dart';
import 'widgets/tabs/cost_tab.dart';
import 'widgets/tabs/coworking_tab.dart';
import 'widgets/tabs/guide_tab.dart';
import 'widgets/tabs/hotels_tab.dart';
import 'widgets/tabs/neighborhoods_tab.dart';
import 'widgets/tabs/photos_tab.dart';
import 'widgets/tabs/pros_cons_tab.dart';
import 'widgets/tabs/reviews_tab.dart';
import 'widgets/tabs/scores_tab.dart';
import 'widgets/tabs/weather/weather_tab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 城市详情页 - GetX 重构版
///
/// 使用模块化组件构建，每个 Tab 都是独立的 GetView 组件
class CityDetailPage extends StatelessWidget {
  final String cityId;
  final String cityName;
  final List<String> cityImages;
  final String cityImage;
  final double overallScore;
  final int reviewCount;

  const CityDetailPage({
    super.key,
    this.cityId = '',
    this.cityName = '',
    this.cityImages = const [],
    this.cityImage = '',
    this.overallScore = 0.0,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 从 Get.arguments 或构造函数获取参数
    final args = Get.arguments as Map<String, dynamic>?;
    final resolvedCityId = args?['cityId'] ?? cityId;
    final resolvedCityName = args?['cityName'] ?? cityName;
    final List<String> resolvedCityImages = (args?['imageUrls'] as List?)?.whereType<String>().toList() ?? cityImages;
    final resolvedCityImage = args?['cityImage'] ?? cityImage;
    final List<String> heroImages = resolvedCityImages.isNotEmpty
        ? resolvedCityImages
        : (resolvedCityImage.isNotEmpty ? [resolvedCityImage] : const <String>[]);
    final resolvedOverallScore = args?['overallScore'] ?? overallScore;
    final resolvedReviewCount = args?['reviewCount'] ?? reviewCount;
    final initialTab = args?['initialTab'] as int? ?? 0;

    // 使用唯一 tag 确保每个城市页面有独立的控制器实例
    final tag = 'city_detail_$resolvedCityId';

    // 每次进入都清理旧控制器，确保数据从服务端全新加载
    if (Get.isRegistered<CityDetailController>(tag: tag)) {
      Get.delete<CityDetailController>(tag: tag, force: true);
      log('🧹 [CityDetailPage] 清理旧控制器: $tag');
    }

    // 重置共享状态控制器的 tab 索引
    final cityDetailStateController = Get.find<CityDetailStateController>();
    cityDetailStateController.currentTabIndex.value = 0;

    // 注册全新的控制器
    final controller = Get.put(CityDetailController(), tag: tag);
    controller.initWithParams(
      cityId: resolvedCityId,
      cityName: resolvedCityName,
      cityImages: heroImages,
      overallScore:
          resolvedOverallScore is double ? resolvedOverallScore : (resolvedOverallScore as num?)?.toDouble() ?? 0.0,
      reviewCount: resolvedReviewCount is int ? resolvedReviewCount : (resolvedReviewCount as num?)?.toInt() ?? 0,
      initialTab: initialTab,
    );

    return _CityDetailPageContent(controllerTag: tag);
  }
}

/// 城市详情页内容组件
class _CityDetailPageContent extends GetView<CityDetailController> {
  const _CityDetailPageContent({required this.controllerTag});

  final String controllerTag;

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: AiTravelPlanFab(
        cityId: controller.cityId,
        cityName: controller.cityName,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return NestedScrollView(
      controller: controller.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // 自定义 AppBar
          CityDetailAppBar(
            controller: controller,
            cityName: controller.cityName,
            cityImages: controller.cityImages,
            overallScore: controller.overallScore,
            reviewCount: controller.reviewCount,
            onShare: () => _shareCityInfo(context),
          ),
          // 版主信息卡片
          const SliverToBoxAdapter(
            child: ModeratorInfoCard(),
          ),
          // 固定的 TabBar
          SliverPersistentHeader(
            pinned: true,
            delegate: CityDetailTabBarDelegate(
              _buildTabBar(context),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: controller.tabController,
        children: _buildTabViews(context),
      ),
    );
  }

  /// 构建 TabBar，支持可添加内容的 Tab 显示 + 图标
  Widget _buildTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 定义哪些 tab 索引需要显示 + 图标及其点击回调
    final addableTabs = {
      // CityDetailController.tabScores: () => _onTabAddPressed(context, CityDetailController.tabScores), // 暂时隐藏
      CityDetailController.tabProsCons: () => _onTabAddPressed(context, CityDetailController.tabProsCons),
      CityDetailController.tabReviews: () => _onTabAddPressed(context, CityDetailController.tabReviews),
      CityDetailController.tabCost: () => _onTabAddPressed(context, CityDetailController.tabCost),
      CityDetailController.tabPhotos: () => _onTabAddPressed(context, CityDetailController.tabPhotos),
      CityDetailController.tabHotels: () => _onTabAddPressed(context, CityDetailController.tabHotels),
      CityDetailController.tabCoworking: () => _onTabAddPressed(context, CityDetailController.tabCoworking),
    };

    final tabLabels = [
      l10n.scores,
      l10n.guide,
      l10n.prosAndCons,
      l10n.reviews,
      l10n.cost,
      l10n.photos,
      l10n.weather,
      l10n.hotels,
      l10n.neighborhoods,
      l10n.coworking,
    ];

    final tabBar = TabBar(
      controller: controller.tabController,
      isScrollable: true,
      labelColor: const Color(0xFFFF4458),
      unselectedLabelColor: Colors.grey[600],
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Color(0xFFFF4458), width: 2.5),
        insets: EdgeInsets.symmetric(horizontal: 12.w),
      ),
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      labelPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
      tabs: List.generate(tabLabels.length, (index) {
        final hasAdd = addableTabs.containsKey(index);
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tabLabels[index]),
              if (hasAdd) ...[
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: addableTabs[index],
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 14.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B7A), Color(0xFFFF4458)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.25),
                          blurRadius: 3.r,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      FontAwesomeIcons.plus,
                      size: 7.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x11000000), width: 1),
        ),
      ),
      child: tabBar,
    );
  }

  /// Tab + 图标点击处理
  void _onTabAddPressed(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case CityDetailController.tabScores:
        _showRatingDialog(context);
        break;
      case CityDetailController.tabProsCons:
        _showAddProsConsPage(context);
        break;
      case CityDetailController.tabReviews:
        ReviewsTab.navigateToAddReview(
          cityId: controller.cityId,
          cityName: controller.cityName,
          isAdminOrModerator: controller.isAdmin.value || controller.isModerator.value,
        );
        break;
      case CityDetailController.tabCost:
        CostTab.navigateToAddCost(
          cityId: controller.cityId,
          cityName: controller.cityName,
          isAdminOrModerator: controller.isAdmin.value || controller.isModerator.value,
        );
        break;
      case CityDetailController.tabPhotos:
        Get.to(() => CityPhotoSubmissionPage(
              cityId: controller.cityId,
              cityName: controller.cityName,
            ));
        break;
      case CityDetailController.tabHotels:
        _navigateToAddHotel();
        break;
      case CityDetailController.tabCoworking:
        _showAddCoworkingPage(context);
        break;
    }
  }

  /// 导航到添加酒店页面
  Future<void> _navigateToAddHotel() async {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;

    await NavigationUtil.toNamedWithCallback<bool>(
      route: AppRoutes.addHotel,
      arguments: {
        'cityId': controller.cityId,
        'cityName': controller.cityName,
        'countryName': city?.country,
      },
      onResult: (result) {
        if (result.needsRefresh) {
          AppToast.success(_l10n.hotelSubmittedSuccess);
        }
      },
    );
  }

  /// 显示添加优缺点页面
  void _showAddProsConsPage(BuildContext context) async {
    final prosConsController = Get.find<ProsConsStateController>();

    if (controller.isAdminOrModerator) {
      await Get.to(() => ManageProsConsPage(
            cityId: controller.cityId,
            cityName: controller.cityName,
          ));
    } else {
      await Get.to(() => ProsAndConsAddPage(
            cityId: controller.cityId,
            cityName: controller.cityName,
          ));
    }
    prosConsController.loadCityProsCons(controller.cityId);
  }

  /// 显示评分对话框
  void _showRatingDialog(BuildContext context) {
    // 触发评分评价，滚动到第一个评分项并提示用户点击评分
    AppToast.info(_l10n.tapStarsToRate);
    // 确保当前 tab 是 Scores
    if (controller.tabController.index != CityDetailController.tabScores) {
      controller.tabController.animateTo(CityDetailController.tabScores);
    }
  }

  List<Widget> _buildTabViews(BuildContext context) {
    return [
      ScoresTab(tag: controllerTag),
      GuideTab(tag: controllerTag), // GuideTab 内部已有完整的 AI 生成逻辑
      ProsConsTab(tag: controllerTag), // ProsConsTab 内部已有导航和投票逻辑
      ReviewsTab(tag: controllerTag),
      CostTab(tag: controllerTag),
      PhotosTab(tag: controllerTag),
      WeatherTab(tag: controllerTag),
      HotelsTab(tag: controllerTag),
      NeighborhoodsTab(
        tag: controllerTag,
        onGeneratePressed: () => _showNearbyCitiesGenerateDialog(context),
        onCheckPermission: _checkGeneratePermission,
      ),
      CoworkingTab(
        tag: controllerTag,
        onAddCoworkingPressed: () => _showAddCoworkingPage(context),
      ),
    ];
  }

  void _shareCityInfo(BuildContext context) {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;
    if (city == null) return;

    final l10n = AppLocalizations.of(context)!;

    // 构建分享标题
    final String title =
        city.country != null ? '${city.name}, ${city.country} - Go Nomads' : '${city.name} - Go Nomads';

    // 构建分享描述
    final List<String> descParts = [];

    // 总体评分
    if (city.overallScore != null && city.overallScore! > 0) {
      descParts.add('⭐ ${l10n.overallScore}: ${city.overallScore!.toStringAsFixed(1)}/5.0');
    }

    // 温度
    if (city.temperature != null) {
      descParts.add('🌡️ ${city.temperature}°C');
    }

    // 人口
    if (city.population != null && city.population!.isNotEmpty) {
      descParts.add('👥 ${l10n.population}: ${city.population}');
    }

    // 平均花费
    if (city.averageCost != null && city.averageCost! > 0) {
      descParts.add('💰 ${l10n.monthlyCost}: \$${city.averageCost!.toStringAsFixed(0)}/月');
    }

    // 安全评分
    if (city.safetyScore != null && city.safetyScore! > 0) {
      descParts.add('🛡️ ${l10n.safety}: ${city.safetyScore!.toStringAsFixed(1)}/5.0');
    }

    // 网速评分
    if (city.internetScore != null && city.internetScore! > 0) {
      descParts.add('📶 ${l10n.internet}: ${city.internetScore!.toStringAsFixed(1)}/5.0');
    }

    // 描述
    if (city.description != null && city.description!.isNotEmpty) {
      descParts.add('\n${city.description}');
    }

    final String description = descParts.join('\n');

    // 构建分享链接
    final String shareUrl = 'https://nomadcities.app/cities/${city.id}';

    // 封面图
    final String? imageUrl = city.imageUrl;

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: description,
      imageUrl: imageUrl,
      shareUrl: shareUrl,
    );
  }

  // ==================== Coworking 相关 ====================

  void _showAddCoworkingPage(BuildContext context) async {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;

    await NavigationUtil.toWithCallback<dynamic>(
      page: () => AddCoworkingPage(
        cityName: controller.cityName,
        cityId: controller.cityId,
        countryName: city?.country,
      ),
      onResult: (result) {
        if (result.needsRefresh) {
          AppToast.success(
            'Your coworking space will be reviewed and added soon!',
            title: _l10n.success,
          );
        }
      },
    );
  }

  // ==================== AI 生成相关 ====================

  Future<bool> _checkGeneratePermission() async {
    log('🔐 [权限检查] 开始检查生成权限...');

    // 使用统一的 AiQuotaService 检查配额并显示升级对话框
    final canUse = await AiQuotaService().checkAndUseAI(
      featureName: '附近城市生成',
      showUpgradeDialog: true,
    );

    if (!canUse) {
      log('❌ [权限检查] AI 配额不足');
      return false;
    }

    log('✅ [权限检查] 权限检查通过');
    return true;
  }

  void _showNearbyCitiesGenerateDialog(BuildContext context) {
    final aiController = Get.find<AiStateController>();
    _showAiGenerateProgressDialog(
      context: context,
      title: _l10n.cityDetailGeneratingNearbyCitiesTitle,
      icon: FontAwesomeIcons.mapLocationDot,
      progressGetter: () => aiController.nearbyCitiesGenerationProgress,
      messageGetter: () => aiController.nearbyCitiesGenerationMessage,
      isCompletedGetter: () => aiController.isNearbyCitiesCompleted,
      onStart: () => aiController.generateNearbyCitiesStream(
        cityId: controller.cityId,
        cityName: controller.cityName,
      ),
      onComplete: () {
        aiController.loadNearbyCities(cityId: controller.cityId);
        AppToast.success(_l10n.cityDetailNearbyCitiesGeneratedSuccess);
      },
    );
  }

  void _showAiGenerateProgressDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int Function() progressGetter,
    required String Function() messageGetter,
    required bool Function() isCompletedGetter,
    required Future<void> Function() onStart,
    required VoidCallback onComplete,
  }) {
    // 开始生成
    onStart();

    Worker? statusWorker;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (statusWorker == null) {
            final aiController = Get.find<AiStateController>();
            statusWorker = ever(
              aiController.isNearbyCitiesCompletedRx,
              (completed) {
                if (completed) {
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                      statusWorker?.dispose();
                      statusWorker = null;
                      Future.delayed(const Duration(milliseconds: 500), onComplete);
                    }
                  });
                }
              },
            );
          }
        });

        return Obx(() {
          final progress = progressGetter();
          final message = messageGetter();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF4458), size: 28.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(title, style: TextStyle(fontSize: 18.sp)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.h),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$progress%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xFFFF4458),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
