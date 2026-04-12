import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/widgets/hub_action_card.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';
import 'package:go_nomads_app/features/visa/presentation/controllers/visa_center_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
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
          final focusProfile = controller.focusProfile;

          return RefreshIndicator(
            color: AppColors.cityPrimary,
            onRefresh: controller.refreshVisaCenter,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
              children: [
                _HeroCard(
                  title: l10n.visaCenterHeroTitle,
                  subtitle: _heroSubtitle(l10n, focusProfile),
                  statusLabel: _recommendedActionLabel(l10n, data?.recommendedAction ?? ''),
                  insights: [
                    '${data?.activeProfileCount ?? 0} ${l10n.visaCenterProfiles}',
                    '${data?.attentionRequiredCount ?? 0} ${l10n.visaCenterAttentionRequired}',
                    _focusDaysLabel(l10n, focusProfile),
                  ],
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
                    subtitle: _recommendedActionLabel(l10n, data?.recommendedAction ?? 'create-first-plan'),
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
                  if (focusProfile != null) ...[
                    _SectionHeader(title: l10n.visaCenterFocusProfile),
                    SizedBox(height: 12.h),
                    _FocusVisaCard(
                      profile: focusProfile,
                      expiryLabel: l10n.visaCenterExpiryDate,
                      requirementsLabel: l10n.visaCenterRequirements,
                      processLabel: l10n.visaCenterProcess,
                      costLabel: l10n.budgetCenterForecast,
                      documentsLabel: l10n.visaCenterDocumentsLabel,
                      stayDaysLabel: l10n.visaCenterStayDaysLabel,
                      statusLabel: _profileStatusLabel(l10n, focusProfile.status),
                    ),
                    SizedBox(height: 18.h),
                    _SectionHeader(title: l10n.visaCenterQuickActions),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.bell,
                      title: l10n.visaCenterSetReminder,
                      subtitle: l10n.visaCenterSetReminderSubtitle,
                      onTap: controller.isSettingReminder.value
                          ? () {}
                          : controller.setReminderForFocusProfile,
                    ),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.route,
                      title: l10n.visaCenterOpenPlan,
                      subtitle: l10n.visaCenterOpenPlanSubtitle,
                      onTap: () => _openPlan(focusProfile),
                    ),
                    SizedBox(height: 12.h),
                    HubActionCard(
                      icon: FontAwesomeIcons.filePen,
                      title: l10n.visaCenterEditProfile,
                      subtitle: _editProfileSubtitle(l10n, focusProfile),
                      onTap: () => _openVisaProfileEditor(context, focusProfile),
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
                        expiryLabel: l10n.visaCenterExpiryDate,
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

  String _heroSubtitle(AppLocalizations l10n, VisaProfile? profile) {
    if (profile == null) {
      return _recommendedActionLabel(l10n, 'create-first-plan');
    }

    final daysLabel = _focusDaysLabel(l10n, profile);
    return '${profile.cityName} · $daysLabel';
  }

  String _editProfileSubtitle(AppLocalizations l10n, VisaProfile profile) {
    final typeLabel = _visaTypeLabel(l10n, profile.visaType);
    return '$typeLabel · ${profile.cityName}';
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
  final List<String> insights;
  final VoidCallback onRefreshTap;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.insights,
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
        borderRadius: BorderRadius.circular(AppUiTokens.radiusHero),
        boxShadow: AppUiTokens.heroCardShadow,
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
                  color: AppColors.textWhite.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  FontAwesomeIcons.passport,
                  size: 20.r,
                  color: AppColors.textWhite,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRefreshTap,
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.textWhite.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20.r,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasSubtitle) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textWhite.withValues(alpha: 0.92),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
          ] else
            SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: AppColors.textWhite.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: insights
                .where((item) => item.trim().isNotEmpty && item.trim() != '-')
                .map(
                  (item) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.95),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
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
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 22.h,
          decoration: BoxDecoration(
            color: AppColors.cityPrimary,
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MiniInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusVisaCard extends StatelessWidget {
  final VisaProfile profile;
  final String expiryLabel;
  final String requirementsLabel;
  final String processLabel;
  final String costLabel;
  final String documentsLabel;
  final String stayDaysLabel;
  final String statusLabel;

  const _FocusVisaCard({
    required this.profile,
    required this.expiryLabel,
    required this.requirementsLabel,
    required this.processLabel,
    required this.costLabel,
    required this.documentsLabel,
    required this.stayDaysLabel,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
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
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildTag(_visaTypeLabel(l10n, profile.visaType)),
              _buildTag('$stayDaysLabel · ${profile.stayDurationDays}'),
              if (profile.daysRemaining != null)
                _buildTag(l10n.daysRemaining(profile.daysRemaining!)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _MiniInfoTile(
                  label: expiryLabel,
                  value: profile.expiryDate != null ? _formatDate(profile.expiryDate!) : '-',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MiniInfoTile(
                  label: costLabel,
                  value: profile.estimatedCostUsd > 0
                      ? '\$${profile.estimatedCostUsd.toStringAsFixed(0)}'
                      : '-',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MiniInfoTile(
                  label: documentsLabel,
                  value: '${profile.requiredDocuments.length}',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MiniInfoTile(
                  label: l10n.visaCenterReminderReady,
                  value: '${profile.reminderDates.length}',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildContentBlock(
            label: requirementsLabel,
            value: profile.requirementsSummary,
          ),
          SizedBox(height: 12.h),
          _buildContentBlock(
            label: processLabel,
            value: profile.processSummary,
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlock({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.cityPrimaryLight,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.cityPrimary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
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
  final String expiryLabel;
  final VoidCallback onTap;

  const _VisaProfileCard({
    required this.profile,
    required this.statusLabel,
    required this.expiryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(18.r),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.cityPrimaryLight,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: AppColors.cityPrimary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _visaTypeLabel(l10n, profile.visaType),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _timelineText(l10n),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        height: 1.4,
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

  String _timelineText(AppLocalizations l10n) {
    final dateText = profile.expiryDate == null
        ? '-'
        : '${profile.expiryDate!.year}-${profile.expiryDate!.month.toString().padLeft(2, '0')}-${profile.expiryDate!.day.toString().padLeft(2, '0')}';
    final daysText = profile.daysRemaining == null ? '' : ' · ${l10n.daysRemaining(profile.daysRemaining!)}';
    return '$expiryLabel: $dateText$daysText';
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240.h,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: const Center(child: AppLoadingWidget()),
      ),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              FontAwesomeIcons.circleExclamation,
              color: AppColors.cityPrimaryDark,
              size: 22.r,
            ),
          ),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              FontAwesomeIcons.passport,
              size: 24.r,
              color: AppColors.cityPrimary,
            ),
          ),
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
