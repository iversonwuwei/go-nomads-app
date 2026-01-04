import 'dart:developer';

import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../features/ai/presentation/controllers/ai_state_controller.dart';
import '../../features/city/presentation/controllers/city_detail_state_controller.dart';
import '../../features/membership/presentation/controllers/membership_state_controller.dart';
import '../../widgets/app_toast.dart';
import '../add_coworking/add_coworking_page.dart';
import 'city_detail_controller.dart';
import 'widgets/ai_travel_plan_fab.dart';
import 'widgets/city_detail_app_bar.dart';
import 'widgets/city_detail_tab_bar.dart';
import 'widgets/city_info_summary_card.dart';
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

/// 城市详情页 - GetX 重构版
///
/// 使用模块化组件构建，每个 Tab 都是独立的 GetView 组件
class CityDetailPage extends StatelessWidget {
  final String cityId;
  final String cityName;
  final String cityImage;
  final double overallScore;
  final int reviewCount;

  const CityDetailPage({
    super.key,
    this.cityId = '',
    this.cityName = '',
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
    final resolvedCityImage = args?['cityImage'] ?? cityImage;
    final resolvedOverallScore = args?['overallScore'] ?? overallScore;
    final resolvedReviewCount = args?['reviewCount'] ?? reviewCount;
    final initialTab = args?['initialTab'] as int? ?? 0;

    // 使用唯一 tag 确保每个城市页面有独立的控制器实例
    final tag = 'city_detail_$resolvedCityId';

    // 注册控制器
    if (!Get.isRegistered<CityDetailController>(tag: tag)) {
      final controller = Get.put(CityDetailController(), tag: tag);
      controller.initWithParams(
        cityId: resolvedCityId,
        cityName: resolvedCityName,
        cityImage: resolvedCityImage,
        overallScore:
            resolvedOverallScore is double ? resolvedOverallScore : (resolvedOverallScore as num?)?.toDouble() ?? 0.0,
        reviewCount: resolvedReviewCount is int ? resolvedReviewCount : (resolvedReviewCount as num?)?.toInt() ?? 0,
        initialTab: initialTab,
      );
    }

    return _CityDetailPageContent(controllerTag: tag);
  }
}

/// 城市详情页内容组件
class _CityDetailPageContent extends GetView<CityDetailController> {
  const _CityDetailPageContent({required this.controllerTag});

  final String controllerTag;

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
            cityImage: controller.cityImage,
            overallScore: controller.overallScore,
            reviewCount: controller.reviewCount,
            onShare: () => _shareCityInfo(context),
          ),
          // 城市信息摘要卡片
          SliverToBoxAdapter(
            child: CityInfoSummaryCard(
              cityId: controller.cityId,
              overallScore: controller.overallScore,
              reviewCount: controller.reviewCount,
            ),
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

  TabBar _buildTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TabBar(
      controller: controller.tabController,
      isScrollable: true,
      labelColor: const Color(0xFFFF4458),
      unselectedLabelColor: Colors.grey[600],
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFFF4458),
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tabs: [
        Tab(text: l10n.scores),
        Tab(text: l10n.guide),
        Tab(text: l10n.prosAndCons),
        Tab(text: l10n.reviews),
        Tab(text: l10n.cost),
        Tab(text: l10n.photos),
        Tab(text: l10n.weather),
        Tab(text: l10n.hotels),
        Tab(text: l10n.neighborhoods),
        Tab(text: l10n.coworking),
      ],
    );
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

  // ==================== 导航方法 ====================

  void _shareCityInfo(BuildContext context) {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;
    if (city == null) return;

    // TODO: 实现分享功能
    AppToast.info('分享功能开发中...');
  }

  // ==================== Coworking 相关 ====================

  void _showAddCoworkingPage(BuildContext context) async {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;

    final result = await Get.to(() => AddCoworkingPage(
          cityName: controller.cityName,
          cityId: controller.cityId,
          countryName: city?.country,
        ));

    if (result != null) {
      AppToast.success(
        'Your coworking space will be reviewed and added soon!',
        title: 'Success',
      );
    }
  }

  // ==================== AI 生成相关 ====================

  Future<bool> _checkGeneratePermission() async {
    log('🔐 [权限检查] 开始检查生成权限...');

    // 检查是否是管理员
    try {
      final cityDetailController = Get.find<CityDetailStateController>();
      final city = cityDetailController.currentCity.value;

      if (city != null && city.isCurrentUserAdmin) {
        log('✅ [权限检查] 当前用户是管理员，允许生成');
        return true;
      }
    } catch (e) {
      log('⚠️ [权限检查] 获取城市信息失败: $e');
    }

    // 检查会员权限
    try {
      final membershipController = Get.find<MembershipStateController>();
      final membership = membershipController.membership;

      if (membership == null) {
        AppToast.error('请先登录');
        return false;
      }

      final remaining = membership.aiUsageRemaining;
      if (remaining <= 0) {
        AppToast.error('AI 使用次数已用完，请升级会员');
        return false;
      }

      log('✅ [权限检查] 会员权限检查通过，剩余次数: $remaining');
      return true;
    } catch (e) {
      log('⚠️ [权限检查] 会员检查失败: $e');
      AppToast.error('权限检查失败，请稍后再试');
      return false;
    }
  }

  void _showNearbyCitiesGenerateDialog(BuildContext context) {
    final aiController = Get.find<AiStateController>();
    _showAiGenerateProgressDialog(
      context: context,
      title: 'AI 正在生成附近城市',
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
        AppToast.success('附近城市生成成功!');
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
                    if (Navigator.of(dialogContext).canPop()) {
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
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF4458), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$progress%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFF4458),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
