import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

import '../travel_plan/travel_plan_page.dart';
import 'widgets/widgets.dart';

/// 创建旅行计划页面 - 使用 GetX + 组件化架构重构
class CreateTravelPlanPage extends GetView<CreateTravelPlanPageController> {
  static const String controllerTag = CreateTravelPlanPageController.controllerTag;

  const CreateTravelPlanPage({super.key});

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
              _HeaderCard(cityName: controller.cityName),

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
                    const TravelPlanOpenClawSection(),

                    SizedBox(height: 28.h),

                    // Attractions
                    const TravelPlanAttractionsSection(),

                    SizedBox(height: 28.h),

                    // Travel Style
                    const TravelPlanStyleSection(),

                    SizedBox(height: 28.h),

                    // Interests
                    const TravelPlanInterestsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const _BottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: const AppBackButton(color: AppColors.backButtonDark),
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
          Column(
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
                l10n.planYourTrip(controller.cityName),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String cityName;

  const _HeaderCard({required this.cityName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          Text(
            '先设定偏好，再决定是否启用 OpenClaw 研究增强，最后由 AI 生成更贴近你任务目标的行程。',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              height: 1.4,
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
    final l10n = AppLocalizations.of(context)!;
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
        child: ElevatedButton(
          onPressed: () => _generatePlan(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4458),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.wandMagicSparkles, size: 20.r),
              SizedBox(width: 8.w),
              Obx(() => Text(
                    controller.planningMode.value == 'research' ? '开始 OpenClaw 研究规划' : l10n.generatePlan,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.3.sp),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _generatePlan() {
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
}
