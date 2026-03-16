import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Card
              _HeaderCard(controllerTag: controllerTag),

              // Form Section
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
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
                    // Destination
                    TravelPlanDestinationSection(controllerTag: controllerTag),

                    SizedBox(height: 28.h),

                    // Departure Location
                    TravelPlanDepartureSection(controllerTag: controllerTag),

                    SizedBox(height: 28.h),

                    // Departure Date
                    TravelPlanDateSection(controllerTag: controllerTag),

                    SizedBox(height: 28.h),

                    // Trip Duration
                    const TravelPlanDurationSection(),

                    SizedBox(height: 28.h),

                    // Budget Level
                    const TravelPlanBudgetSection(),

                    SizedBox(height: 28.h),

                    // OpenClaw Research Layer
                    TravelPlanOpenClawSection(
                      onStrategyTap: (planningMode) => _launchTravelPlanFromCreatePage(
                        context,
                        controller,
                        overridePlanningMode: planningMode,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Attractions
                    const TravelPlanAttractionsSection(),

                    SizedBox(height: 28.h),

                    // Travel Style
                    const TravelPlanStyleSection(),

                    SizedBox(height: 28.h),

                    // Interests
                    const TravelPlanInterestsSection(),

                    if (embeddedInBottomNav) ...[
                      SizedBox(height: 28.h),
                      const _GeneratePlanButton(),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
        ],
      ),
    );
  }
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
