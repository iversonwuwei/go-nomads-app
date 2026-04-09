import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/widgets/hub_action_card.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';
import 'package:go_nomads_app/features/visa/presentation/controllers/visa_center_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

class VisaCenterPage extends GetView<VisaCenterController> {
  const VisaCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final data = controller.visaCenter.value;

          return RefreshIndicator(
            color: AppColors.cityPrimary,
            onRefresh: controller.refreshVisaCenter,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
              children: [
                _HeroCard(
                  title: l10n.visaCenterHeroTitle,
                  subtitle: '',
                  statusLabel: _recommendedActionLabel(
                      l10n, data?.recommendedAction ?? ''),
                  onRefreshTap: controller.refreshVisaCenter,
                ),
                SizedBox(height: 18.h),
                if (controller.isLoading.value && !controller.hasData)
                  const _LoadingState()
                else if (controller.errorMessage.value != null &&
                    !controller.hasData)
                  _ErrorState(
                    message: controller.errorMessage.value!,
                    retryLabel: l10n.migrationWorkspaceRetry,
                    onRetry: controller.refreshVisaCenter,
                  )
                else if (!controller.hasData)
                  _EmptyState(
                    title: l10n.visaCenterEmptyTitle,
                    subtitle: '',
                    ctaLabel: l10n.createTravelPlan,
                    onCtaTap: () => Get.toNamed(AppRoutes.createTravelPlan),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.passport,
                          label: l10n.visaCenterProfiles,
                          value: '${data?.activeProfileCount ?? 0}',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.circleExclamation,
                          label: l10n.visaCenterAttentionRequired,
                          value: '${data?.attentionRequiredCount ?? 0}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.bell,
                          label: l10n.visaCenterReminderReady,
                          value: '${data?.reminderReadyCount ?? 0}',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _MetricCard(
                          icon: FontAwesomeIcons.calendarDays,
                          label: l10n.visaCenterSoonestExpiry,
                          value: _focusDaysLabel(l10n, controller.focusProfile),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  if (controller.focusProfile != null) ...[
                    _SectionHeader(title: l10n.visaCenterFocusProfile),
                    SizedBox(height: 12.h),
                    _FocusVisaCard(
                      profile: controller.focusProfile!,
                      expiryLabel: l10n.visaCenterExpiryDate,
                      requirementsLabel: l10n.visaCenterRequirements,
                      processLabel: l10n.visaCenterProcess,
                      statusLabel: _profileStatusLabel(
                          l10n, controller.focusProfile!.status),
                    ),
                    SizedBox(height: 18.h),
                    _SectionHeader(title: l10n.visaCenterQuickActions),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.bell,
                      title: l10n.visaCenterSetReminder,
                      subtitle: '',
                      onTap: controller.isSettingReminder.value
                          ? () {}
                          : controller.setReminderForFocusProfile,
                    ),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.route,
                      title: l10n.visaCenterOpenPlan,
                      subtitle: '',
                      onTap: () => _openPlan(controller.focusProfile!),
                    ),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.filePen,
                      title: l10n.visaCenterEditProfile,
                      subtitle: '',
                      onTap: () => _openVisaProfileEditor(
                          context, controller.focusProfile!),
                    ),
                    SizedBox(height: 18.h),
                  ],
                  _SectionHeader(title: l10n.visaCenterAllProfiles),
                  SizedBox(height: 12.h),
                  ...controller.profiles.map(
                    (profile) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _VisaProfileCard(
                        profile: profile,
                        statusLabel: _profileStatusLabel(l10n, profile.status),
                        onTap: () => _openPlan(profile),
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

  void _openPlan(VisaProfile profile) {
    Get.toNamed(
      AppRoutes.travelPlan,
      arguments: {
        'planId': profile.id,
        'cityId': profile.cityId,
        'cityName': profile.cityName,
      },
    );
  }

  Future<void> _openVisaProfileEditor(
      BuildContext context, VisaProfile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final visaTypeController = TextEditingController(text: profile.visaType);
    final stayController =
        TextEditingController(text: profile.stayDurationDays.toString());
    final entryController =
        TextEditingController(text: _formatDate(profile.entryDate));
    final expiryController =
        TextEditingController(text: _formatDate(profile.expiryDate));
    final costController = TextEditingController(
        text: profile.estimatedCostUsd.toStringAsFixed(0));
    final requirementsController =
        TextEditingController(text: profile.requirementsSummary);
    final processController =
        TextEditingController(text: profile.processSummary);
    final documentsController =
        TextEditingController(text: profile.requiredDocuments.join('\n'));
    final remindersController = TextEditingController(
      text:
          profile.reminderDates.map(_formatDate).whereType<String>().join('\n'),
    );

    try {
      await AppBottomDrawer.show<void>(
        context,
        title: l10n.visaCenterEditProfile,
        subtitle: profile.cityName,
        child: Column(
          children: [
            TextField(
              controller: visaTypeController,
              decoration: InputDecoration(labelText: l10n.visaCenterTypeLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stayController,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: l10n.visaCenterStayDaysLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: entryController,
              decoration:
                  InputDecoration(labelText: l10n.visaCenterEntryDateLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: expiryController,
              decoration: InputDecoration(labelText: l10n.visaCenterExpiryDate),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.budgetCenterForecast),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: requirementsController,
              maxLines: 3,
              decoration:
                  InputDecoration(labelText: l10n.visaCenterRequirements),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: processController,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.visaCenterProcess),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: documentsController,
              maxLines: 4,
              decoration:
                  InputDecoration(labelText: l10n.visaCenterDocumentsLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remindersController,
              maxLines: 4,
              decoration:
                  InputDecoration(labelText: l10n.visaCenterReminderDatesLabel),
            ),
          ],
        ),
        footer: AppBottomDrawerActionRow(
          secondaryLabel: l10n.cancel,
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: l10n.saveChanges,
          onPrimaryPressed: () {
            controller.saveVisaProfile(
              profile: profile,
              visaType: visaTypeController.text.trim(),
              stayDurationDays: int.tryParse(stayController.text.trim()) ??
                  profile.stayDurationDays,
              entryDate: DateTime.tryParse(entryController.text.trim()),
              expiryDate: DateTime.tryParse(expiryController.text.trim()),
              estimatedCostUsd: double.tryParse(costController.text.trim()) ??
                  profile.estimatedCostUsd,
              requirementsSummary: requirementsController.text.trim(),
              processSummary: processController.text.trim(),
              requiredDocuments: _parseLines(documentsController.text),
              reminderDates: _parseReminderDates(remindersController.text),
            );
            Get.back<void>();
          },
        ),
      );
    } finally {
      visaTypeController.dispose();
      stayController.dispose();
      entryController.dispose();
      expiryController.dispose();
      costController.dispose();
      requirementsController.dispose();
      processController.dispose();
      documentsController.dispose();
      remindersController.dispose();
    }
  }

  List<String> _parseLines(String raw) {
    return raw
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<DateTime> _parseReminderDates(String raw) {
    return _parseLines(raw)
        .map((item) => DateTime.tryParse(item))
        .whereType<DateTime>()
        .toList();
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }

    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  String _recommendedActionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'set-reminder-now':
        return l10n.visaCenterActionSetReminderNow;
      case 'compare-entry-options':
        return l10n.visaCenterActionCompareEntryOptions;
      case 'complete-visa-brief':
        return l10n.visaCenterActionCompleteBrief;
      case 'create-first-plan':
        return l10n.visaCenterActionCreateFirstPlan;
      default:
        return l10n.visaCenterActionReviewLatestVisa;
    }
  }

  String _profileStatusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'attention_required':
        return l10n.visaCenterStatusAttentionRequired;
      case 'review_soon':
        return l10n.visaCenterStatusReviewSoon;
      case 'planning':
        return l10n.visaCenterStatusPlanning;
      case 'archived':
        return l10n.visaCenterStatusArchived;
      default:
        return l10n.visaCenterStatusOnTrack;
    }
  }

  String _focusDaysLabel(AppLocalizations l10n, VisaProfile? profile) {
    if (profile?.daysRemaining == null) {
      return '-';
    }

    return l10n.daysRemaining(profile!.daysRemaining!);
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final VoidCallback onRefreshTap;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
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
                  FontAwesomeIcons.passport,
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
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8.h),
          ] else
            SizedBox(height: 10.h),
          Text(
            statusLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
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

class _FocusVisaCard extends StatelessWidget {
  final VisaProfile profile;
  final String expiryLabel;
  final String requirementsLabel;
  final String processLabel;
  final String statusLabel;

  const _FocusVisaCard({
    required this.profile,
    required this.expiryLabel,
    required this.requirementsLabel,
    required this.processLabel,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.cityName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimaryLight,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: AppColors.cityPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _visaTypeLabel(l10n, profile.visaType),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$expiryLabel: ${profile.expiryDate != null ? _formatDate(profile.expiryDate!) : '-'}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.daysRemaining(profile.daysRemaining ?? 0),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            requirementsLabel,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            profile.requirementsSummary,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13.sp, height: 1.5),
          ),
          SizedBox(height: 12.h),
          Text(
            processLabel,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            profile.processSummary,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13.sp, height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _visaTypeLabel(AppLocalizations l10n, String visaType) {
    switch (visaType) {
      case 'long_stay_visa':
        return l10n.visaCenterTypeLongStay;
      case 'digital_nomad_entry':
        return l10n.visaCenterTypeDigitalNomad;
      case 'priority_evisa':
        return l10n.visaCenterTypePriorityEVisa;
      default:
        return l10n.visaCenterTypeShortStay;
    }
  }
}

class _VisaProfileCard extends StatelessWidget {
  final VisaProfile profile;
  final String statusLabel;
  final VoidCallback onTap;

  const _VisaProfileCard({
    required this.profile,
    required this.statusLabel,
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
                  FontAwesomeIcons.stamp,
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
                      profile.cityName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      statusLabel,
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
          Icon(FontAwesomeIcons.passport,
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
