import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../travel_plan/travel_plan_page.dart';
import 'widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 创建旅行计划页面 - 使用 GetX + 组件化架构重构
class CreateTravelPlanPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const CreateTravelPlanPage({super.key, required this.cityId, required this.cityName});

  @override
  Widget build(BuildContext context) {
    // 生成唯一 tag 避免多页面冲突
    final uniqueTag = 'create_travel_plan_${cityId}_${DateTime.now().millisecondsSinceEpoch}';

    // 注册 controller
    Get.put(
      CreateTravelPlanPageController(cityId: cityId, cityName: cityName),
      tag: uniqueTag,
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 延迟删除控制器，等待当前帧渲染完成
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isRegistered<CreateTravelPlanPageController>(tag: uniqueTag)) {
              Get.delete<CreateTravelPlanPageController>(tag: uniqueTag);
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
              _HeaderCard(cityName: cityName),

              // Form Section
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    TravelPlanDepartureSection(controllerTag: uniqueTag),

                    SizedBox(height: 28.h),

                    // Departure Date
                    TravelPlanDateSection(controllerTag: uniqueTag),

                    SizedBox(height: 28.h),

                    // Trip Duration
                    TravelPlanDurationSection(controllerTag: uniqueTag),

                    SizedBox(height: 28.h),

                    // Budget Level
                    TravelPlanBudgetSection(controllerTag: uniqueTag),

                    SizedBox(height: 28.h),

                    // Attractions
                    TravelPlanAttractionsSection(controllerTag: uniqueTag),

                    SizedBox(height: 28.h),

                    // Travel Style
                    TravelPlanStyleSection(controllerTag: uniqueTag),

                    SizedBox(height: 28.h),

                    // Interests
                    TravelPlanInterestsSection(controllerTag: uniqueTag),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(controllerTag: uniqueTag),
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
                l10n.planYourTrip(cityName),
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
            l10n.tellPreferences(cityName),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String controllerTag;

  const _BottomBar({required this.controllerTag});

  CreateTravelPlanPageController? get _controller {
    try {
      return Get.find<CreateTravelPlanPageController>(tag: controllerTag);
    } catch (e) {
      return null;
    }
  }

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
              Text(
                l10n.generatePlan,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.3.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generatePlan() {
    final controller = _controller;
    if (controller == null) return;

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
