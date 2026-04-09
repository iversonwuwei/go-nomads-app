import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/planning/planning_launch_components.dart';

import '../travel_plan/travel_plan_page.dart';
import 'widgets/widgets.dart';

/// 创建旅行计划页面 - 使用 GetX + 组件化架构重构
class CreateTravelPlanPage extends GetView<CreateTravelPlanPageController> {
  static const String controllerTag = CreateTravelPlanPageController.controllerTag;
  final bool embeddedInBottomNav;

  const CreateTravelPlanPage({super.key, this.embeddedInBottomNav = false});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 延迟删除控制器，等待当前帧渲染完成。
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
              Get.delete<CreateTravelPlanPageController>(tag: controllerTag);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: _CreateTravelPlanBody(
          controllerTag: controllerTag,
          embeddedInBottomNav: embeddedInBottomNav,
        ),
        bottomNavigationBar: embeddedInBottomNav ? null : const _BottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: embeddedInBottomNav ? null : const AppBackButton(color: AppColors.backButtonDark),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              FontAwesomeIcons.wandMagicSparkles,
              color: Color(0xFFFF4458),
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiTravelPlanner,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  controller.cityName.isNotEmpty ? l10n.planYourTrip(controller.cityName) : l10n.selectDestination,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          const _MembershipExclusiveBadge(),
        ],
      ),
    );
  }
}

class _CreateTravelPlanBody extends StatefulWidget {
  final String controllerTag;
  final bool embeddedInBottomNav;

  const _CreateTravelPlanBody({
    required this.controllerTag,
    required this.embeddedInBottomNav,
  });

  @override
  State<_CreateTravelPlanBody> createState() => _CreateTravelPlanBodyState();
}

class _CreateTravelPlanBodyState extends State<_CreateTravelPlanBody> {
  late final ScrollController _scrollController;
  late final CreateTravelPlanPageController _controller;
  late final List<GlobalKey> _stageKeys;
  int _activeStage = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CreateTravelPlanPageController>(tag: widget.controllerTag);
    _scrollController = ScrollController()..addListener(_handleScroll);
    _stageKeys = List<GlobalKey>.generate(3, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) {
      return;
    }

    final anchor = MediaQuery.paddingOf(context).top + kToolbarHeight + 88.h;
    var nextStage = _activeStage;
    var nearestDistance = double.infinity;

    for (var index = 0; index < _stageKeys.length; index++) {
      final stageContext = _stageKeys[index].currentContext;
      final renderBox = stageContext?.findRenderObject() as RenderBox?;

      if (renderBox == null || !renderBox.attached) {
        continue;
      }

      final top = renderBox.localToGlobal(Offset.zero).dy;
      final distance = (top - anchor).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nextStage = index;
      }
    }

    if (nextStage != _activeStage) {
      setState(() {
        _activeStage = nextStage;
      });
    }
  }

  Future<void> _scrollToStage(int index) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _activeStage = index;
    });

    final stageContext = _stageKeys[index].currentContext;
    if (stageContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      stageContext,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stages = <_CreatePlanStageMeta>[
      _CreatePlanStageMeta(
        label: l10n.destination,
        title: 'Travel Brief',
        icon: FontAwesomeIcons.route,
        color: const Color(0xFFFF4458),
      ),
      _CreatePlanStageMeta(
        label: l10n.travelStyle,
        title: 'Preference Stack',
        icon: FontAwesomeIcons.sliders,
        color: const Color(0xFF2E9B7F),
      ),
      _CreatePlanStageMeta(
        label: l10n.generatePlan,
        title: 'Research Launch',
        icon: FontAwesomeIcons.wandMagicSparkles,
        color: const Color(0xFF2667FF),
      ),
    ];

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        children: [
          _HeaderCard(controllerTag: widget.controllerTag),
          _CreatePlanMissionShell(
            controllerTag: widget.controllerTag,
            stages: stages,
            activeStage: _activeStage,
            onStageSelected: _scrollToStage,
          ),
          _CreatePlanStageSection(
            key: _stageKeys[0],
            accentColor: stages[0].color,
            icon: stages[0].icon,
            eyebrow: '01',
            title: stages[0].title,
            label: stages[0].label,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelPlanDestinationSection(controllerTag: widget.controllerTag),
                SizedBox(height: 28.h),
                TravelPlanDepartureSection(controllerTag: widget.controllerTag),
                SizedBox(height: 28.h),
                TravelPlanDateSection(controllerTag: widget.controllerTag),
              ],
            ),
          ),
          _CreatePlanStageSection(
            key: _stageKeys[1],
            accentColor: stages[1].color,
            icon: stages[1].icon,
            eyebrow: '02',
            title: stages[1].title,
            label: stages[1].label,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TravelPlanDurationSection(),
                SizedBox(height: 28.h),
                const TravelPlanBudgetSection(),
                SizedBox(height: 28.h),
                const TravelPlanAttractionsSection(),
                SizedBox(height: 28.h),
                const TravelPlanStyleSection(),
                SizedBox(height: 28.h),
                const TravelPlanInterestsSection(),
              ],
            ),
          ),
          _CreatePlanStageSection(
            key: _stageKeys[2],
            accentColor: stages[2].color,
            icon: stages[2].icon,
            eyebrow: '03',
            title: stages[2].title,
            label: stages[2].label,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelPlanOpenClawSection(
                  onStrategyTap: (planningMode) => _launchTravelPlanFromCreatePage(
                    context,
                    _controller,
                    overridePlanningMode: planningMode,
                  ),
                ),
                SizedBox(height: 28.h),
                _LaunchReadinessCard(
                  controllerTag: widget.controllerTag,
                  showInlineButton: widget.embeddedInBottomNav,
                ),
              ],
            ),
          ),
          SizedBox(height: widget.embeddedInBottomNav ? 20.h : 120.h),
        ],
      ),
    );
  }
}

class _CreatePlanMissionShell extends StatelessWidget {
  final String controllerTag;
  final List<_CreatePlanStageMeta> stages;
  final int activeStage;
  final ValueChanged<int> onStageSelected;

  const _CreatePlanMissionShell({
    required this.controllerTag,
    required this.stages,
    required this.activeStage,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<CreateTravelPlanPageController>(tag: controllerTag);

    return Obx(() {
      final previewItems = _buildPreviewItems(l10n, controller);
      return Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF4F5), Color(0xFFF7F9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFFF4458).withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.createTravelPlan,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        controller.cityName.isNotEmpty ? l10n.planYourTrip(controller.cityName) : l10n.aiTravelPlanner,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: stages[activeStage].color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '${activeStage + 1}/${stages.length}',
                    style: TextStyle(
                      color: stages[activeStage].color,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: (activeStage + 1) / stages.length,
                minHeight: 8.h,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(stages[activeStage].color),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List<Widget>.generate(
                stages.length,
                (index) => _CreatePlanStagePill(
                  label: stages[index].label,
                  icon: stages[index].icon,
                  color: stages[index].color,
                  isActive: activeStage == index,
                  onTap: () => onStageSelected(index),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Wrap(
                key: ValueKey<int>(activeStage),
                spacing: 12.w,
                runSpacing: 12.h,
                children: previewItems[activeStage]
                    .map(
                      (item) => SizedBox(
                        width: 146.w,
                        child: PlanningPreviewCard(
                          title: item.title,
                          value: item.value,
                          icon: item.icon,
                          tint: stages[activeStage].color,
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<List<_CreatePlanPreviewItem>> _buildPreviewItems(
    AppLocalizations l10n,
    CreateTravelPlanPageController controller,
  ) {
    final date = controller.departureDate.value;
    final dateText = date == null
        ? l10n.selectDate
        : '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final interestCount = controller.interests.length + controller.selectedAttractions.length;

    return [
      [
        _CreatePlanPreviewItem(
          title: l10n.destination,
          value: controller.cityName.isNotEmpty ? controller.cityName : l10n.selectDestination,
          icon: FontAwesomeIcons.locationDot,
        ),
        _CreatePlanPreviewItem(
          title: l10n.departureLocation,
          value: controller.departureLocation.value.isNotEmpty
              ? controller.departureLocation.value
              : l10n.selectDeparture,
          icon: FontAwesomeIcons.planeDeparture,
        ),
        _CreatePlanPreviewItem(
          title: l10n.date,
          value: dateText,
          icon: FontAwesomeIcons.calendarDay,
        ),
      ],
      [
        _CreatePlanPreviewItem(
          title: l10n.tripDuration,
          value: '${controller.duration.value} d',
          icon: FontAwesomeIcons.clock,
        ),
        _CreatePlanPreviewItem(
          title: l10n.budget,
          value: controller.getFinalBudget(),
          icon: FontAwesomeIcons.wallet,
        ),
        _CreatePlanPreviewItem(
          title: l10n.interests,
          value: interestCount > 0 ? '$interestCount selected' : l10n.selectInterests,
          icon: FontAwesomeIcons.layerGroup,
        ),
      ],
      [
        _CreatePlanPreviewItem(
          title: 'OpenClaw',
          value: controller.planningModeLabel,
          icon: FontAwesomeIcons.magnifyingGlassChart,
        ),
        _CreatePlanPreviewItem(
          title: 'Signals',
          value: controller.openClawSignals.isNotEmpty
              ? controller.openClawSignals.join(', ')
              : 'No signals',
          icon: FontAwesomeIcons.waveSquare,
        ),
        _CreatePlanPreviewItem(
          title: l10n.generatePlan,
          value: controller.hasSelectedDestination ? 'Ready' : l10n.selectDestination,
          icon: FontAwesomeIcons.rocket,
        ),
      ],
    ];
  }
}

class _CreatePlanStageSection extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String label;
  final Widget child;

  const _CreatePlanStageSection({
    super.key,
    required this.accentColor,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: accentColor, size: 18.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          child,
        ],
      ),
    );
  }
}

class _CreatePlanStagePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _CreatePlanStagePill({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: isActive ? color : Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: isActive ? Colors.white : Colors.black54),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchReadinessCard extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;
  final bool showInlineButton;

  const _LaunchReadinessCard({
    required this.controllerTag,
    required this.showInlineButton,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final summaryItems = <_CreatePlanPreviewItem>[
        _CreatePlanPreviewItem(
          title: l10n.destination,
          value: controller.cityName.isNotEmpty ? controller.cityName : l10n.selectDestination,
          icon: FontAwesomeIcons.locationDot,
        ),
        _CreatePlanPreviewItem(
          title: l10n.tripDuration,
          value: '${controller.duration.value} d',
          icon: FontAwesomeIcons.clock,
        ),
        _CreatePlanPreviewItem(
          title: l10n.budget,
          value: controller.getFinalBudget(),
          icon: FontAwesomeIcons.wallet,
        ),
      ];

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF4FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFF2667FF).withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2667FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.rocket,
                    color: const Color(0xFF2667FF),
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.generatePlan,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.hasSelectedDestination ? controller.planningModeLabel : l10n.selectDestination,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: summaryItems
                  .map(
                    (item) => SizedBox(
                      width: 146.w,
                      child: PlanningPreviewCard(
                        title: item.title,
                        value: item.value,
                        icon: item.icon,
                        tint: const Color(0xFF2667FF),
                        backgroundColor: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                PlanningStageChip(
                  label: 'Travel Brief',
                  value: controller.cityName.isNotEmpty ? controller.cityName : l10n.selectDestination,
                  minWidth: 104.w,
                ),
                PlanningStageChip(
                  label: 'Preference Stack',
                  value: controller.getFinalBudget(),
                  minWidth: 104.w,
                ),
                PlanningStageChip(
                  label: 'Research Launch',
                  value: controller.planningModeLabel,
                  minWidth: 104.w,
                ),
              ],
            ),
            if (showInlineButton) ...[
              SizedBox(height: 18.h),
              const _GeneratePlanButton(),
            ],
          ],
        ),
      );
    });
  }
}

class _CreatePlanStageMeta {
  final String label;
  final String title;
  final IconData icon;
  final Color color;

  const _CreatePlanStageMeta({
    required this.label,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _CreatePlanPreviewItem {
  final String title;
  final String value;
  final IconData icon;

  const _CreatePlanPreviewItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _HeaderCard extends StatelessWidget {
  final String controllerTag;

  const _HeaderCard({required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<CreateTravelPlanPageController>(tag: controllerTag);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.wandMagicSparkles, color: Colors.white, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                l10n.aiPoweredPlanning,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              controller.cityName.isNotEmpty
                  ? '已为你预填 ${controller.cityName}，你也可以在下方重新选择目的地后再生成 AI 行程。'
                  : '请先选择旅行目的地，再设定偏好并决定是否启用 OpenClaw 研究增强。',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '会员专享：AI 旅行规划师仅对有效会员开放。',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _StepBadge(label: '1 偏好输入'),
              _StepBadge(label: '2 OpenClaw 研究'),
              _StepBadge(label: '3 AI 成稿'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final String label;

  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MembershipExclusiveBadge extends StatelessWidget {
  const _MembershipExclusiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFFF4458).withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, color: const Color(0xFFFF4458), size: 14.r),
          SizedBox(width: 4.w),
          Text(
            '会员专享',
            style: TextStyle(
              color: const Color(0xFFFF4458),
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends GetView<CreateTravelPlanPageController> {
  const _BottomBar();

  @override
  String? get tag => CreateTravelPlanPageController.controllerTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: const _GeneratePlanButton(),
      ),
    );
  }
}

class _GeneratePlanButton extends GetView<CreateTravelPlanPageController> {
  const _GeneratePlanButton();

  @override
  String? get tag => CreateTravelPlanPageController.controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(
      () => ElevatedButton(
        onPressed: () => _generatePlan(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4458),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          minimumSize: Size(double.infinity, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.wandMagicSparkles, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              controller.planningMode.value == 'research' ? '开始 OpenClaw 研究规划' : l10n.generatePlan,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.3.sp),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePlan(BuildContext context) {
    _launchTravelPlanFromCreatePage(
      context,
      controller,
    );
  }
}

void _launchTravelPlanFromCreatePage(
  BuildContext context,
  CreateTravelPlanPageController controller, {
  String? overridePlanningMode,
}) {
  final l10n = AppLocalizations.of(context)!;

  if (!controller.hasSelectedDestination) {
    AppToast.warning(
      l10n.selectDestination,
      title: l10n.destination,
    );
    return;
  }

  if (overridePlanningMode != null && overridePlanningMode.isNotEmpty) {
    controller.setPlanningMode(overridePlanningMode);
  }

  Get.to(
    () => TravelPlanPage(
      cityId: controller.cityId,
      cityName: controller.cityName,
      duration: controller.duration.value,
      budget: controller.getFinalBudget(),
      travelStyle: controller.travelStyle.value,
      interests: controller.getAllInterests(),
      departureLocation: controller.departureLocation.value,
      departureDate: controller.departureDate.value,
    ),
  );
}
