import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/travel_plan/travel_plan_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 计划概览卡片组件
class TravelPlanOverviewCard extends GetView<TravelPlanPageController> {
  const TravelPlanOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final plan = controller.plan.value;
      if (plan == null) return const SizedBox.shrink();

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
            _InfoChips(plan: plan, l10n: l10n),
          ],
        ),
      );
    });
  }
}

/// 信息标签组件
class _InfoChips extends GetView<TravelPlanPageController> {
  final TravelPlan plan;
  final AppLocalizations l10n;

  const _InfoChips({required this.plan, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final departureLocation = controller.effectiveDepartureLocation;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (departureLocation != null && departureLocation.isNotEmpty) ...[
            _InfoChip(
              icon: FontAwesomeIcons.plane,
              label: '${l10n.from}: $departureLocation',
            ),
            SizedBox(width: 12.w),
          ],
          _InfoChip(
            icon: FontAwesomeIcons.calendar,
            label: '${plan.metadata.duration} ${l10n.days}',
          ),
          SizedBox(width: 12.w),
          _InfoChip(
            icon: FontAwesomeIcons.dollarSign,
            label: plan.metadata.budgetLevel.displayName,
          ),
          SizedBox(width: 12.w),
          _InfoChip(
            icon: FontAwesomeIcons.paintbrush,
            label: plan.metadata.style.name,
          ),
        ],
      ),
    );
  }
}

/// 单个信息标签
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
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

/// 区块标题组件
class TravelPlanSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const TravelPlanSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
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
    );
  }
}

/// 错误页面组件
class TravelPlanErrorView extends StatelessWidget {
  const TravelPlanErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.travelPlan),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: 64.r,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.failedToGeneratePlan,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.pleaseTryAgain,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }
}
