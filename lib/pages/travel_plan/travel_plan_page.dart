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
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '重排第${dayItinerary.day}天',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '当前主题：${dayItinerary.theme}。你可以直接调全天，也可以只改上午、下午或晚上。',
                    style: TextStyle(fontSize: 12.sp, height: 1.5, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '当前会重点影响：第${dayItinerary.day}天$selectedScopeLabel。',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFFFF7A57)),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '调整范围',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
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
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
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
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
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
                                color: const Color(0xFFFFF6EF),
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(color: const Color(0xFFFFE0CC)),
                              ),
                              child: Text(
                                '${activity.time} ${activity.name}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
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
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
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
                          ? '例如：把这一天改成半天办公 + 半天博物馆，晚上安排安静餐厅'
                          : '例如：把$selectedScopeLabel改成更轻松，减少打卡点并留出咖啡休息时间',
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
                        controller.replanDayPeriodWithPrompt(
                          dayItinerary,
                          prompt,
                          targetPeriod: selectedPeriod,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4458),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('生成第${dayItinerary.day}天$selectedScopeLabel新版本'),
                    ),
                  ),
                ],
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
                SizedBox(width: 12.w),
                _buildInfoChip(FontAwesomeIcons.binoculars, controller.planningModeLabel),
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
                      'OpenClaw 实验研究层',
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
                          ? '当前方案没有附加实时核对项，因此更偏向静态偏好驱动的路线生成。'
                          : '本次规划会把 ${signalLabels.join('、')} 作为高优先级研究线索，帮助 AI 更贴近远程工作和城市探索的真实场景。'),
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
                          '${controller.replanScopeLabel}：${controller.replanScopeDescription}',
                          style: TextStyle(fontSize: 12.sp, height: 1.45, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.activeResearchSignalLabels.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ResearchListBlock(
                    title: '本次启用信号',
                    icon: FontAwesomeIcons.satelliteDish,
                    items: controller.activeResearchSignalLabels,
                  ),
                ],
                if (controller.openClawInsights.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ResearchListBlock(
                    title: '研究发现',
                    icon: FontAwesomeIcons.magnifyingGlass,
                    items: controller.openClawInsights,
                  ),
                ],
                if (controller.openClawChecks.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ResearchListBlock(
                    title: '落地核对',
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
                          'Next Draft',
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
                              '二次重规划',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '在不推翻整份路线的前提下，把这一版往更明确的目标继续推进。',
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.92),
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
                    children: const [
                      _ReplanMetaChip(label: '保留城市上下文'),
                      _ReplanMetaChip(label: '沿用 OpenClaw 线索'),
                      _ReplanMetaChip(label: '生成下一版方案'),
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
                Row(
                  children: [
                    Text(
                      '快捷策略',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '先定方向，再出下一稿。',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = 10.w;
                    final itemWidth = (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 10.h,
                      children: _presets
                          .map(
                            (preset) => _ReplanPresetButton(
                              width: itemWidth,
                              preset: preset,
                              onTap: () => controller.replanWithPreset(preset.key),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFFFE6D8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
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
                              '需要更细的要求？',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '比如只强调预算、远程工作窗口，或者让某一天更轻松一些。',
                              style: TextStyle(fontSize: 11.sp, height: 1.45, color: Colors.grey[700]),
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
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你想怎么改这份路线？',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 8.h),
                Text(
                  '例如：把白天改成工作优先，晚上安排城市夜生活；或者把第三天改成更轻松的节奏。',
                  style: TextStyle(fontSize: 12.sp, height: 1.5, color: Colors.grey[700]),
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
    final signalLabels = controller.activeResearchSignalLabels;
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
                '本次调整摘要',
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
              ...signalLabels.map(
                (label) => _ResearchChip(
                  icon: FontAwesomeIcons.satelliteDish,
                  label: label,
                ),
              ),
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
              title: '实际变化',
              icon: FontAwesomeIcons.arrowsRotate,
              items: actualDiffItems,
            ),
          ],
          if (strategyHighlights.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _StrategyInsightListBlock(
              title: '本次策略重点',
              icon: FontAwesomeIcons.wandMagicSparkles,
              items: strategyHighlights,
              resolveSourceLabels: controller.strategySourceLabels,
            ),
          ],
          if (impactPreviews.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _ImpactPreviewListBlock(
              title: '预计变化',
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
                '本次重点活动：$activities',
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
            Text(
              preset.subtitle,
              style: TextStyle(fontSize: 11.sp, height: 1.45, color: Colors.grey[700]),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: preset.accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '点击生成这一方向',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: preset.accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplanMetaChip extends StatelessWidget {
  final String label;

  const _ReplanMetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
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
