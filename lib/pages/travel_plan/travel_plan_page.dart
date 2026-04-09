import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/migration_workspace/presentation/widgets/workspace_plan_editor_sheet.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
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
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';
import 'package:go_nomads_app/widgets/planning/planning_launch_components.dart';
import 'package:go_nomads_app/widgets/share_bottom_sheet.dart';
import 'package:go_nomads_app/widgets/share_button.dart';

/// 旅行计划详情页 - 使用 GetView 模式重构
///
/// 采用小组件组合方式构建页面，符合 GetX 标准
class TravelPlanPage extends GetView<TravelPlanPageController> {
  final TravelPlan? plan;
  final TravelPlan? baselinePlan;
  final String? planId;
  final String? instanceTag;
  final String? cityId;
  final String? cityName;
  final int? duration;
  final String? budget;
  final String? travelStyle;
  final List<String>? interests;
  final String? departureLocation;
  final DateTime? departureDate;
  final TravelPlanSummary? workspaceSummary;

  const TravelPlanPage({
    super.key,
    this.plan,
    this.baselinePlan,
    this.planId,
    this.instanceTag,
    this.cityId,
    this.cityName,
    this.duration,
    this.budget,
    this.travelStyle,
    this.interests,
    this.departureLocation,
    this.departureDate,
    this.workspaceSummary,
  });

  @override
  String? get tag => _generateTag();

  String _generateTag() {
    return instanceTag ?? 'travel_plan_${planId ?? cityId ?? DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final uniqueTag = _generateTag();

    // 注册 Controller
    Get.put(
      TravelPlanPageController(
        initialPlan: plan,
        baselinePlan: baselinePlan,
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
      child: _TravelPlanPageContent(
        controllerTag: uniqueTag,
        workspaceSummary: workspaceSummary,
      ),
    );
  }
}

/// 页面内容组件
class _TravelPlanPageContent extends StatelessWidget {
  final String controllerTag;
  final TravelPlanSummary? workspaceSummary;

  const _TravelPlanPageContent({
    required this.controllerTag,
    required this.workspaceSummary,
  });

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final content = controller.plan.value == null
          ? const TravelPlanErrorView()
          : _TravelPlanContentView(
              controllerTag: controllerTag,
              workspaceSummary: workspaceSummary,
            );

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
  final TravelPlanSummary? workspaceSummary;

  const _TravelPlanContentView({
    required this.controllerTag,
    required this.workspaceSummary,
  });

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

          SliverToBoxAdapter(
            child: _ReplanActionCard(controllerTag: controllerTag),
          ),

          if (controller.hasReplanSummary)
            SliverToBoxAdapter(
              child: _ReplanSummaryCard(controllerTag: controllerTag),
            ),

          if (controller.showsOpenClawResearchCard)
            SliverToBoxAdapter(
              child: _OpenClawResearchCard(controllerTag: controllerTag),
            ),

          if (workspaceSummary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: _MigrationWorkspaceFocusCard(
                  summary: workspaceSummary!,
                  controllerTag: controllerTag,
                ),
              ),
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
                children: plan.dailyItineraries
                    .map(
                      (day) => TravelPlanDayCard(
                        dayItinerary: day,
                        onReplan: () => _showDayReplanSheet(context, controller, day),
                        onReplanPeriod: (period) => _showDayReplanSheet(
                          context,
                          controller,
                          day,
                          initialScope: period,
                        ),
                        availablePeriodKeys: controller.availablePeriodKeysForDay(day),
                        isHighlighted: controller.isHighlightedDay(day),
                        highlightedPeriodKey: controller.highlightedPeriodKeyForDay(day),
                      ),
                    )
                    .toList(),
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

Future<void> _showDayReplanSheet(BuildContext context, TravelPlanPageController controller, DailyItinerary dayItinerary,
    {String initialScope = 'day'}) async {
  final textController = TextEditingController();
  final availablePeriods = controller.availablePeriodKeysForDay(dayItinerary);
  final availableScopes = ['day', ...availablePeriods];
  var selectedScope = availableScopes.contains(initialScope) ? initialScope : 'day';

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      final maxSheetHeight = (mediaQuery.size.height - mediaQuery.viewInsets.bottom - mediaQuery.padding.top - 24.h)
          .clamp(240.0, mediaQuery.size.height * 0.9)
          .toDouble();

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedPeriod = selectedScope == 'day' ? null : selectedScope;
          final presets = _dayPresetOptionsForScope(selectedScope);
          final scopedActivities = controller.previewActivitiesForScope(dayItinerary, selectedPeriod);
          final selectedScopeLabel = switch (selectedScope) {
            'morning' => '上午',
            'afternoon' => '下午',
            'evening' => '晚上',
            _ => '全天',
          };

          return Padding(
            padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
            child: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: maxSheetHeight),
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 44.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: AppColors.textTertiary.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),
                      Text(
                            '重排第${dayItinerary.day}天',
                            style:
                                TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                          SizedBox(height: 14.h),
                      Text(
                        '调整范围',
                            style:
                                TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: const [
                          _ReplanScopeUi(key: 'day', label: '全天'),
                          _ReplanScopeUi(key: 'morning', label: '上午'),
                          _ReplanScopeUi(key: 'afternoon', label: '下午'),
                          _ReplanScopeUi(key: 'evening', label: '晚上'),
                        ]
                            .where((scope) => availableScopes.contains(scope.key))
                            .map(
                              (scope) => _ReplanScopeChip(
                                scope: scope,
                                isSelected: selectedScope == scope.key,
                                onTap: () => setSheetState(() => selectedScope = scope.key),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '快捷调整',
                            style:
                                TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: presets
                            .map(
                              (preset) => _ReplanPresetButton(
                                width: (1.sw - 58.w) / 2,
                                preset: _ReplanPresetUi(
                                  key: preset.key,
                                  title: preset.title,
                                  subtitle: preset.subtitle,
                                  icon: preset.icon,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  controller.replanDayPeriodWithPreset(
                                    dayItinerary,
                                    preset.key,
                                    targetPeriod: selectedPeriod,
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                      if (scopedActivities.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Text(
                          '当前命中活动',
                              style:
                                  TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: scopedActivities
                              .take(5)
                              .map(
                                (activity) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                                  decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.56),
                                    borderRadius: BorderRadius.circular(999.r),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                                  ),
                                  child: Text(
                                    '${activity.time} ${activity.name}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (scopedActivities.length > 5) ...[
                          SizedBox(height: 8.h),
                          Text(
                            '还有 ${scopedActivities.length - 5} 个活动会被一起考虑。',
                                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                      SizedBox(height: 16.h),
                      TextField(
                        controller: textController,
                        maxLines: 4,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: selectedScope == 'day'
                              ? '输入你想保留或调整的重点' : '输入$selectedScopeLabel的调整要求',
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.62),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                                borderSide: const BorderSide(color: AppColors.cityPrimary, width: 1.4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final prompt = textController.text.trim();
                            Navigator.of(context).pop();
                            controller.replanDayPeriodWithPrompt(
                              dayItinerary,
                              prompt,
                              targetPeriod: selectedPeriod,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cityPrimary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          ),
                          child: Text('生成第${dayItinerary.day}天$selectedScopeLabel新版本'),
                        ),
                      ),
                    ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

List<_DayReplanPresetUi> _dayPresetOptionsForScope(String scope) {
  switch (scope) {
    case 'morning':
      return const [
        _DayReplanPresetUi(
          key: 'lighter-day',
          title: '上午轻一点',
          subtitle: '降低早高峰奔波和密度',
          icon: FontAwesomeIcons.featherPointed,
        ),
        _DayReplanPresetUi(
          key: 'work-first',
          title: '上午先专注工作',
          subtitle: '先稳住办公和深度时段',
          icon: FontAwesomeIcons.briefcase,
        ),
        _DayReplanPresetUi(
          key: 'local-explore',
          title: '上午慢逛开场',
          subtitle: '咖啡馆、街区和低压探索',
          icon: FontAwesomeIcons.map,
        ),
        _DayReplanPresetUi(
          key: 'rain-backup',
          title: '上午天气兜底',
          subtitle: '先切到室内与短动线',
          icon: FontAwesomeIcons.cloudRain,
        ),
      ];
    case 'afternoon':
      return const [
        _DayReplanPresetUi(
          key: 'lighter-day',
          title: '午后降密度',
          subtitle: '减少连轴转和跨区移动',
          icon: FontAwesomeIcons.featherPointed,
        ),
        _DayReplanPresetUi(
          key: 'work-first',
          title: '午后工作块',
          subtitle: '保留一段稳定办公窗口',
          icon: FontAwesomeIcons.briefcase,
        ),
        _DayReplanPresetUi(
          key: 'local-explore',
          title: '午后在地探索',
          subtitle: '更适合街区漫游和小店停留',
          icon: FontAwesomeIcons.map,
        ),
        _DayReplanPresetUi(
          key: 'rain-backup',
          title: '午后天气兜底',
          subtitle: '把暴晒或阵雨风险降下来',
          icon: FontAwesomeIcons.cloudRain,
        ),
      ];
    case 'evening':
      return const [
        _DayReplanPresetUi(
          key: 'lighter-day',
          title: '晚上轻松点',
          subtitle: '少折返，早点收束节奏',
          icon: FontAwesomeIcons.featherPointed,
        ),
        _DayReplanPresetUi(
          key: 'work-first',
          title: '晚上收束工作',
          subtitle: '保留低干扰收尾和恢复时间',
          icon: FontAwesomeIcons.briefcase,
        ),
        _DayReplanPresetUi(
          key: 'local-explore',
          title: '晚间本地体验',
          subtitle: '夜市、散步和夜生活优先',
          icon: FontAwesomeIcons.map,
        ),
        _DayReplanPresetUi(
          key: 'rain-backup',
          title: '夜间天气兜底',
          subtitle: '优先室内备选和返程方便',
          icon: FontAwesomeIcons.cloudRain,
        ),
      ];
    default:
      return const [
        _DayReplanPresetUi(
          key: 'lighter-day',
          title: '调轻一点',
          subtitle: '减少奔波，保留重点',
          icon: FontAwesomeIcons.featherPointed,
        ),
        _DayReplanPresetUi(
          key: 'work-first',
          title: '白天工作优先',
          subtitle: '晚间再安排活动',
          icon: FontAwesomeIcons.briefcase,
        ),
        _DayReplanPresetUi(
          key: 'local-explore',
          title: '更像本地人',
          subtitle: '街区漫游和在地体验',
          icon: FontAwesomeIcons.map,
        ),
        _DayReplanPresetUi(
          key: 'rain-backup',
          title: '天气兜底版',
          subtitle: '加室内备选与短动线',
          icon: FontAwesomeIcons.cloudRain,
        ),
      ];
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
    final preferenceCount = plan.metadata.interests.where((item) => !item.startsWith('openclaw_')).length;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: CockpitPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF102542), Color(0xFF264653)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRAVEL BRIEF',
                    style: TextStyle(
                      fontSize: 10.sp,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.wandMagicSparkles,
                          color: Colors.white,
                          size: 18.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Travel Brief',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '${plan.destination.cityName} · ${controller.planningModeLabel} · ${controller.planningObjectiveLabel}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      PlanningStageChip(
                        label: 'Travel Brief',
                        value: l10n.durationDays('${plan.metadata.duration}'),
                        minWidth: 104.w,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.16),
                        labelColor: Colors.white.withValues(alpha: 0.72),
                        valueColor: Colors.white,
                      ),
                      PlanningStageChip(
                        label: 'Preference Stack',
                        value: '$preferenceCount picks · ${plan.metadata.style.name}',
                        minWidth: 104.w,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.16),
                        labelColor: Colors.white.withValues(alpha: 0.72),
                        valueColor: Colors.white,
                      ),
                      PlanningStageChip(
                        label: 'Research Launch',
                        value: controller.planningModeLabel,
                        minWidth: 104.w,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.16),
                        labelColor: Colors.white.withValues(alpha: 0.72),
                        valueColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  if (departureLocation != null && departureLocation.isNotEmpty) ...[
                    _OverviewMetricTile(
                      icon: FontAwesomeIcons.plane,
                      label: l10n.from,
                      value: departureLocation,
                    ),
                  ],
                  _OverviewMetricTile(
                    icon: FontAwesomeIcons.calendar,
                    label: l10n.duration,
                    value: '${plan.metadata.duration}',
                  ),
                  _OverviewMetricTile(
                    icon: FontAwesomeIcons.dollarSign,
                    label: l10n.budget,
                    value: plan.metadata.budgetLevel.displayName,
                  ),
                  _OverviewMetricTile(
                    icon: FontAwesomeIcons.paintbrush,
                    label: l10n.travelStyle,
                    value: plan.metadata.style.name,
                  ),
                  _OverviewMetricTile(
                    icon: FontAwesomeIcons.binoculars,
                    label: 'Research Launch',
                    value: controller.planningModeLabel,
                  ),
                  _OverviewMetricTile(
                    icon: FontAwesomeIcons.bullseye,
                    label: 'Preference Stack',
                    value: controller.planningObjectiveLabel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145.w,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13.r, color: AppColors.cityPrimary),
            SizedBox(height: 10.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenClawResearchCard extends StatelessWidget {
  final String controllerTag;

  const _OpenClawResearchCard({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final signalLabels = controller.researchSignalLabels;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6EF), Color(0xFFFFFBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFD9BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A57).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(FontAwesomeIcons.binoculars, color: const Color(0xFFFF7A57), size: 18.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Research launch context',
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      controller.planningModeDescription,
                      style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _ResearchChip(
                icon: FontAwesomeIcons.layerGroup,
                label: controller.planningModeLabel,
              ),
              _ResearchChip(
                icon: FontAwesomeIcons.bullseye,
                label: controller.planningObjectiveLabel,
              ),
              _ResearchChip(
                icon: FontAwesomeIcons.route,
                label: controller.replanScopeLabel,
              ),
              ...signalLabels.map(
                (label) => _ResearchChip(
                  icon: FontAwesomeIcons.satelliteDish,
                  label: label,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.openClawSummary ??
                      (signalLabels.isEmpty
                          ? 'The current draft is leaning on static preferences only, so this round will stay close to your existing brief.'
                          : 'This round promotes ${signalLabels.join('、')} into active research signals so the next draft can react to real on-the-ground context.'),
                  style: TextStyle(fontSize: 13.sp, height: 1.55, color: Colors.black87),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5ED),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFFFE0CC)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(FontAwesomeIcons.arrowsSplitUpAndLeft, size: 13.r, color: const Color(0xFFFF7A57)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '${controller.replanScopeLabel}: ${controller.replanScopeDescription}',
                          style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.activeResearchSignalLabels.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ResearchListBlock(
                    title: 'Active signals',
                    icon: FontAwesomeIcons.satelliteDish,
                    items: controller.activeResearchSignalLabels,
                  ),
                ],
                if (controller.openClawInsights.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ResearchListBlock(
                    title: 'Research findings',
                    icon: FontAwesomeIcons.magnifyingGlass,
                    items: controller.openClawInsights,
                  ),
                ],
                if (controller.openClawChecks.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ResearchListBlock(
                    title: 'Execution checks',
                    icon: FontAwesomeIcons.clipboardCheck,
                    items: controller.openClawChecks,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MigrationWorkspaceFocusCard extends StatelessWidget {
  final TravelPlanSummary summary;
  final String controllerTag;

  const _MigrationWorkspaceFocusCard({
    required this.summary,
    required this.controllerTag,
  });

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  Future<void> _editWorkspace(BuildContext context) async {
    final result = await showWorkspacePlanEditor(context, summary);
    if (result == null) {
      return;
    }

    await controller.saveWorkspaceState(
      plan: summary,
      stage: result.stage,
      focusNote: result.focusNote,
      checklist: result.checklist,
      timeline: result.timeline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final checklistPreview = summary.checklist.take(3).toList(growable: false);
    final timelinePreview = summary.timeline.take(3).toList(growable: false);
    final totalTasks = summary.totalTaskCount == 0 ? summary.checklist.length : summary.totalTaskCount;
    final completedTasks = summary.completedTaskCount == 0
        ? summary.checklist.where((item) => item.isCompleted).length
        : summary.completedTaskCount;

    return CockpitPanel(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.migrationWorkspaceFocusTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      summary.focusNote?.trim().isNotEmpty == true
                          ? summary.focusNote!.trim()
                          : 'Keep the move plan visible so the trip brief, checklist, and timeline stay aligned.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Obx(
                () => controller.isSavingWorkspace.value
                    ? Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cityPrimary),
                          ),
                        ),
                      )
                    : CockpitGlassIconButton(
                        icon: FontAwesomeIcons.penToSquare,
                        iconColor: AppColors.textPrimary,
                        onTap: () => _editWorkspace(context),
                      ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (summary.migrationStage.isNotEmpty)
                _WorkspaceSignalPill(
                  icon: FontAwesomeIcons.flagCheckered,
                  label: '${l10n.migrationWorkspaceStageLabel} ${summary.migrationStage}',
                ),
              _WorkspaceSignalPill(
                icon: FontAwesomeIcons.listCheck,
                label:
                    '$completedTasks/${totalTasks == 0 ? checklistPreview.length : totalTasks} ${l10n.migrationWorkspaceChecklistLabel}',
              ),
              if (summary.departureDate != null)
                _WorkspaceSignalPill(
                  icon: FontAwesomeIcons.planeDeparture,
                  label: '${l10n.migrationWorkspaceDepartureDate} ${summary.formattedDepartureDate}',
                ),
              if (summary.timeline.isNotEmpty)
                _WorkspaceSignalPill(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  label: '${summary.timeline.length} ${l10n.migrationWorkspaceTimelineLabel}',
                ),
            ],
          ),
          if (checklistPreview.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _WorkspaceBlock(
              title: l10n.migrationWorkspaceChecklistLabel,
              icon: FontAwesomeIcons.listCheck,
              child: Column(
                children: checklistPreview
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _WorkspaceChecklistRow(item: item),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
          if (timelinePreview.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _WorkspaceBlock(
              title: l10n.migrationWorkspaceTimelineLabel,
              icon: FontAwesomeIcons.clockRotateLeft,
              child: Column(
                children: timelinePreview
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _WorkspaceTimelineRow(item: item),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkspaceSignalPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WorkspaceSignalPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: AppColors.cityPrimary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _WorkspaceBlock({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.r, color: AppColors.cityPrimary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _WorkspaceChecklistRow extends StatelessWidget {
  final MigrationChecklistItem item;

  const _WorkspaceChecklistRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.isCompleted ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circle,
          size: 14.r,
          color: item.isCompleted ? const Color(0xFF10B981) : AppColors.textTertiary,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            item.title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceTimelineRow extends StatelessWidget {
  final MigrationTimelineItem item;

  const _WorkspaceTimelineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateLabel = item.targetDate == null
        ? item.status
        : '${item.targetDate!.month.toString().padLeft(2, '0')}/${item.targetDate!.day.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.cityPrimaryLight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.cityPrimary,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReplanActionCard extends StatelessWidget {
  final String controllerTag;

  const _ReplanActionCard({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  static const _presets = [
    _ReplanPresetUi(
      key: 'remote-work',
      title: '更适合远程工作',
      subtitle: '加强共享办公和通勤效率',
      icon: FontAwesomeIcons.laptop,
      accentColor: Color(0xFF3D6DCC),
      softColor: Color(0xFFEFF4FF),
    ),
    _ReplanPresetUi(
      key: 'save-budget',
      title: '压缩预算',
      subtitle: '优先削减高溢价项目',
      icon: FontAwesomeIcons.wallet,
      accentColor: Color(0xFF1F8A70),
      softColor: Color(0xFFEDF9F4),
    ),
    _ReplanPresetUi(
      key: 'more-explore',
      title: '增加城市探索',
      subtitle: '更像本地人一样逛',
      icon: FontAwesomeIcons.compass,
      accentColor: Color(0xFFC96B1A),
      softColor: Color(0xFFFFF4E9),
    ),
    _ReplanPresetUi(
      key: 'weather-safe',
      title: '按天气重排',
      subtitle: '把天气风险降下来',
      icon: FontAwesomeIcons.cloudSun,
      accentColor: Color(0xFF7B5CC9),
      softColor: Color(0xFFF4F0FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final signalLabels = controller.activeResearchSignalLabels;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCFA), Color(0xFFFFF5F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFE2D1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A57).withValues(alpha: 0.10),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 14.h),
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6958), Color(0xFFFF9460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A57).withValues(alpha: 0.16),
                    blurRadius: 16.r,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.wandMagicSparkles, size: 12.r, color: Colors.white),
                        SizedBox(width: 6.w),
                        Text(
                          'Research Launch',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '发起下一轮调整',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              controller.replanScopeDescription,
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.45,
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _ResearchChip(icon: FontAwesomeIcons.route, label: controller.replanScopeLabel),
                      _ResearchChip(icon: FontAwesomeIcons.bullseye, label: controller.planningObjectiveLabel),
                      _ResearchChip(icon: FontAwesomeIcons.magnifyingGlassChart, label: controller.planningModeLabel),
                      if (signalLabels.isNotEmpty)
                        _ResearchChip(
                          icon: FontAwesomeIcons.waveSquare,
                          label: signalLabels.join(' · '),
                        ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: PlanningStageChip(
                          label: 'Travel Brief',
                          value: controller.replanScopeLabel,
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          borderColor: Colors.white.withValues(alpha: 0.14),
                          labelColor: Colors.white.withValues(alpha: 0.72),
                          valueColor: Colors.white,
                          padding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: PlanningStageChip(
                          label: 'Preference Stack',
                          value: controller.planningObjectiveLabel,
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          borderColor: Colors.white.withValues(alpha: 0.14),
                          labelColor: Colors.white.withValues(alpha: 0.72),
                          valueColor: Colors.white,
                          padding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: PlanningStageChip(
                          label: 'Research Launch',
                          value: controller.planningModeLabel,
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          borderColor: Colors.white.withValues(alpha: 0.14),
                          labelColor: Colors.white.withValues(alpha: 0.72),
                          valueColor: Colors.white,
                          padding: EdgeInsets.all(12.w),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Launch lanes',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                SizedBox(height: 10.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final presetWidth = (constraints.maxWidth - 12.w) / 2;

                    return Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: _presets
                          .map(
                            (preset) => _ReplanPresetButton(
                              width: presetWidth,
                              preset: preset,
                              onTap: () => controller.replanWithPreset(preset.key),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFFFE3D6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E8),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(FontAwesomeIcons.penToSquare, size: 15.r, color: const Color(0xFFFF7A57)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prompt override',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              controller.planningModeDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                height: 1.4,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      FilledButton.tonalIcon(
                        onPressed: () => _showCustomReplanSheet(context),
                        icon: Icon(FontAwesomeIcons.penToSquare, size: 13.r),
                        label: const Text('自定义'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE8E4),
                          foregroundColor: const Color(0xFFFF5C48),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomReplanSheet(BuildContext context) async {
    final textController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final maxSheetHeight = (mediaQuery.size.height - mediaQuery.viewInsets.bottom - mediaQuery.padding.top - 24.h)
            .clamp(240.0, mediaQuery.size.height * 0.9)
            .toDouble();

        return Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '调整路线',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: '输入你的调整要求...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(color: Color(0xFFFF4458), width: 1.4),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final prompt = textController.text.trim();
                          Navigator.of(context).pop();
                          controller.replanWithPrompt(prompt);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4458),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: const Text('生成调整后的方案'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReplanSummaryCard extends StatelessWidget {
  final String controllerTag;

  const _ReplanSummaryCard({required this.controllerTag});

  TravelPlanPageController get controller => Get.find<TravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final request = controller.currentReplanRequest;
    final activities = controller.currentReplanActivities;
    final strategyHighlights = controller.replanStrategyHighlights;
    final impactPreviews = controller.replanImpactPreviews;
    final actualDiffHeadline = controller.actualReplanDiffHeadline;
    final actualDiffItems = controller.actualReplanDiffItems;
    if (request == null || request.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFE0CC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.sliders, size: 15.r, color: const Color(0xFFFF7A57)),
              SizedBox(width: 8.w),
              Text(
                'Research outcome',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _ResearchChip(icon: FontAwesomeIcons.route, label: controller.replanScopeLabel),
              _ResearchChip(icon: FontAwesomeIcons.bullseye, label: controller.planningObjectiveLabel),
              _ResearchChip(icon: FontAwesomeIcons.magnifyingGlassChart, label: controller.planningModeLabel),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              PlanningStageChip(label: 'Travel Brief', value: controller.replanScopeLabel, minWidth: 104.w),
              PlanningStageChip(label: 'Preference Stack', value: controller.planningObjectiveLabel, minWidth: 104.w),
              PlanningStageChip(label: 'Research Launch', value: controller.planningModeLabel, minWidth: 104.w),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            request,
            style: TextStyle(fontSize: 13.sp, height: 1.55, color: Colors.black87),
          ),
          if (actualDiffHeadline != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5ED),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFFE0CC)),
              ),
              child: Text(
                actualDiffHeadline,
                style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.black87),
              ),
            ),
          ],
          if (actualDiffItems.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _ActualDiffListBlock(
              title: 'Travel Brief delta',
              icon: FontAwesomeIcons.arrowsRotate,
              items: actualDiffItems,
            ),
          ],
          if (strategyHighlights.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _StrategyInsightListBlock(
              title: 'Preference Stack logic',
              icon: FontAwesomeIcons.wandMagicSparkles,
              items: strategyHighlights,
              resolveSourceLabels: controller.strategySourceLabels,
            ),
          ],
          if (impactPreviews.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _ImpactPreviewListBlock(
              title: 'Research impact preview',
              icon: FontAwesomeIcons.arrowsTurnToDots,
              items: impactPreviews,
              resolveSourceLabels: controller.strategySourceLabels,
            ),
          ],
          if (activities != null && activities.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Focus lane: $activities',
                style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.grey[800]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplanPresetButton extends StatelessWidget {
  final double width;
  final _ReplanPresetUi preset;
  final VoidCallback onTap;

  const _ReplanPresetButton({
    required this.width,
    required this.preset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: width,
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, preset.softColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFFE3D6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7A57).withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 4.h,
              decoration: BoxDecoration(
                color: preset.accentColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999.r),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.46,
                child: Container(
                  decoration: BoxDecoration(
                    color: preset.accentColor,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [preset.softColor, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(preset.icon, size: 16.r, color: preset.accentColor),
                ),
                const Spacer(),
                Icon(FontAwesomeIcons.arrowRightLong, size: 12.r, color: preset.accentColor.withValues(alpha: 0.45)),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              preset.title,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.3),
            ),
            SizedBox(height: 6.h),
            if (preset.subtitle.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                preset.subtitle,
                style: TextStyle(fontSize: 11.sp, height: 1.45, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReplanPresetUi {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softColor;

  const _ReplanPresetUi({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accentColor = const Color(0xFFFF684E),
    this.softColor = const Color(0xFFFFF5EF),
  });
}

class _DayReplanPresetUi {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const _DayReplanPresetUi({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ReplanScopeUi {
  final String key;
  final String label;

  const _ReplanScopeUi({
    required this.key,
    required this.label,
  });
}

class _ReplanScopeChip extends StatelessWidget {
  final _ReplanScopeUi scope;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReplanScopeChip({
    required this.scope,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4458) : const Color(0xFFFFF2F4),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: isSelected ? const Color(0xFFFF4458) : const Color(0xFFFFD9DE)),
        ),
        child: Text(
          scope.label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFFFF4458),
          ),
        ),
      ),
    );
  }
}

class _ResearchListBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _ResearchListBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.r, color: const Color(0xFFFF7A57)),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7A57),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StrategyInsightListBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ReplanStrategyHighlight> items;
  final List<String> Function(List<String>) resolveSourceLabels;

  const _StrategyInsightListBlock({
    required this.title,
    required this.icon,
    required this.items,
    required this.resolveSourceLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.r, color: const Color(0xFFFF7A57)),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...items.map((item) {
          final sourceLabels = resolveSourceLabels(item.sourceKeys);

          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFFEAD8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.black87),
                ),
                if (sourceLabels.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: sourceLabels
                        .map(
                          (label) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E8),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF7A57),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ImpactPreviewListBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ReplanImpactPreview> items;
  final List<String> Function(List<String>) resolveSourceLabels;

  const _ImpactPreviewListBlock({
    required this.title,
    required this.icon,
    required this.items,
    required this.resolveSourceLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.r, color: const Color(0xFFFF7A57)),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...items.map((item) {
          final sourceLabels = resolveSourceLabels(item.sourceKeys);

          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFFEAD8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.detail,
                  style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.grey[800]),
                ),
                if (sourceLabels.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: sourceLabels
                        .map(
                          (label) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E8),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF7A57),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ActualDiffListBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ReplanActualDiffItem> items;

  const _ActualDiffListBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.r, color: const Color(0xFFFF7A57)),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...items.map((item) {
          final tone = _actualDiffTone(item.kind);
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: tone.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: tone.foreground),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.detail,
                  style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.black87),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  _ActualDiffTone _actualDiffTone(ReplanActualDiffKind kind) {
    switch (kind) {
      case ReplanActualDiffKind.added:
        return const _ActualDiffTone(
          background: Color(0xFFF4FBF6),
          border: Color(0xFFD8EFD9),
          foreground: Color(0xFF2E7D32),
        );
      case ReplanActualDiffKind.removed:
        return const _ActualDiffTone(
          background: Color(0xFFFFF6F5),
          border: Color(0xFFFFDDD8),
          foreground: Color(0xFFC2513E),
        );
      case ReplanActualDiffKind.dayChanged:
        return const _ActualDiffTone(
          background: Color(0xFFFFFAF0),
          border: Color(0xFFFFE7BF),
          foreground: Color(0xFF9A6700),
        );
      case ReplanActualDiffKind.unchanged:
        return const _ActualDiffTone(
          background: Color(0xFFF8F8F8),
          border: Color(0xFFE7E7E7),
          foreground: Color(0xFF6B7280),
        );
      case ReplanActualDiffKind.replaced:
        return const _ActualDiffTone(
          background: Color(0xFFFFFBF7),
          border: Color(0xFFFFE0CC),
          foreground: Color(0xFFFF7A57),
        );
    }
  }
}

class _ActualDiffTone {
  final Color background;
  final Color border;
  final Color foreground;

  const _ActualDiffTone({
    required this.background,
    required this.border,
    required this.foreground,
  });
}

class _ResearchChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ResearchChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFFFD9BF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: const Color(0xFFFF7A57)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
