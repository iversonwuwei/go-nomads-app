import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/travel_plan/travel_plan_page_controller.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';

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
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.cityPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            ),
            child: Icon(icon, color: AppColors.cityPrimary, size: 16.r),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: CockpitPanel(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CockpitGlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: Get.back,
                      iconColor: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Icon(
                    FontAwesomeIcons.circleExclamation,
                    size: 56.r,
                    color: const Color(0xFFFF6B6B),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.failedToGeneratePlan,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.pleaseTryAgain,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cityPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(l10n.goBack),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
