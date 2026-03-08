import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/travel_plan/travel_plan_page_controller.dart';
import 'package:go_nomads_app/pages/travel_plan/widgets/travel_plan_accommodation_card.dart';
import 'package:go_nomads_app/pages/travel_plan/widgets/travel_plan_budget_card.dart';
import 'package:go_nomads_app/pages/travel_plan/widgets/travel_plan_day_card.dart';
import 'package:go_nomads_app/pages/travel_plan/widgets/travel_plan_overview_card.dart';
import 'package:go_nomads_app/pages/travel_plan/widgets/travel_plan_recommendation_cards.dart';
import 'package:go_nomads_app/utils/share_link_util.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/share_bottom_sheet.dart';
import 'package:go_nomads_app/widgets/share_button.dart';

/// 旅行计划详情页 - 使用 GetView 模式重构
///
/// 采用小组件组合方式构建页面，符合 GetX 标准
class TravelPlanPage extends GetView<TravelPlanPageController> {
  final TravelPlan? plan;
  final String? planId;
  final String? cityId;
  final String? cityName;
  final int? duration;
  final String? budget;
  final String? travelStyle;
  final List<String>? interests;
  final String? departureLocation;
  final DateTime? departureDate;

  const TravelPlanPage({
    super.key,
    this.plan,
    this.planId,
    this.cityId,
    this.cityName,
    this.duration,
    this.budget,
    this.travelStyle,
    this.interests,
    this.departureLocation,
    this.departureDate,
  });

  @override
  String? get tag => _generateTag();

  String _generateTag() {
    return 'travel_plan_${planId ?? cityId ?? DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final uniqueTag = _generateTag();

    // 注册 Controller
    Get.put(
      TravelPlanPageController(
        initialPlan: plan,
        planId: planId,
        cityId: cityId,
        cityName: cityName,
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        departureLocation: departureLocation,
        departureDate: departureDate,
      ),
      tag: uniqueTag,
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 延迟删除控制器，等待当前帧渲染完成
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isRegistered<TravelPlanPageController>(tag: uniqueTag)) {
              Get.delete<TravelPlanPageController>(tag: uniqueTag);
            }
          });
        }
      },
      child: _TravelPlanPageContent(controllerTag: uniqueTag),
    );
  }
}

/// 页面内容组件
class _TravelPlanPageContent extends StatelessWidget {
  final String controllerTag;

  const _TravelPlanPageContent({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final content = controller.plan.value == null
          ? const TravelPlanErrorView()
          : _TravelPlanContentView(controllerTag: controllerTag);

      return AppLoadingSwitcher(
        isLoading: controller.isLoading.value,
        loading: _TravelPlanLoadingView(controllerTag: controllerTag),
        child: content,
      );
    });
  }
}

/// 加载视图组件
class _TravelPlanLoadingView extends StatelessWidget {
  final String controllerTag;

  const _TravelPlanLoadingView({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 进度提示
            SliverToBoxAdapter(
              child: Obx(() => Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        // AI 图标
                        Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: AppColors.containerMedium.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.wandMagicSparkles,
                            size: 40.r,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // 进度文本
                        Text(
                          controller.progressMessage.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        // 进度条
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(
                            value: controller.progressValue.value / 100,
                            minHeight: 8.h,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // 进度百分比
                        Text(
                          '${controller.progressValue.value}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            // 骨架屏
            SliverToBoxAdapter(
              child: _SkeletonListView(controllerTag: controllerTag),
            ),
          ],
        ),
      ),
    );
  }
}

/// 骨架屏列表视图
class _SkeletonListView extends StatelessWidget {
  final String controllerTag;

  const _SkeletonListView({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.h,
      child: AppSceneLoading(
        scene: AppLoadingScene.travelPlan,
        fullScreen: true,
        subtitleOverride: controller.progressMessage.value,
      ),
    );
  }
}

/// 内容视图组件
class _TravelPlanContentView extends StatelessWidget {
  final String controllerTag;

  const _TravelPlanContentView({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plan = controller.plan.value!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, plan, l10n),
      body: CustomScrollView(
        slivers: [
          // Plan Overview
          SliverToBoxAdapter(
            child: _OverviewCard(plan: plan, controllerTag: controllerTag),
          ),

          // Budget Breakdown
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.budgetBreakdown,
              FontAwesomeIcons.wallet,
              TravelPlanBudgetCard(
                budget: plan.budget,
                transportationLabel: l10n.transportation,
                accommodationLabel: l10n.accommodation,
                foodLabel: l10n.foodAndDining,
                activitiesLabel: l10n.activities,
                miscellaneousLabel: l10n.miscellaneous,
                totalLabel: l10n.totalEstimatedCost,
              ),
            ),
          ),

          // Transportation
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.transportation,
              FontAwesomeIcons.plane,
              TravelPlanTransportationCard(
                transportation: plan.transportation,
                estimatedCostLabel: l10n.estimatedCost,
              ),
            ),
          ),

          // Accommodation
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.accommodation,
              FontAwesomeIcons.hotel,
              TravelPlanAccommodationCard(
                accommodation: plan.accommodation,
                pricePerNightLabel: l10n.pricePerNight,
              ),
            ),
          ),

          // Daily Itinerary
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.dailyItinerary,
              FontAwesomeIcons.noteSticky,
              Column(
                children: plan.dailyItineraries.map((day) => TravelPlanDayCard(dayItinerary: day)).toList(),
              ),
            ),
          ),

          // Must-Visit Attractions
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.mustVisitAttractions,
              FontAwesomeIcons.locationPin,
              Column(
                children:
                    plan.attractions.map((attraction) => TravelPlanAttractionCard(attraction: attraction)).toList(),
              ),
            ),
          ),

          // Recommended Restaurants
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.recommendedRestaurants,
              FontAwesomeIcons.utensils,
              Column(
                children:
                    plan.restaurants.map((restaurant) => TravelPlanRestaurantCard(restaurant: restaurant)).toList(),
              ),
            ),
          ),

          // Travel Tips
          SliverToBoxAdapter(
            child: _buildSection(
              l10n.travelTips,
              FontAwesomeIcons.lightbulb,
              Column(
                children: plan.tips.map((tip) => TravelPlanTipItem(tip: tip)).toList(),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TravelPlan plan, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: const AppBackButton(),
      title: Text(
        plan.destination.cityName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        AppShareButton(
          onPressed: () => _shareTravelPlan(context, plan),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF4458), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          content,
        ],
      ),
    );
  }

  void _shareTravelPlan(BuildContext context, TravelPlan plan) {
    // 构建分享标题
    final String cityName = plan.destination.cityName;
    final int duration = plan.metadata.duration;
    final String title = '$cityName $duration天旅行计划';

    // 构建分享描述
    final StringBuffer descBuffer = StringBuffer();
    descBuffer.writeln('🗺️ AI 智能旅行规划');
    descBuffer.writeln('📍 目的地: $cityName');
    descBuffer.writeln('📅 行程天数: $duration天');
    descBuffer.writeln('💰 预算等级: ${plan.metadata.budgetLevel.displayName}');
    descBuffer.writeln('🎯 旅行风格: ${plan.metadata.style.emoji} ${plan.metadata.style.name}');
    if (plan.tips.isNotEmpty) {
      descBuffer.writeln('\n💡 小贴士: ${plan.tips.first}');
    }

    // 构建分享链接
    final String shareUrl = ShareLinkUtil.travelPlanDetail(plan.id);

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: descBuffer.toString(),
      shareUrl: shareUrl,
    );
  }
}

/// 概览卡片
class _OverviewCard extends StatelessWidget {
  final TravelPlan plan;
  final String controllerTag;

  const _OverviewCard({required this.plan, required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final departureLocation = controller.effectiveDepartureLocation;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: Color(0xFFFF4458),
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiGeneratedPlan,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.personalizedForYou,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 16.h),
          // 信息标签
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (departureLocation != null && departureLocation.isNotEmpty) ...[
                  _buildInfoChip(FontAwesomeIcons.plane, '${l10n.from}: $departureLocation'),
                  SizedBox(width: 12.w),
                ],
                _buildInfoChip(FontAwesomeIcons.calendar, '${plan.metadata.duration} ${l10n.days}'),
                SizedBox(width: 12.w),
                _buildInfoChip(FontAwesomeIcons.dollarSign, plan.metadata.budgetLevel.displayName),
                SizedBox(width: 12.w),
                _buildInfoChip(FontAwesomeIcons.paintbrush, plan.metadata.style.name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: const Color(0xFFFF4458)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
