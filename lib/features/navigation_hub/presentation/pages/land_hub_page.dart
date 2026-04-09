import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/controllers/land_hub_controller.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/widgets/hub_action_card.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_hero_banner.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_metric_card.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_section_header.dart';

class LandHubPage extends GetView<LandHubController> {
  const LandHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: AppColors.cityPrimary,
            onRefresh: controller.refreshHub,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 108.h),
              children: [
                CockpitHeroBanner(
                  icon: FontAwesomeIcons.suitcaseRolling,
                  title: l10n.landHubTitle,
                  subtitle: '',
                  gradient: const LinearGradient(
                    colors: [AppColors.cityGradientStart, AppColors.cityGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  foregroundColor: Colors.white,
                  panelColor: Colors.white,
                  borderColor: Colors.white,
                  trailing: CockpitGlassIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: controller.refreshHub,
                  ),
                  metrics: [
                    CockpitHeroMetric(
                      icon: Icons.route_outlined,
                      label: '${controller.activePlansCount} ${l10n.migrationWorkspace}',
                    ),
                    CockpitHeroMetric(
                      icon: Icons.savings_outlined,
                      label: '${controller.trackedCityCount} ${l10n.budgetCenter}',
                    ),
                    CockpitHeroMetric(
                      icon: Icons.badge_outlined,
                      label: '${controller.visaAttentionCount} ${l10n.visaCenterAttentionRequired}',
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                if (controller.isLoading.value && !controller.hasData)
                  const _LandLoadingState()
                else ...[
                  CockpitPanel(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CockpitSectionHeader(
                          title: l10n.landHubCurrentFocusTitle,
                        ),
                        SizedBox(height: 12.h),
                        if (!controller.hasData)
                          _LandEmptyState(l10n: l10n)
                        else
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                              childAspectRatio: 1.18,
                            ),
                            children: [
                              CockpitMetricCard(
                                icon: Icons.location_city_rounded,
                                label: l10n.landHubFocusCityLabel,
                                value: controller.focusCityName?.isNotEmpty == true ? controller.focusCityName! : '-',
                                accentColor: const Color(0xFF457B9D),
                              ),
                              CockpitMetricCard(
                                icon: Icons.schedule_rounded,
                                label: l10n.landHubDepartureLabel,
                                value: _departureLabel(l10n),
                                accentColor: const Color(0xFF2A9D8F),
                              ),
                              CockpitMetricCard(
                                icon: Icons.savings_rounded,
                                label: l10n.landHubBudgetLabel,
                                value: _budgetLabel(),
                                accentColor: const Color(0xFFE9C46A),
                              ),
                              CockpitMetricCard(
                                icon: Icons.badge_rounded,
                                label: l10n.landHubVisaLabel,
                                value: _visaLabel(l10n),
                                accentColor: const Color(0xFFFF6B6B),
                              ),
                            ],
                          ),
                        if (controller.hasMigrationPlan) ...[
                          SizedBox(height: 14.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.tonalIcon(
                              onPressed: _openCurrentPlan,
                              icon: const Icon(Icons.route_rounded),
                              label: Text(l10n.migrationWorkspaceOpenPlan),
                              style: FilledButton.styleFrom(
                                minimumSize: Size(0, 38.h),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  CockpitPanel(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CockpitSectionHeader(
                          title: l10n.landHubArrivalLaneTitle,
                        ),
                        SizedBox(height: 12.h),
                        ..._buildArrivalChecklist(l10n).map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _LandingChecklistCard(data: item),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  CockpitPanel(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CockpitSectionHeader(
                          title: l10n.landHubPlanningLaneTitle,
                        ),
                        SizedBox(height: 12.h),
                        HubActionCard(
                          icon: FontAwesomeIcons.route,
                          title: l10n.migrationWorkspace,
                          subtitle: '',
                          badgeCount: controller.activePlansCount,
                          accentColor: const Color(0xFF457B9D),
                          onTap: () => Get.toNamed(AppRoutes.migrationWorkspace),
                        ),
                        SizedBox(height: 10.h),
                        HubActionCard(
                          icon: FontAwesomeIcons.wallet,
                          title: l10n.budgetCenter,
                          subtitle: '',
                          badgeCount: controller.trackedCityCount,
                          accentColor: const Color(0xFFE9C46A),
                          onTap: () => Get.toNamed(AppRoutes.budgetCenter),
                        ),
                        SizedBox(height: 10.h),
                        HubActionCard(
                          icon: FontAwesomeIcons.passport,
                          title: l10n.visaCenter,
                          subtitle: '',
                          badgeCount: controller.visaAttentionCount,
                          accentColor: const Color(0xFFFF6B6B),
                          onTap: () => Get.toNamed(AppRoutes.visaCenter),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  CockpitPanel(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CockpitSectionHeader(
                          title: l10n.landHubResourceLaneTitle,
                        ),
                        SizedBox(height: 12.h),
                        HubActionCard(
                          icon: FontAwesomeIcons.clockRotateLeft,
                          title: l10n.travelHistory,
                          subtitle: '',
                          accentColor: const Color(0xFF6C757D),
                          onTap: () => Get.toNamed(AppRoutes.travelHistory),
                        ),
                      ],
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

  String _departureLabel(AppLocalizations l10n) {
    final date = controller.focusDepartureDate;
    if (date == null) {
      return l10n.landHubPendingLabel;
    }

    return '${date.month}/${date.day}';
  }

  String _budgetLabel() {
    final amount = controller.focusMonthlyBudgetUsd;
    if (amount == null || amount <= 0) {
      return '-';
    }

    return '\$${amount.toStringAsFixed(0)}';
  }

  String _visaLabel(AppLocalizations l10n) {
    final days = controller.focusVisaDaysRemaining;
    if (days == null) {
      return l10n.landHubPendingLabel;
    }

    return l10n.daysRemaining(days);
  }

  List<_LandingChecklistCardData> _buildArrivalChecklist(AppLocalizations l10n) {
    final cityName = controller.focusCityName ?? l10n.landHubPendingLabel;
    final cityId = controller.focusCityId;
    final daysUntilDeparture = controller.daysUntilDeparture;
    final isDepartureUrgent = daysUntilDeparture != null && daysUntilDeparture <= 14;
    final hasDeparture = controller.hasDepartureLocked;
    final hasBudgetBaseline = controller.hasBudgetBaseline;
    final hasVisaClock = controller.focusVisaDaysRemaining != null;
    final hasVisaProfile = controller.hasVisaProfile;
    final hasMigrationPlan = controller.hasMigrationPlan;
    final hasFocusCity = controller.hasFocusCity;
    final hasArrivalPlan = controller.hasArrivalPlan;
    final hasAccommodationPlan = controller.hasAccommodationPlan;
    final hasLocalTransportPlan = controller.hasLocalTransportPlan;

    return [
      _LandingChecklistCardData(
        icon: Icons.flight_land_rounded,
        title: l10n.landHubChecklistArrivalTitle,
        subtitle: hasArrivalPlan
            ? l10n.landHubChecklistArrivalDetailed(
                _formatMethodLabel(controller.focusArrivalPlan?.method),
                controller.focusArrivalPlan?.details ?? l10n.landHubPendingLabel,
              )
            : hasDeparture
                ? l10n.landHubChecklistArrivalReady(_departureLabel(l10n))
                : l10n.landHubChecklistArrivalPending,
        trackingNote: '',
        statusLabel: hasArrivalPlan
            ? l10n.landHubChecklistDetailed
            : hasDeparture
                ? l10n.landHubChecklistLocked
                : (isDepartureUrgent ? l10n.landHubChecklistNow : l10n.landHubChecklistNext),
        statusColor: hasArrivalPlan
            ? const Color(0xFF2A9D8F)
            : hasDeparture
                ? const Color(0xFF2A9D8F)
                : (isDepartureUrgent ? const Color(0xFFFF6B6B) : const Color(0xFF457B9D)),
        actionLabel: l10n.migrationWorkspaceOpenPlan,
        onTap: hasMigrationPlan ? _openCurrentPlan : () => Get.toNamed(AppRoutes.migrationWorkspace),
      ),
      _LandingChecklistCardData(
        icon: Icons.hotel_rounded,
        title: l10n.landHubChecklistStayTitle,
        subtitle: hasAccommodationPlan
            ? l10n.landHubChecklistStayDetailed(
                cityName,
                controller.focusAccommodationPlan?.recommendedArea ?? l10n.landHubPendingLabel,
                _formatNightlyRate(controller.focusAccommodationPlan?.pricePerNight),
              )
            : hasBudgetBaseline
                ? l10n.landHubChecklistStayWithBudget(cityName, _budgetLabel())
                : l10n.landHubChecklistStaySubtitle(cityName),
        trackingNote: '',
        statusLabel: hasAccommodationPlan
            ? l10n.landHubChecklistShortlisted
            : hasBudgetBaseline
                ? l10n.landHubChecklistBaselineReady
                : (isDepartureUrgent ? l10n.landHubChecklistNow : l10n.landHubChecklistNext),
        statusColor: const Color(0xFF2A9D8F),
        actionLabel: l10n.accommodation,
        onTap: () => Get.toNamed(AppRoutes.hotelList, arguments: {
          'cityId': cityId ?? '',
          'cityName': cityName,
        }),
      ),
      _LandingChecklistCardData(
        icon: Icons.laptop_mac_rounded,
        title: l10n.landHubChecklistWorkTitle,
        subtitle: l10n.landHubChecklistWorkSubtitle(cityName),
        trackingNote: '',
        statusLabel: hasMigrationPlan ? l10n.landHubChecklistPlanningLive : l10n.landHubChecklistNext,
        statusColor: const Color(0xFF457B9D),
        actionLabel: l10n.coworking,
        onTap: () => Get.toNamed(AppRoutes.coworkingList, arguments: {
          'cityId': cityId ?? '',
          'cityName': cityName,
        }),
      ),
      _LandingChecklistCardData(
        icon: Icons.directions_transit_rounded,
        title: l10n.landHubChecklistTransportTitle,
        subtitle: hasLocalTransportPlan
            ? l10n.landHubChecklistTransportDetailed(
                _formatMethodLabel(controller.focusLocalTransportPlan?.method),
                controller.focusLocalTransportPlan?.details ?? l10n.landHubPendingLabel,
              )
            : l10n.landHubChecklistTransportSubtitle(cityName),
        trackingNote: '',
        statusLabel: hasLocalTransportPlan
            ? l10n.landHubChecklistMapped
            : hasFocusCity
                ? l10n.landHubChecklistCityScoped
                : l10n.landHubChecklistNext,
        statusColor: const Color(0xFFE9C46A),
        actionLabel: l10n.localTransport,
        onTap: () {
          if (cityId != null && cityId.isNotEmpty) {
            Get.toNamed(
              AppRoutes.cityDetail,
              arguments: {
                'cityId': cityId,
                'cityName': cityName,
              },
            );
            return;
          }

          Get.toNamed(AppRoutes.globalMap);
        },
      ),
      _LandingChecklistCardData(
        icon: Icons.sim_card_rounded,
        title: l10n.landHubChecklistConnectivityTitle,
        subtitle: hasVisaClock
            ? l10n.landHubChecklistConnectivityWithVisa(cityName, _visaLabel(l10n))
            : l10n.landHubChecklistConnectivitySubtitle(cityName),
        trackingNote: '',
        statusLabel: hasVisaProfile
            ? l10n.landHubChecklistVisaLinked
            : (hasVisaClock ? l10n.landHubChecklistWatch : l10n.landHubChecklistNext),
        statusColor: hasVisaProfile ? const Color(0xFFFF6B6B) : const Color(0xFF6C757D),
        actionLabel: l10n.aiChat,
        onTap: () => Get.toNamed(AppRoutes.aiChat),
      ),
    ];
  }

  String _formatMethodLabel(String? method) {
    if (method == null || method.trim().isEmpty) {
      return '-';
    }

    final normalized = method.replaceAll('_', ' ').trim();
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _formatNightlyRate(double? pricePerNight) {
    if (pricePerNight == null || pricePerNight <= 0) {
      return '-';
    }

    return '\$${pricePerNight.toStringAsFixed(0)}/night';
  }

  void _openCurrentPlan() {
    final summary = controller.migrationWorkspace.value?.latestPlan;
    final planId = summary?.id ?? controller.focusPlanId;
    if (planId == null || planId.isEmpty) {
      Get.toNamed(AppRoutes.migrationWorkspace);
      return;
    }

    Get.toNamed(
      AppRoutes.travelPlan,
      arguments: {
        'planId': planId,
        'cityId': summary?.cityId ?? controller.focusCityId,
        'cityName': summary?.cityName ?? controller.focusCityName,
        'summary': summary,
      },
    );
  }
}

class _LandingChecklistCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trackingNote;
  final String statusLabel;
  final Color statusColor;
  final String actionLabel;
  final VoidCallback onTap;

  const _LandingChecklistCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trackingNote,
    required this.statusLabel,
    required this.statusColor,
    required this.actionLabel,
    required this.onTap,
  });
}

class _LandingChecklistCard extends StatelessWidget {
  final _LandingChecklistCardData data;

  const _LandingChecklistCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasTrackingNote = data.trackingNote.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: data.statusColor.withValues(alpha: 0.05),
            blurRadius: 18.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: data.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(data.icon, color: data.statusColor, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: data.statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        data.statusLabel,
                        style: TextStyle(
                          color: data.statusColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                if (hasTrackingNote) ...[
                  SizedBox(height: 6.h),
                  Text(
                    data.trackingNote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                      fontSize: 11.sp,
                      height: 1.25,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                OutlinedButton(
                  onPressed: data.onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: data.statusColor,
                    side: BorderSide(color: data.statusColor.withValues(alpha: 0.4)),
                    minimumSize: Size(0, 34.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(data.actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandLoadingState extends StatelessWidget {
  const _LandLoadingState();

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

class _LandEmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _LandEmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        FilledButton.tonalIcon(
          onPressed: () => Get.toNamed(AppRoutes.createTravelPlan),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l10n.createTravelPlan),
          style: FilledButton.styleFrom(
            minimumSize: Size(0, 38.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
        ),
      ],
    );
  }
}
