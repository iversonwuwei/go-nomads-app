import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/create_travel_plan_page_controller.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../travel_plan_page.dart';
import 'travel_plan_budget_section.dart';
import 'travel_plan_departure_section.dart';
import 'travel_plan_duration_section.dart';
import 'travel_plan_style_section.dart';

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
    final controller = Get.put(
      CreateTravelPlanPageController(cityId: cityId, cityName: cityName),
      tag: uniqueTag,
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<CreateTravelPlanPageController>(tag: uniqueTag);
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
                    // Departure Location
                    TravelPlanDepartureSection(controllerTag: uniqueTag),

                    const SizedBox(height: 28),

                    // Departure Date
                    TravelPlanDateSection(controllerTag: uniqueTag),

                    const SizedBox(height: 28),

                    // Trip Duration
                    TravelPlanDurationSection(controllerTag: uniqueTag),

                    const SizedBox(height: 28),

                    // Budget Level
                    TravelPlanBudgetSection(controllerTag: uniqueTag),

                    const SizedBox(height: 28),

                    // Attractions
                    TravelPlanAttractionsSection(controllerTag: uniqueTag),

                    const SizedBox(height: 28),

                    // Travel Style
                    TravelPlanStyleSection(controllerTag: uniqueTag),

                    const SizedBox(height: 28),

                    // Interests
                    TravelPlanInterestsSection(controllerTag: uniqueTag),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(controllerTag: uniqueTag, controller: controller),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              FontAwesomeIcons.wandMagicSparkles,
              color: Color(0xFFFF4458),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiTravelPlanner,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                l10n.planYourTrip(cityName),
                style: const TextStyle(
                  fontSize: 12,
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.wandMagicSparkles, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.aiPoweredPlanning,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tellPreferences(cityName),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
  final CreateTravelPlanPageController controller;

  const _BottomBar({required this.controllerTag, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.wandMagicSparkles, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.generatePlan,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
              ),
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
