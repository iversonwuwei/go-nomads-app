import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/budget/presentation/controllers/budget_center_controller.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/widgets/hub_action_card.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/manage_cost_page.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

class BudgetCenterPage extends GetView<BudgetCenterController> {
  const BudgetCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final data = controller.budgetCenter.value;

          return RefreshIndicator(
            color: AppColors.cityPrimary,
            onRefresh: controller.refreshBudgetCenter,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
              children: [
                _HeroCard(
                  title: l10n.budgetCenterHeroTitle,
                  subtitle: '',
                  statusLabel:
                      _budgetHealthLabel(l10n, data?.budgetHealth ?? 'no_data'),
                  primaryLabel: controller.focusPlan != null
                      ? l10n.budgetCenterOpenPlan
                      : l10n.createTravelPlan,
                  secondaryLabel: _recommendedActionLabel(
                      l10n, data?.recommendedAction ?? ''),
                  onPrimaryTap: () {
                    final focusPlan = controller.focusPlan;
                    if (focusPlan == null) {
                      Get.toNamed(AppRoutes.createTravelPlan);
                      return;
                    }
                    _openPlan(focusPlan);
                  },
                  statusColor:
                      _budgetHealthColor(data?.budgetHealth ?? 'no_data'),
                  onRefreshTap: controller.refreshBudgetCenter,
                ),
                SizedBox(height: 18.h),
                if (controller.isLoading.value && !controller.hasData)
                  const _LoadingState()
                else if (controller.errorMessage.value != null &&
                    !controller.hasData)
                  _ErrorState(
                    message: controller.errorMessage.value!,
                    retryLabel: l10n.migrationWorkspaceRetry,
                    onRetry: controller.refreshBudgetCenter,
                  )
                else if (!controller.hasData)
                  _EmptyState(
                    title: l10n.budgetCenterEmptyTitle,
                    subtitle: '',
                    ctaLabel: l10n.createTravelPlan,
                    onCtaTap: () => Get.toNamed(AppRoutes.createTravelPlan),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.bullseye,
                          label: l10n.budgetCenterMonthlyTarget,
                          value: _formatCurrency(
                              data?.monthlyBudgetTargetUsd ?? 0),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.chartLine,
                          label: l10n.budgetCenterForecast,
                          value: _formatCurrency(
                              data?.forecastMonthlyCostUsd ?? 0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.scaleBalanced,
                          label: l10n.budgetCenterDelta,
                          value: _formatSignedCurrency(data?.deltaUsd ?? 0),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.layerGroup,
                          label: l10n.budgetCenterTrackedCities,
                          value: '${data?.trackedCityCount ?? 0}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  if (controller.focusPlan != null) ...[
                    _SectionHeader(title: l10n.budgetCenterFocusCity),
                    SizedBox(height: 12.h),
                    _FocusPlanCard(
                      plan: controller.focusPlan!,
                      estimatedLabel: l10n.budgetCenterEstimatedMonthlyCost,
                      departureLabel: l10n.migrationWorkspaceDepartureDate,
                      openPlanLabel: l10n.budgetCenterOpenPlan,
                      onOpenPlan: () => _openPlan(controller.focusPlan!),
                    ),
                    SizedBox(height: 18.h),
                    _SectionHeader(title: l10n.budgetCenterQuickActions),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.plus,
                      title: l10n.budgetCenterAddCost,
                      subtitle: '',
                      onTap: () => _openAddCost(controller.focusPlan!),
                    ),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.receipt,
                      title: l10n.budgetCenterManageCosts,
                      subtitle: '',
                      onTap: () => _openManageCosts(controller.focusPlan!),
                    ),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.sliders,
                      title: l10n.budgetCenterEditBaseline,
                      subtitle: '',
                      onTap: () => _openBudgetBaselineEditor(
                          context, controller.focusPlan!),
                    ),
                    SizedBox(height: 18.h),
                  ],
                  _SectionHeader(title: l10n.budgetCenterTrackedPlans),
                  SizedBox(height: 12.h),
                  ...controller.plans.map(
                    (plan) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _BudgetPlanCard(
                        plan: plan,
                        onTap: () => _openPlan(plan),
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

  void _openPlan(BudgetCenterPlan plan) {
    Get.toNamed(
      AppRoutes.travelPlan,
      arguments: {
        'planId': plan.id,
        'cityId': plan.cityId,
        'cityName': plan.cityName,
      },
    );
  }

  void _openAddCost(BudgetCenterPlan plan) {
    Get.toNamed(
      AppRoutes.addCost,
      arguments: {
        'cityId': plan.cityId,
        'cityName': plan.cityName,
      },
    );
  }

  void _openManageCosts(BudgetCenterPlan plan) {
    Get.to(
      () => ManageCostPage(
        cityId: plan.cityId,
        cityName: plan.cityName,
      ),
    );
  }

  Future<void> _openBudgetBaselineEditor(
      BuildContext context, BudgetCenterPlan plan) async {
    final l10n = AppLocalizations.of(context)!;
    final templateController = TextEditingController(text: plan.templateName);
    final targetController = TextEditingController(
        text: plan.declaredMonthlyBudgetUsd.toStringAsFixed(0));
    final forecastController = TextEditingController(
        text: plan.estimatedMonthlyCostUsd.toStringAsFixed(0));
    final thresholdController = TextEditingController(
        text: plan.alertThresholdPercent.toStringAsFixed(0));
    final categoriesController = TextEditingController(
      text: plan.categories
          .map((item) =>
              '${item.category}: ${item.budgetUsd.toStringAsFixed(0)}')
          .join('\n'),
    );

    try {
      await AppBottomDrawer.show<void>(
        context,
        title: l10n.budgetCenterEditBaseline,
        subtitle: plan.cityName,
        child: Column(
          children: [
            TextField(
              controller: templateController,
              decoration:
                  InputDecoration(labelText: l10n.budgetCenterTemplateLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: l10n.budgetCenterMonthlyTarget),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: forecastController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.budgetCenterForecast),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: thresholdController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: l10n.budgetCenterThresholdLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoriesController,
              maxLines: 5,
              decoration:
                  InputDecoration(labelText: l10n.budgetCenterCategoryLabel),
            ),
          ],
        ),
        footer: AppBottomDrawerActionRow(
          secondaryLabel: l10n.cancel,
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: l10n.saveChanges,
          onPrimaryPressed: () {
            controller.saveBudgetPlan(
              plan: plan,
              templateName: templateController.text.trim(),
              monthlyBudgetTargetUsd:
                  double.tryParse(targetController.text.trim()) ??
                      plan.declaredMonthlyBudgetUsd,
              forecastMonthlyCostUsd:
                  double.tryParse(forecastController.text.trim()) ??
                      plan.estimatedMonthlyCostUsd,
              alertThresholdPercent:
                  double.tryParse(thresholdController.text.trim()) ??
                      plan.alertThresholdPercent,
              overrunAlertEnabled: plan.overrunAlertEnabled,
              categories: _parseBudgetCategories(categoriesController.text),
            );
            Get.back<void>();
          },
        ),
      );
    } finally {
      templateController.dispose();
      targetController.dispose();
      forecastController.dispose();
      thresholdController.dispose();
      categoriesController.dispose();
    }
  }

  List<BudgetCategoryAllocation> _parseBudgetCategories(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
      final segments = line.split(':');
      final category = segments.first.trim();
      final double amount = segments.length > 1
          ? double.tryParse(segments.sublist(1).join(':').trim()) ?? 0.0
          : 0.0;
      return BudgetCategoryAllocation(category: category, budgetUsd: amount);
    }).toList();
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatSignedCurrency(double value) {
    if (value > 0) {
      return '+\$${value.toStringAsFixed(0)}';
    }

    if (value < 0) {
      return '-\$${value.abs().toStringAsFixed(0)}';
    }

    return '\$0';
  }

  String _budgetHealthLabel(AppLocalizations l10n, String budgetHealth) {
    switch (budgetHealth) {
      case 'on_track':
        return l10n.budgetCenterStatusOnTrack;
      case 'watch':
        return l10n.budgetCenterStatusWatch;
      case 'over_budget':
        return l10n.budgetCenterStatusOverBudget;
      default:
        return l10n.budgetCenterStatusNoData;
    }
  }

  String _recommendedActionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'create-first-plan':
        return l10n.budgetCenterActionCreateFirstPlan;
      case 'review-over-budget':
        return l10n.budgetCenterActionReviewOverBudget;
      case 'lock-first-month-budget':
        return l10n.budgetCenterActionLockFirstMonthBudget;
      case 'compare-city-budget':
        return l10n.budgetCenterActionCompareCityBudget;
      case 'finalize-budget-baseline':
        return l10n.budgetCenterActionFinalizeBudgetBaseline;
      default:
        return l10n.budgetCenterActionReviewLatestPlan;
    }
  }

  Color _budgetHealthColor(String budgetHealth) {
    switch (budgetHealth) {
      case 'on_track':
        return Colors.green;
      case 'watch':
        return Colors.orange;
      case 'over_budget':
        return AppColors.cityPrimaryDark;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimaryTap;
  final Color statusColor;
  final VoidCallback onRefreshTap;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryTap,
    required this.statusColor,
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
                  FontAwesomeIcons.wallet,
                  size: 20.r,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              CockpitGlassIconButton(
                icon: Icons.refresh_rounded,
                onTap: onRefreshTap,
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999.r),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.28)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8.h),
          ] else
            SizedBox(height: 10.h),
          Text(
            secondaryLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 14.h),
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

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FocusPlanCard extends StatelessWidget {
  final BudgetCenterPlan plan;
  final String estimatedLabel;
  final String departureLabel;
  final String openPlanLabel;
  final VoidCallback onOpenPlan;

  const _FocusPlanCard({
    required this.plan,
    required this.estimatedLabel,
    required this.departureLabel,
    required this.openPlanLabel,
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.cityName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '$estimatedLabel: \$${plan.estimatedMonthlyCostUsd.toStringAsFixed(0)}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$departureLabel: ${plan.departureDate != null ? _formatDate(plan.departureDate!) : '-'}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: onOpenPlan,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
              side: BorderSide(color: AppColors.cityPrimary),
            ),
            icon: Icon(FontAwesomeIcons.route, size: 14.r),
            label: Text(openPlanLabel),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _BudgetPlanCard extends StatelessWidget {
  final BudgetCenterPlan plan;
  final VoidCallback onTap;

  const _BudgetPlanCard({
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.cityPrimaryLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  FontAwesomeIcons.chartPie,
                  size: 18.r,
                  color: AppColors.cityPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.cityName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${plan.budgetLevel} · \$${plan.estimatedMonthlyCostUsd.toStringAsFixed(0)} / month',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 14.r,
                color: AppColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240.h,
      child: const Center(child: AppLoadingWidget()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.circleExclamation,
              color: AppColors.cityPrimaryDark, size: 24.r),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cityPrimary),
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
          Icon(FontAwesomeIcons.wallet,
              size: 28.r, color: AppColors.cityPrimary),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],
          SizedBox(height: 18.h),
          FilledButton(
            onPressed: onCtaTap,
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.cityPrimary),
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}
