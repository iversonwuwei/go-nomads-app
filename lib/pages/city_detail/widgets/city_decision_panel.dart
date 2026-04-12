import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_nomad_summary.dart';
import 'package:go_nomads_app/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/pages/city_detail/widgets/ai_travel_plan_fab.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/planning/planning_launch_components.dart';

class CityDecisionPanel extends GetView<CityDetailController> {
  final String? _tag;

  const CityDecisionPanel({
    super.key,
    required String? tag,
  }) : _tag = tag;

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cityDetailController = Get.find<CityDetailStateController>();
    final aiController = Get.find<AiStateController>();

    _ensureGuideData(aiController);

    return Obx(() {
      final city = cityDetailController.currentCity.value;
      if (city == null) {
        return const SizedBox.shrink();
      }

      final guide = _resolveGuide(aiController);
      final nomadSummary = cityDetailController.currentNomadSummary.value;
      final snapshot = _buildSnapshot(city, guide, nomadSummary);
      final budgetLabel = _formatBudget(city, nomadSummary);
        final hasShortlists = nomadSummary?.recommendedStays.isNotEmpty == true ||
          nomadSummary?.recommendedCoworkings.isNotEmpty == true ||
          nomadSummary?.upcomingMeetups.isNotEmpty == true;

      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DecisionHero(
              title: l10n.cityDecisionTitle,
              subtitle: l10n.cityDecisionSubtitle(city.fullLocation),
              budgetLabel: budgetLabel,
              timezoneLabel: city.displayTimezone,
              guideLabel: guide != null ? l10n.cityDecisionGuideReady : l10n.cityDecisionGuideLoading,
            ),
            SizedBox(height: 14.h),
            _DecisionTravelPlanLaunchCard(
              cityName: city.name,
              budgetLabel: budgetLabel,
              timezoneLabel: city.displayTimezone,
              planningHint: guide?.visaInfo.type.isNotEmpty == true
                  ? '${guide!.visaInfo.type} · ${guide.visaInfo.duration} ${l10n.days(guide.visaInfo.duration)}'
                  : (guide != null ? l10n.cityDecisionGuideReady : l10n.cityDecisionGuideLoading),
              onTap: () => _openCreateTravelPlan(context),
            ),
            SizedBox(height: 14.h),
            _SectionHeader(
              title: l10n.cityDecisionSignals,
              caption: 'Travel brief signals',
            ),
            SizedBox(height: 10.h),
            Column(
              children: [
                _LeadDecisionCard(
                  budgetLabel: budgetLabel,
                  timezoneLabel: city.displayTimezone,
                  guideLabel: guide?.visaInfo.type.isNotEmpty == true
                      ? '${guide!.visaInfo.type} · ${guide.visaInfo.duration} ${l10n.days}'
                      : (guide != null ? l10n.cityDecisionGuideReady : l10n.cityDecisionGuideLoading),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    _SignalCard(
                      label: l10n.cityDecisionInternet,
                      value: snapshot.networkQualityScore,
                      icon: FontAwesomeIcons.wifi,
                    ),
                    _SignalCard(
                      label: l10n.cityDecisionVideoCall,
                      value: snapshot.videoCallFriendlinessScore,
                      icon: FontAwesomeIcons.video,
                    ),
                    _SignalCard(
                      label: l10n.visa,
                      value: snapshot.visaFriendlinessScore,
                      icon: FontAwesomeIcons.passport,
                    ),
                    _SignalCard(
                      label: l10n.timezone,
                      value: snapshot.timezoneOverlapScore,
                      caption: city.displayTimezone,
                      icon: FontAwesomeIcons.clock,
                    ),
                    _SignalCard(
                      label: l10n.cityDecisionCommunity,
                      value: snapshot.communityActivityScore,
                      icon: FontAwesomeIcons.userGroup,
                    ),
                    _SignalCard(
                      label: l10n.cityDecisionClimate,
                      value: snapshot.climateStabilityScore,
                      icon: FontAwesomeIcons.cloudSun,
                    ),
                    _SignalCard(
                      label: l10n.safety,
                      value: snapshot.safetyScore,
                      icon: FontAwesomeIcons.shieldHeart,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            if (guide?.visaInfo.type.isNotEmpty == true) ...[
              _SectionHeader(
                title: l10n.cityDecisionVisaSummary,
                caption: 'Entry path',
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF0DA), Color(0xFFFFE1BF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide!.visaInfo.type,
                      style: TextStyle(
                        color: AppColors.cityPrimaryDark,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${guide.visaInfo.duration} ${l10n.days}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      guide.visaInfo.requirements,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
            ],
            _SectionHeader(
              title: l10n.cityDecisionActions,
              caption: 'Launch lanes',
            ),
            SizedBox(height: 10.h),
            _DecisionActionRail(
              actions: [
                _ActionButtonData(
                  icon: FontAwesomeIcons.hotel,
                  label: l10n.hotels,
                  onTap: () => _openHotels(city),
                ),
                _ActionButtonData(
                  icon: FontAwesomeIcons.houseLaptop,
                  label: l10n.coworking,
                  onTap: () => _openCoworking(city),
                ),
                _ActionButtonData(
                  icon: FontAwesomeIcons.peopleGroup,
                  label: l10n.meetups,
                  onTap: _openMeetups,
                ),
                _ActionButtonData(
                  icon: FontAwesomeIcons.scaleBalanced,
                  label: l10n.compareCities,
                  onTap: _openCityCompare,
                ),
              ],
            ),
            if (hasShortlists) ...[
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBF7), Color(0xFFF8FBFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE7DED0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                      title: 'Decision shortlists',
                      caption: 'Shortlist lanes',
                    ),
                    if (nomadSummary?.recommendedStays.isNotEmpty == true) ...[
                      SizedBox(height: 14.h),
                      _PreviewSection(
                        title: 'Stay shortlist',
                        eyebrow: l10n.hotels,
                        actionLabel: l10n.seeAll,
                        onActionTap: () => _openHotels(city),
                        children: nomadSummary!.recommendedStays
                            .take(2)
                            .map(
                              (stay) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _PreviewCard(
                                  icon: FontAwesomeIcons.hotel,
                                  title: stay.name,
                                  primaryMeta: '${stay.rating.toStringAsFixed(1)} ★',
                                  secondaryMeta: stay.pricePerNight == null
                                      ? null
                                      : '${stay.pricePerNight!.toStringAsFixed(0)} ${stay.currency}/night',
                                  onTap: () => _openStayPreview(city, stay),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    if (nomadSummary?.recommendedCoworkings.isNotEmpty == true) ...[
                      SizedBox(height: 8.h),
                      _PreviewSection(
                        title: 'Workspace shortlist',
                        eyebrow: l10n.coworking,
                        actionLabel: l10n.seeAll,
                        onActionTap: () => _openCoworking(city),
                        children: nomadSummary!.recommendedCoworkings
                            .take(2)
                            .map(
                              (space) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _PreviewCard(
                                  icon: FontAwesomeIcons.houseLaptop,
                                  title: space.name,
                                  primaryMeta: '${space.rating.toStringAsFixed(1)} ★',
                                  secondaryMeta: space.dayPassPrice == null
                                      ? null
                                      : '${space.dayPassPrice!.toStringAsFixed(0)} ${space.currency}/day',
                                  onTap: () => _openCoworking(city),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    if (nomadSummary?.upcomingMeetups.isNotEmpty == true) ...[
                      SizedBox(height: 8.h),
                      _PreviewSection(
                        title: 'Connection shortlist',
                        eyebrow: l10n.upcomingMeetups,
                        actionLabel: l10n.viewAllMeetups,
                        onActionTap: _openMeetups,
                        children: nomadSummary!.upcomingMeetups
                            .take(2)
                            .map(
                              (meetup) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _PreviewCard(
                                  icon: FontAwesomeIcons.peopleGroup,
                                  title: meetup.title,
                                  primaryMeta: meetup.startTime == null
                                      ? l10n.upcoming
                                      : _formatMeetupDate(meetup.startTime!),
                                  secondaryMeta: meetup.venue?.trim().isNotEmpty == true
                                      ? meetup.venue!.trim()
                                      : '${meetup.participantCount} joined',
                                  onTap: () => _openMeetupPreview(meetup.id),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _ensureGuideData(AiStateController aiController) {
    if (controller.hasInitializedGuide.value && controller.lastGuideLoadedCityId.value == controller.cityId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentGuide = aiController.currentGuide;

      if (currentGuide != null && currentGuide.cityId != controller.cityId) {
        aiController.resetGuideState();
      }

      if (!aiController.isGeneratingGuide && !aiController.isLoadingGuide) {
        final shouldLoad = currentGuide == null || currentGuide.cityId != controller.cityId;
        if (shouldLoad) {
          aiController.loadCityGuide(cityId: controller.cityId, cityName: controller.cityName);
        }
      }

      controller.hasInitializedGuide.value = true;
      controller.lastGuideLoadedCityId.value = controller.cityId;
    });
  }

  DigitalNomadGuide? _resolveGuide(AiStateController aiController) {
    final guide = aiController.currentGuide;
    if (guide == null || guide.cityId != controller.cityId) {
      return null;
    }

    return guide;
  }

  _DecisionSnapshot _buildSnapshot(
    City city,
    DigitalNomadGuide? guide,
    CityNomadSummary? nomadSummary,
  ) {
    final summarySignals = nomadSummary?.decisionSignals;
    final networkQualityScore = _scaleFivePoint(city.displayInternetScore);
    final communityActivityScore = _scaleFivePoint(city.communityScore ?? _communityFallback(city));
    final climateStabilityScore = _scaleFivePoint(city.weatherScore ?? _weatherFallback(city));
    final safetyScore = _scaleFivePoint(city.displaySafetyScore);
    final visaFriendlinessScore = _visaScore(guide?.visaInfo);
    final timezoneOverlapScore = _timezoneScore(city.displayTimezone);
    final videoCallFriendlinessScore = ((networkQualityScore * 0.7) + (_coworkingBoost(city) * 0.3)).round();

    return _DecisionSnapshot(
      networkQualityScore: summarySignals?.networkQualityScore ?? networkQualityScore,
      videoCallFriendlinessScore:
          summarySignals?.videoCallFriendlinessScore ?? videoCallFriendlinessScore,
      visaFriendlinessScore:
          summarySignals?.visaFriendlinessScore ?? visaFriendlinessScore,
      timezoneOverlapScore:
          summarySignals?.timezoneOverlapScore ?? timezoneOverlapScore,
      communityActivityScore:
          summarySignals?.communityActivityScore ?? communityActivityScore,
      climateStabilityScore:
          summarySignals?.climateStabilityScore ?? climateStabilityScore,
      safetyScore: summarySignals?.safetyScore ?? safetyScore,
    );
  }

  int _scaleFivePoint(double score) {
    return ((score / 5) * 100).clamp(0, 100).round();
  }

  double _communityFallback(City city) {
    if (city.displayMeetupCount >= 10) {
      return 4.5;
    }
    if (city.displayMeetupCount >= 5) {
      return 4.0;
    }
    if (city.displayMeetupCount >= 2) {
      return 3.5;
    }
    return 3.0;
  }

  double _weatherFallback(City city) {
    final humidity = city.displayHumidity;
    if (humidity >= 45 && humidity <= 70) {
      return 4.0;
    }
    if (humidity >= 35 && humidity <= 80) {
      return 3.5;
    }
    return 3.0;
  }

  int _visaScore(VisaInfo? visaInfo) {
    if (visaInfo == null || visaInfo.duration <= 0) {
      return 45;
    }

    if (visaInfo.duration >= 180) {
      return 92;
    }
    if (visaInfo.duration >= 90) {
      return 82;
    }
    if (visaInfo.duration >= 60) {
      return 72;
    }
    if (visaInfo.duration >= 30) {
      return 60;
    }
    return 46;
  }

  int _timezoneScore(String timezone) {
    final normalized = timezone.toUpperCase();
    final match = RegExp(r'([+-]\d{1,2})').firstMatch(normalized);
    if (match == null) {
      return 65;
    }

    final offset = int.tryParse(match.group(1) ?? '0') ?? 0;
    final distanceFromUtc8 = (offset - 8).abs();
    final score = 92 - (distanceFromUtc8 * 8);
    return score.clamp(40, 92);
  }

  int _coworkingBoost(City city) {
    if (city.displayCoworkingCount >= 10) {
      return 95;
    }
    if (city.displayCoworkingCount >= 5) {
      return 84;
    }
    if (city.displayCoworkingCount >= 1) {
      return 72;
    }
    return 58;
  }

  String _formatBudget(City city, CityNomadSummary? nomadSummary) {
    final budgetRange = nomadSummary?.monthlyBudgetRange;
    if (budgetRange != null && budgetRange.min > 0 && budgetRange.max > 0) {
      return '${budgetRange.min.toStringAsFixed(0)}-${budgetRange.max.toStringAsFixed(0)} ${budgetRange.currency}';
    }

    final currency = city.currency?.isNotEmpty == true ? city.currency! : 'USD';
    return '${city.displayAverageCost.toStringAsFixed(0)} $currency';
  }

  void _openCreateTravelPlan(BuildContext context) {
    openAiTravelPlanEntry(
      context,
      cityId: controller.cityId,
      cityName: controller.cityName,
    );
  }

  void _openHotels(City city) {
    Get.toNamed(
      AppRoutes.hotelList,
      arguments: {
        'cityId': controller.cityId,
        'cityName': controller.cityName,
      },
    );
  }

  void _openCoworking(City city) {
    Get.toNamed(
      AppRoutes.coworkingList,
      arguments: {
        'cityId': controller.cityId,
        'cityName': controller.cityName,
        'countryName': city.country,
      },
    );
  }

  void _openMeetups() {
    Get.toNamed(AppRoutes.meetupsList);
  }

  void _openMeetupPreview(String meetupId) {
    Get.toNamed(
      AppRoutes.meetupDetail,
      arguments: {'meetupId': meetupId},
    );
  }

  void _openStayPreview(City city, CityStayPreview stay) {
    final hotelId = int.tryParse(stay.id);
    if (hotelId != null) {
      Get.toNamed(AppRoutes.hotelDetail, arguments: hotelId);
      return;
    }

    _openHotels(city);
  }

  String _formatMeetupDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _openCityCompare() {
    Get.toNamed(AppRoutes.cityList);
  }
}

class _DecisionSnapshot {
  final int networkQualityScore;
  final int videoCallFriendlinessScore;
  final int visaFriendlinessScore;
  final int timezoneOverlapScore;
  final int communityActivityScore;
  final int climateStabilityScore;
  final int safetyScore;

  const _DecisionSnapshot({
    required this.networkQualityScore,
    required this.videoCallFriendlinessScore,
    required this.visaFriendlinessScore,
    required this.timezoneOverlapScore,
    required this.communityActivityScore,
    required this.climateStabilityScore,
    required this.safetyScore,
  });
}

class _DecisionHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String budgetLabel;
  final String timezoneLabel;
  final String guideLabel;

  const _DecisionHero({
    required this.title,
    required this.subtitle,
    required this.budgetLabel,
    required this.timezoneLabel,
    required this.guideLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF), Color(0xFFFFF5F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.heroCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  FontAwesomeIcons.compassDrafting,
                  color: AppColors.cityPrimary,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            budgetLabel,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'monthly move baseline',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _HeroChip(icon: FontAwesomeIcons.clock, label: timezoneLabel),
              _HeroChip(icon: FontAwesomeIcons.wandMagicSparkles, label: guideLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: AppColors.cityPrimary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String caption;

  const _SectionHeader({required this.title, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption.toUpperCase(),
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10.sp,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LeadDecisionCard extends StatelessWidget {
  final String budgetLabel;
  final String timezoneLabel;
  final String guideLabel;

  const _LeadDecisionCard({
    required this.budgetLabel,
    required this.timezoneLabel,
    required this.guideLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            'Move-readiness board',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _LeadStat(label: 'Budget', value: budgetLabel),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _LeadStat(label: 'Timezone', value: timezoneLabel),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              guideLabel,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadStat extends StatelessWidget {
  final String label;
  final String value;

  const _LeadStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionTravelPlanLaunchCard extends StatelessWidget {
  final String cityName;
  final String budgetLabel;
  final String timezoneLabel;
  final String planningHint;
  final VoidCallback onTap;

  const _DecisionTravelPlanLaunchCard({
    required this.cityName,
    required this.budgetLabel,
    required this.timezoneLabel,
    required this.planningHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF), Color(0xFFFFF7F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: AppColors.cityPrimary,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiTravelPlanner,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.planYourTrip(cityName),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Turn this decision snapshot into a Travel Brief, then carry your preference stack and shortlist into the AI planner.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              PlanningStageChip(label: 'Travel Brief', value: budgetLabel, minWidth: 104.w),
              PlanningStageChip(label: 'Preference Stack', value: timezoneLabel, minWidth: 104.w),
              PlanningStageChip(label: 'Research Launch', value: planningHint, minWidth: 104.w),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.route_rounded),
              label: Text(l10n.createTravelPlan),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  final String label;
  final int value;
  final String? caption;
  final IconData icon;

  const _SignalCard({
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(value);

    return SizedBox(
      width: 148.w,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 13.r, color: accent),
                ),
                const Spacer(),
                Text(
                  '$value',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 6.h,
                backgroundColor: accent.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            if (caption != null) ...[
              SizedBox(height: 6.h),
              Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _accentColor(int score) {
    if (score >= 80) {
      return AppColors.travelMint;
    }
    if (score >= 65) {
      return AppColors.travelAmber;
    }
    return AppColors.cityPrimaryDark;
  }
}

class _ActionButtonData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButtonData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _DecisionActionRail extends StatelessWidget {
  final List<_ActionButtonData> actions;

  const _DecisionActionRail({
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions
            .map(
              (action) => Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: _ActionButton(action: action),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _ActionButtonData action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 14.r, color: AppColors.cityPrimary),
              SizedBox(width: 8.w),
              Text(
                action.label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final String eyebrow;
  final String actionLabel;
  final VoidCallback onActionTap;
  final List<Widget> children;

  const _PreviewSection({
    required this.title,
    required this.eyebrow,
    required this.actionLabel,
    required this.onActionTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10.sp,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: onActionTap,
              child: Text(actionLabel),
            ),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String primaryMeta;
  final String? secondaryMeta;
  final VoidCallback onTap;

  const _PreviewCard({
    required this.icon,
    required this.title,
    required this.primaryMeta,
    required this.onTap,
    this.secondaryMeta,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: AppColors.surfaceElevated,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.cityPrimaryLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 15.r, color: AppColors.cityPrimary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _PreviewMetaPill(label: primaryMeta),
                        if (secondaryMeta != null && secondaryMeta!.trim().isNotEmpty)
                          _PreviewMetaPill(label: secondaryMeta!),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 12.r,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewMetaPill extends StatelessWidget {
  final String label;

  const _PreviewMetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
