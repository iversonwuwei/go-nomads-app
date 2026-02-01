import 'package:flutter/material.dart';
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
      if (controller.isLoading.value) {
        return _TravelPlanLoadingView(controllerTag: controllerTag);
      }

      if (controller.plan.value == null) {
        return const TravelPlanErrorView();
      }

      return _TravelPlanContentView(controllerTag: controllerTag);
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // AI 图标
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.containerMedium.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.wandMagicSparkles,
                            size: 40,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 进度文本
                        Text(
                          controller.progressMessage.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // 进度条
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: controller.progressValue.value / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 进度百分比
                        Text(
                          '${controller.progressValue.value}%',
                          style: TextStyle(
                            fontSize: 14,
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overview Card Skeleton
          _SkeletonCard(height: 150, shimmerController: controller.shimmerController),
          const SizedBox(height: 16),
          // Transportation Card Skeleton
          _SkeletonCard(height: 200, shimmerController: controller.shimmerController),
          const SizedBox(height: 16),
          // Accommodation Card Skeleton
          _SkeletonCard(height: 180, shimmerController: controller.shimmerController),
          const SizedBox(height: 16),
          // Itinerary Card Skeleton
          _SkeletonCard(height: 300, shimmerController: controller.shimmerController),
          const SizedBox(height: 16),
          // Loading indicator
          Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.generatingAiPlan,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 骨架卡片
class _SkeletonCard extends StatelessWidget {
  final double height;
  final AnimationController shimmerController;

  const _SkeletonCard({
    required this.height,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
                  const SizedBox(width: 12),
                  _buildShimmerBox(width: 120, height: 20, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 16),
              _buildShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
              const SizedBox(height: 10),
              _buildShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
              const SizedBox(height: 10),
              _buildShimmerBox(width: 200, height: 14, borderRadius: 4),
              const Spacer(),
              Row(
                children: [
                  _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
                  const Spacer(),
                  _buildShimmerBox(width: 60, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          begin: Alignment(-1.0 + shimmerController.value * 2, 0),
          end: Alignment(1.0 + shimmerController.value * 2, 0),
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
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

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
              Icon(icon, color: const Color(0xFFFF4458), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    final String shareUrl = 'https://nomadcities.app/travel-plans/${plan.id}';

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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: Color(0xFFFF4458),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiGeneratedPlan,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.personalizedForYou,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // 信息标签
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (departureLocation != null && departureLocation.isNotEmpty) ...[
                  _buildInfoChip(FontAwesomeIcons.plane, '${l10n.from}: $departureLocation'),
                  const SizedBox(width: 12),
                ],
                _buildInfoChip(FontAwesomeIcons.calendar, '${plan.metadata.duration} ${l10n.days}'),
                const SizedBox(width: 12),
                _buildInfoChip(FontAwesomeIcons.dollarSign, plan.metadata.budgetLevel.displayName),
                const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF4458)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
