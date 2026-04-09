import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/utils/share_link_util.dart';

import '../../features/ai/presentation/controllers/ai_state_controller.dart';
import '../../features/city/application/state_controllers/pros_cons_state_controller.dart';
import '../../features/city/presentation/controllers/city_detail_state_controller.dart';
import '../../features/membership/presentation/services/ai_quota_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/dialogs/app_bottom_drawer.dart';
import '../../widgets/share_bottom_sheet.dart';
import '../add_coworking/add_coworking_page.dart';
import '../city_photo_submission_page.dart';
import '../manage_pros_cons_page.dart';
import '../pros_and_cons_add_page.dart';
import 'city_detail_controller.dart';
import 'widgets/city_detail_app_bar.dart';
import 'widgets/tabs/cost_tab.dart';
import 'widgets/tabs/coworking_tab.dart';
import 'widgets/tabs/decision_tab.dart';
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

class _CitySectionNavItem {
  const _CitySectionNavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.accent,
    this.onAddPressed,
  });

  final int index;
  final String label;
  final IconData icon;
  final String subtitle;
  final Color accent;
  final VoidCallback? onAddPressed;
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _CitySectionNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B7A), Color(0xFFFF4458)],
                  )
                : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isActive ? Colors.transparent : const Color(0xFFE8E1D6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 12.r,
                color: isActive ? Colors.white : const Color(0xFF5B6470),
              ),
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : const Color(0xFF2A313A),
                ),
              ),
              if (item.onAddPressed != null) ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: item.onAddPressed,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white.withValues(alpha: 0.22) : const Color(0xFFFFEFF1),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Icon(
                      FontAwesomeIcons.plus,
                      size: 8.r,
                      color: isActive ? Colors.white : const Color(0xFFFF4458),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigatorIconButton extends StatelessWidget {
  const _NavigatorIconButton({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Opacity(
        opacity: isEnabled ? 1 : 0.36,
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFFFF4458) : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            icon,
            size: 13.r,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CityStickySectionNavigatorDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const _CityStickySectionNavigatorDelegate({
    required this.child,
    this.height = 148,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: Colors.white.withAlpha(200),
          child: child,
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _CityStickySectionNavigatorDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
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
    );
  }

  Widget _buildBody(BuildContext context) {
    final items = _buildSectionItems(context);
    final tabViews = _buildTabViews(context);

    return NestedScrollView(
      controller: controller.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          CityDetailAppBar(
            controller: controller,
            cityName: controller.cityName,
            cityImages: controller.cityImages,
            overallScore: controller.overallScore,
            reviewCount: controller.reviewCount,
            onShare: () => _shareCityInfo(context),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CityStickySectionNavigatorDelegate(
              child: _buildSectionNavigator(context, items),
              height: 112,
            ),
          ),
        ];
      },
      body: AnimatedBuilder(
        animation: controller.tabController,
        builder: (context, _) {
          final currentIndex = controller.tabController.index;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(currentIndex),
              child: tabViews[currentIndex],
            ),
          );
        },
      ),
    );
  }

  List<_CitySectionNavItem> _buildSectionItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final addableTabs = {
      CityDetailController.tabProsCons: () => _onTabAddPressed(context, CityDetailController.tabProsCons),
      CityDetailController.tabReviews: () => _onTabAddPressed(context, CityDetailController.tabReviews),
      CityDetailController.tabCost: () => _onTabAddPressed(context, CityDetailController.tabCost),
      CityDetailController.tabPhotos: () => _onTabAddPressed(context, CityDetailController.tabPhotos),
      CityDetailController.tabHotels: () => _onTabAddPressed(context, CityDetailController.tabHotels),
      CityDetailController.tabCoworking: () => _onTabAddPressed(context, CityDetailController.tabCoworking),
    };

    final tabLabels = [
      l10n.cityDecisionTitle,
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

    return List.generate(tabLabels.length, (index) {
      return _CitySectionNavItem(
        index: index,
        label: tabLabels[index],
        icon: _iconForSection(index),
        subtitle: _subtitleForSection(index),
        accent: _accentForSection(index),
        onAddPressed: addableTabs[index],
      );
    });
  }

  Widget _buildSectionNavigator(BuildContext context, List<_CitySectionNavItem> items) {
    return AnimatedBuilder(
      animation: controller.tabController,
      builder: (context, _) {
        final currentIndex = controller.tabController.index;
        final currentItem = items[currentIndex];
        final canGoPrev = currentIndex > 0;
        final canGoNext = currentIndex < items.length - 1;

        return Container(
          padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 6.h),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0x11000000), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF17191D), Color(0xFF2A2E35)],
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(currentItem.icon, size: 13.r, color: Colors.white),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${currentIndex + 1}/${items.length}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white60,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  currentItem.label,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _NavigatorIconButton(
                      icon: FontAwesomeIcons.grip,
                      onTap: () => _showSectionJumpSheet(context, items),
                    ),
                    SizedBox(width: 6.w),
                    if (currentItem.onAddPressed != null) ...[
                      _NavigatorIconButton(
                        icon: FontAwesomeIcons.plus,
                        onTap: currentItem.onAddPressed!,
                        highlighted: true,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    _NavigatorIconButton(
                      icon: FontAwesomeIcons.chevronLeft,
                      onTap: canGoPrev ? () => controller.tabController.animateTo(currentIndex - 1) : null,
                    ),
                    SizedBox(width: 6.w),
                    _NavigatorIconButton(
                      icon: FontAwesomeIcons.chevronRight,
                      onTap: canGoNext ? () => controller.tabController.animateTo(currentIndex + 1) : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                height: 32.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isActive = index == currentIndex;
                    return _SectionPill(
                      item: item,
                      isActive: isActive,
                      onTap: () => controller.tabController.animateTo(index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForSection(int index) {
    switch (index) {
      case CityDetailController.tabDecision:
        return FontAwesomeIcons.compass;
      case CityDetailController.tabScores:
        return FontAwesomeIcons.chartSimple;
      case CityDetailController.tabGuide:
        return FontAwesomeIcons.solidMap;
      case CityDetailController.tabProsCons:
        return FontAwesomeIcons.scaleBalanced;
      case CityDetailController.tabReviews:
        return FontAwesomeIcons.commentDots;
      case CityDetailController.tabCost:
        return FontAwesomeIcons.wallet;
      case CityDetailController.tabPhotos:
        return FontAwesomeIcons.images;
      case CityDetailController.tabWeather:
        return FontAwesomeIcons.cloudSun;
      case CityDetailController.tabHotels:
        return FontAwesomeIcons.hotel;
      case CityDetailController.tabNeighborhoods:
        return FontAwesomeIcons.mapLocationDot;
      case CityDetailController.tabCoworking:
        return FontAwesomeIcons.laptop;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  String _subtitleForSection(int index) {
    switch (index) {
      case CityDetailController.tabDecision:
        return 'Start with the city fit, signals, and recommended next moves.';
      case CityDetailController.tabScores:
        return 'See category ratings without mixing them into the decision brief.';
      case CityDetailController.tabGuide:
        return 'Read the narrative guide, local context, and AI-generated framing.';
      case CityDetailController.tabProsCons:
        return 'Balance field-reported upsides and tradeoffs before committing.';
      case CityDetailController.tabReviews:
        return 'Check firsthand reports and add your own city experience.';
      case CityDetailController.tabCost:
        return 'Estimate the monthly burn and compare core spending categories.';
      case CityDetailController.tabPhotos:
        return 'Scan the visual moodboard and contribute fresh city images.';
      case CityDetailController.tabWeather:
        return 'Understand seasonality, forecast, and climate comfort.';
      case CityDetailController.tabHotels:
        return 'Scout sleep bases, price ranges, and remote-work-friendly stays.';
      case CityDetailController.tabNeighborhoods:
        return 'Explore nearby areas and adjacent places worth comparing.';
      case CityDetailController.tabCoworking:
        return 'Review work hubs, network quality, and workspace trust signals.';
      default:
        return '';
    }
  }

  Color _accentForSection(int index) {
    switch (index) {
      case CityDetailController.tabDecision:
        return const Color(0xFF1E5C7A);
      case CityDetailController.tabScores:
        return const Color(0xFF7A4A1E);
      case CityDetailController.tabGuide:
        return const Color(0xFF2F6A48);
      case CityDetailController.tabProsCons:
        return const Color(0xFF7B3559);
      case CityDetailController.tabReviews:
        return const Color(0xFF6A4A8C);
      case CityDetailController.tabCost:
        return const Color(0xFF7B5A24);
      case CityDetailController.tabPhotos:
        return const Color(0xFF235D5D);
      case CityDetailController.tabWeather:
        return const Color(0xFF3C73A8);
      case CityDetailController.tabHotels:
        return const Color(0xFF8A4D2A);
      case CityDetailController.tabNeighborhoods:
        return const Color(0xFF3E6F60);
      case CityDetailController.tabCoworking:
        return const Color(0xFF5B3D87);
      default:
        return const Color(0xFF5B6470);
    }
  }

  void _showSectionJumpSheet(BuildContext context, List<_CitySectionNavItem> items) {
    AppBottomDrawer.show<void>(
      context,
      title: 'Browse Sections',
      maxHeightFactor: 0.72,
      child: AnimatedBuilder(
        animation: controller.tabController,
        builder: (context, _) {
          final currentIndex = controller.tabController.index;
          return ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1.h, color: const Color(0xFFEAE3D8)),
            itemBuilder: (context, index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return ListTile(
                onTap: () {
                  Get.back<void>();
                  controller.tabController.animateTo(index);
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                leading: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFFFEFF1) : const Color(0xFFF5F1EA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    item.icon,
                    size: 16.r,
                    color: isActive ? const Color(0xFFFF4458) : const Color(0xFF5B6470),
                  ),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isActive ? const Color(0xFFFF4458) : const Color(0xFF20262E),
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.35,
                      color: const Color(0xFF66707D),
                    ),
                  ),
                ),
                trailing: isActive
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFF1),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF4458),
                          ),
                        ),
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A94A1),
                        ),
                      ),
              );
            },
          );
        },
      ),
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
      DecisionTab(tag: controllerTag),
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
    final String shareUrl = ShareLinkUtil.cityDetail(city.id.toString());

    // 封面图
    final String imageUrl = city.displayImageUrl;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (statusWorker == null) {
        final aiController = Get.find<AiStateController>();
        statusWorker = ever(
          aiController.isNearbyCitiesCompletedRx,
          (completed) {
            if (completed) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if ((Get.isBottomSheetOpen ?? false)) {
                  Get.back<void>();
                }
                statusWorker?.dispose();
                statusWorker = null;
                Future.delayed(const Duration(milliseconds: 500), onComplete);
              });
            }
          },
        );
      }
    });

    AppBottomDrawer.show<void>(
      context,
      title: title,
      maxHeightFactor: 0.44,
      isDismissible: false,
      enableDrag: false,
      child: Obx(() {
        final progress = progressGetter();
        final message = messageGetter();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFF4458), size: 28.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$progress%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: const Color(0xFFFF4458),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
