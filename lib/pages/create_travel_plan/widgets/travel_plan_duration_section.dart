import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 行程天数部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanDurationSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanDurationSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.tripDuration, icon: FontAwesomeIcons.calendar),
        SizedBox(height: 12.h),
        _DurationCard(controllerTag: controllerTag),
      ],
    );
  }
}

/// 天数选择卡片
class _DurationCard extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _DurationCard({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Obx(() => Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: controller.duration.value.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: l10n.days(controller.duration.value),
                      activeColor: const Color(0xFFFF4458),
                      inactiveColor: Colors.grey[300],
                      onChanged: (value) => controller.setDuration(value.toInt()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _DurationBadge(days: controller.duration.value),
                ],
              )),
          SizedBox(height: 8.h),
          _DurationLabel(controllerTag: controllerTag),
        ],
      ),
    );
  }
}

/// 天数显示徽章
class _DurationBadge extends StatelessWidget {
  final int days;

  const _DurationBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458),
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        days.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 天数标签
class _DurationLabel extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _DurationLabel({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() => Text(
          controller.duration.value == 1 ? l10n.day(1) : l10n.days(controller.duration.value),
          style: TextStyle(
            color: Color(0xFFFF4458),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ));
  }
}

/// 区块标题组件
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
