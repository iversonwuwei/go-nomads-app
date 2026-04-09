import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/migration_workspace/presentation/controllers/migration_workspace_controller.dart';
import 'package:go_nomads_app/features/migration_workspace/presentation/widgets/workspace_plan_editor_sheet.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';

class MigrationWorkspacePage extends GetView<MigrationWorkspaceController> {
  const MigrationWorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: AppColors.cityPrimary,
            onRefresh: controller.refreshWorkspace,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
              children: [
                _HeroCard(
                  title: l10n.migrationWorkspaceHeroTitle,
                  subtitle: '',
                  primaryLabel: controller.latestPlan != null
                      ? l10n.migrationWorkspaceContinuePlanning
                      : l10n.createTravelPlan,
                  onPrimaryTap: () {
                    final latestPlan = controller.latestPlan;
                    if (latestPlan != null) {
                      _openPlan(latestPlan);
                      return;
                    }
                    Get.toNamed(AppRoutes.createTravelPlan);
                  },
                  onRefreshTap: controller.refreshWorkspace,
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: FontAwesomeIcons.layerGroup,
                        label: l10n.migrationWorkspacePlanCount,
                        value: controller.totalPlans.toString(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _MetricCard(
                        icon: FontAwesomeIcons.listCheck,
                        label: l10n.migrationWorkspaceActivePlans,
                        value: controller.activePlansCount.toString(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _MetricCard(
                        icon: FontAwesomeIcons.planeDeparture,
                        label: l10n.migrationWorkspaceUpcomingDepartures,
                        value: controller.upcomingDeparturesCount.toString(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                if (controller.latestPlan?.hasWorkspaceDetails == true) ...[
                  _WorkspaceFocusCard(
                    plan: controller.latestPlan!,
                    onEdit: () =>
                        _openWorkspaceEditor(context, controller.latestPlan!),
                  ),
                  SizedBox(height: 18.h),
                ],
                _SectionHeader(
                  title: l10n.myTravelPlans,
                  actionLabel:
                      controller.plans.isNotEmpty ? l10n.createNew : null,
                  onActionTap: controller.plans.isNotEmpty
                      ? () => Get.toNamed(AppRoutes.createTravelPlan)
                      : null,
                ),
                SizedBox(height: 12.h),
                if (controller.isLoading.value && controller.plans.isEmpty)
                  const _LoadingState()
                else if (controller.errorMessage.value != null &&
                    controller.plans.isEmpty)
                  _ErrorState(
                    message: controller.errorMessage.value!,
                    retryLabel: l10n.migrationWorkspaceRetry,
                    onRetry: controller.refreshWorkspace,
                  )
                else if (controller.plans.isEmpty)
                  _EmptyState(
                    title: l10n.migrationWorkspaceEmptyTitle,
                    subtitle: '',
                    ctaLabel: l10n.createTravelPlan,
                    onCtaTap: () => Get.toNamed(AppRoutes.createTravelPlan),
                  )
                else ...[
                  if (controller.draftPlansCount > 0) ...[
                    _InsightBanner(
                      icon: FontAwesomeIcons.wandMagicSparkles,
                      title: l10n.migrationWorkspaceDraftPlans,
                      value: controller.draftPlansCount.toString(),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  ...controller.plans.map(
                    (plan) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _PlanCard(
                        plan: plan,
                        openLabel: l10n.migrationWorkspaceOpenPlan,
                        onOpen: () => _openPlan(plan),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  void _openPlan(TravelPlanSummary plan) {
    Get.toNamed(
      AppRoutes.travelPlan,
      arguments: {
        'planId': plan.id,
        'cityId': plan.cityId,
        'cityName': plan.cityName,
        'summary': plan,
      },
    );
  }

  Future<void> _openWorkspaceEditor(
      BuildContext context, TravelPlanSummary plan) async {
    final result = await showWorkspacePlanEditor(context, plan);
    if (result == null) {
      return;
    }

    await controller.savePlanState(
      plan: plan,
      stage: result.stage,
      focusNote: result.focusNote,
      checklist: result.checklist,
      timeline: result.timeline,
    );
  }
}

class _WorkspaceFocusCard extends StatelessWidget {
  final TravelPlanSummary plan;
  final VoidCallback onEdit;

  const _WorkspaceFocusCard({
    required this.plan,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.migrationWorkspaceFocusTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onEdit, child: Text(l10n.saveChanges)),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _MetaChip(
                  icon: FontAwesomeIcons.flagCheckered,
                  label: plan.migrationStage),
              _MetaChip(
                icon: FontAwesomeIcons.listCheck,
                label: '${plan.completedTaskCount}/${plan.totalTaskCount}',
              ),
            ],
          ),
          if ((plan.focusNote ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              plan.focusNote!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ],
          if (plan.checklist.isNotEmpty) ...[
            SizedBox(height: 14.h),
            ...plan.checklist.take(3).map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      children: [
                        Icon(
                          item.isCompleted
                              ? FontAwesomeIcons.circleCheck
                              : FontAwesomeIcons.circle,
                          size: 12.r,
                          color: item.isCompleted
                              ? Colors.green
                              : AppColors.textTertiary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback onRefreshTap;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cityGradientStart, AppColors.cityGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  FontAwesomeIcons.suitcaseRolling,
                  size: 20.r,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              CockpitGlassIconButton(
                icon: Icons.refresh_rounded,
                onTap: onRefreshTap,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasSubtitle) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 14.h),
          ] else
            SizedBox(height: 16.h),
          FilledButton.icon(
            onPressed: onPrimaryTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.cityPrimary,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            ),
            icon: Icon(FontAwesomeIcons.arrowRight, size: 14.r),
            label: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.r, color: AppColors.cityPrimary),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        if ((actionLabel ?? '').isNotEmpty) ...[
          const Spacer(),
          TextButton.icon(
            onPressed: onActionTap,
            icon: Icon(FontAwesomeIcons.plus, size: 14.r),
            label: Text(actionLabel!),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(child: AppLoadingWidget(fullScreen: false)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.triangleExclamation,
              size: 28.r, color: AppColors.cityPrimary),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
              side: const BorderSide(color: AppColors.cityPrimary),
            ),
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onCtaTap;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(FontAwesomeIcons.mapLocationDot,
                size: 26.r, color: AppColors.cityPrimary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasSubtitle) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 18.h),
          FilledButton.icon(
            onPressed: onCtaTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
            ),
            icon: Icon(FontAwesomeIcons.wandMagicSparkles, size: 14.r),
            label: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InsightBanner({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 14.r, color: AppColors.cityPrimary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.cityPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final TravelPlanSummary plan;
  final String openLabel;
  final VoidCallback onOpen;

  const _PlanCard({
    required this.plan,
    required this.openLabel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 146.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              gradient: plan.cityImage == null || plan.cityImage!.isEmpty
                  ? const LinearGradient(
                      colors: [
                        AppColors.cityGradientStart,
                        AppColors.cityGradientEnd
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              image: plan.cityImage != null && plan.cityImage!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(plan.cityImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.5)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _StatusChip(status: plan.status),
                  ),
                  const Spacer(),
                  Text(
                    plan.cityName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _MetaChip(
                      icon: FontAwesomeIcons.calendarDays,
                      label: l10n.durationDays(plan.duration.toString()),
                    ),
                    _MetaChip(
                      icon: FontAwesomeIcons.wallet,
                      label: plan.budgetLevelDisplay,
                    ),
                    _MetaChip(
                      icon: FontAwesomeIcons.compassDrafting,
                      label: plan.travelStyleDisplay,
                    ),
                  ],
                ),
                if (plan.departureDate != null) ...[
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.planeDeparture,
                          size: 12.r, color: AppColors.textTertiary),
                      SizedBox(width: 8.w),
                      Text(
                        '${l10n.migrationWorkspaceDepartureDate}: ${plan.formattedDepartureDate}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.clock,
                        size: 12.r, color: AppColors.textTertiary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${l10n.createdAt} ${plan.formattedCreatedAt}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cityPrimaryLight,
                        foregroundColor: AppColors.cityPrimary,
                      ),
                      icon: Icon(FontAwesomeIcons.arrowRight, size: 12.r),
                      label: Text(openLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        status.isEmpty ? 'draft' : status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
