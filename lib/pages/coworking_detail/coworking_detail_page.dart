import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_amenities_hours_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_comments_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_contact_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_image_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_info_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_pricing_specs_section.dart';
import 'package:go_nomads_app/pages/osm_navigation_page.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

class CoworkingDetailPage extends StatelessWidget {
  final CoworkingSpace space;

  const CoworkingDetailPage({super.key, required this.space});

  String get _controllerTag => 'coworking_detail_${space.id}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CoworkingDetailPageController(initialSpace: space),
      tag: _controllerTag,
    );

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(controller);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320.h,
              pinned: true,
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: SliverBackButton(onPressed: () => _handleBack(controller)),
              actions: [
                CoworkingDetailImageCounterBadge(controllerTag: _controllerTag),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _CoworkingHero(controllerTag: _controllerTag),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -40.h),
                      child: _CoworkingSummaryCard(controllerTag: _controllerTag),
                    ),
                    SizedBox(height: 4.h),
                    _CoworkingSectionCard(
                      eyebrow: 'Work signals',
                      title: 'What this space is optimized for',
                      child: _CoworkingSignalBoard(controllerTag: _controllerTag),
                    ),
                    SizedBox(height: 16.h),
                    _CoworkingSectionCard(
                      eyebrow: 'Context',
                      title: 'Story and location',
                      child: Column(
                        children: [
                          CoworkingDetailAddressSection(controllerTag: _controllerTag),
                          Divider(height: 1, color: AppColors.divider),
                          CoworkingDetailAboutSection(controllerTag: _controllerTag),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _CoworkingSectionCard(
                      eyebrow: 'Desk economics',
                      title: 'Pricing and specs',
                      child: Column(
                        children: [
                          CoworkingDetailPricingSection(controllerTag: _controllerTag),
                          Divider(height: 1, color: AppColors.divider),
                          CoworkingDetailSpecsSection(controllerTag: _controllerTag),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _CoworkingSectionCard(
                      eyebrow: 'Comfort',
                      title: 'Amenities and hours',
                      child: Column(
                        children: [
                          CoworkingDetailAmenitiesSection(controllerTag: _controllerTag),
                          CoworkingDetailOpeningHoursSection(controllerTag: _controllerTag),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _CoworkingSectionCard(
                      eyebrow: 'Reach out',
                      title: 'Contact and community proof',
                      child: Column(
                        children: [
                          CoworkingDetailContactSection(controllerTag: _controllerTag),
                          Divider(height: 1, color: AppColors.divider),
                          CoworkingDetailCommentsSection(controllerTag: _controllerTag),
                        ],
                      ),
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, l10n, controller),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n, CoworkingDetailPageController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: AppUiTokens.softTopSheetShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(FontAwesomeIcons.diamondTurnRight),
              label: Text(l10n.directions),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              onPressed: () => Get.to(() => OSMNavigationPage(coworkingSpace: controller.space.value)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(() => ElevatedButton.icon(
                  icon: const Icon(FontAwesomeIcons.globe),
                  label: Text(l10n.visitWebsite),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: AppColors.cityPrimary,
                    disabledBackgroundColor: AppColors.surfaceDisabled,
                    disabledForegroundColor: AppColors.textTertiary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  onPressed: controller.space.value.contactInfo.hasWebsite
                      ? () => controller.launchURL(controller.space.value.contactInfo.website)
                      : null,
                )),
          ),
        ],
      ),
    );
  }

  void _handleBack(CoworkingDetailPageController controller) {
    NavigationUtil.backFromDetail<CoworkingSpace>(
      entity: controller.space.value,
      hasChanged: controller.hasDataChanged.value,
      context: Get.context,
    );
    _cleanupController();
  }

  void _cleanupController() {
    if (Get.isRegistered<CoworkingDetailPageController>(tag: _controllerTag)) {
      Get.delete<CoworkingDetailPageController>(tag: _controllerTag);
    }
  }
}

class _CoworkingHero extends StatelessWidget {
  const _CoworkingHero({required this.controllerTag});

  final String controllerTag;

  CoworkingDetailPageController get _controller => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CoworkingDetailImageSection(controllerTag: controllerTag),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.04),
                Colors.black.withValues(alpha: 0.12),
                const Color(0xFF15212B).withValues(alpha: 0.78),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 32.h,
          child: Obx(() {
            final currentSpace = _controller.space.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _HeroTag(
                      icon: FontAwesomeIcons.building,
                      label: currentSpace.isVerified ? 'Verified work hub' : 'Community workspace',
                    ),
                    if (currentSpace.pricing.hasFreeTrial)
                      const _HeroTag(
                        icon: FontAwesomeIcons.wandMagicSparkles,
                        label: 'Free trial',
                      ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  currentSpace.name,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.locationDot, size: 12.r, color: Colors.white70),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        currentSpace.fullAddress,
                        style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _CoworkingSummaryCard extends StatelessWidget {
  const _CoworkingSummaryCard({required this.controllerTag});

  final String controllerTag;

  CoworkingDetailPageController get _controller => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSpace = _controller.space.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.heroCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workspace profile',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: AppColors.cityPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        currentSpace.spaceInfo.rating > 0 ? 'Rated work base' : 'Fresh work base',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        currentSpace.creatorName?.isNotEmpty == true
                            ? 'Shared by ${currentSpace.creatorName}'
                            : 'Scout the daily setup before you lock the week.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentSpace.lowestPrice > 0
                            ? '${currentSpace.pricing.currency} ${currentSpace.lowestPrice.toStringAsFixed(0)}'
                            : 'Flexible',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        currentSpace.lowestPrice > 0 ? 'starting rate' : 'price on request',
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Rating',
                    value: currentSpace.spaceInfo.rating > 0 ? currentSpace.spaceInfo.rating.toStringAsFixed(1) : 'N/A',
                    hint: '${currentSpace.spaceInfo.reviewCount} reviews',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Value score',
                    value: currentSpace.valueScore.toString(),
                    hint: currentSpace.hasHighSpeedInternet ? 'Fast internet detected' : 'Check internet quality',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Social proof',
                    value: currentSpace.verificationVotes.toString(),
                    hint: currentSpace.isVerified ? 'verification votes' : 'awaiting more proof',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _CoworkingSignalBoard extends StatelessWidget {
  const _CoworkingSignalBoard({required this.controllerTag});

  final String controllerTag;

  CoworkingDetailPageController get _controller => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSpace = _controller.space.value;
      final signals = [
        _WorkspaceSignal(
          label: 'Internet',
          value: currentSpace.specs.wifiSpeed != null
              ? '${currentSpace.specs.wifiSpeed!.toStringAsFixed(0)} Mbps'
              : 'Unknown',
          detail: currentSpace.hasHighSpeedInternet ? 'Remote-work grade' : 'Verify before deep work days',
          icon: FontAwesomeIcons.wifi,
          accent: const Color(0xFF276A88),
        ),
        _WorkspaceSignal(
          label: 'Space type',
          value: currentSpace.specs.spaceType?.name ?? 'Mixed',
          detail: currentSpace.amenities.hasMeetingRoom ? 'Supports team syncs' : 'Best for solo sessions',
          icon: FontAwesomeIcons.tableCellsLarge,
          accent: const Color(0xFF855129),
        ),
        _WorkspaceSignal(
          label: 'Access',
          value: currentSpace.is24HourAccess ? '24/7' : 'Standard hours',
          detail: currentSpace.pricing.hasFreeTrial ? 'Trial available' : 'Commitment required',
          icon: FontAwesomeIcons.clock,
          accent: const Color(0xFF3E7B59),
        ),
        _WorkspaceSignal(
          label: 'Capacity',
          value: currentSpace.specs.capacity?.toString() ?? 'N/A',
          detail: currentSpace.specs.numberOfMeetingRooms != null
              ? '${currentSpace.specs.numberOfMeetingRooms} meeting rooms'
              : 'Meeting room data unavailable',
          icon: FontAwesomeIcons.users,
          accent: const Color(0xFF6F3D78),
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 12.w) / 2;
          return Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: signals
                .map(
                  (signal) => SizedBox(
                    width: width,
                    child: _SignalTile(signal: signal),
                  ),
                )
                .toList(),
          );
        },
      );
    });
  }
}

class _CoworkingSectionCard extends StatelessWidget {
  const _CoworkingSectionCard({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.cityPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _WorkspaceSignal {
  const _WorkspaceSignal({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.signal});

  final _WorkspaceSignal signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: signal.accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: signal.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(signal.icon, size: 16.r, color: signal.accent),
          ),
          SizedBox(height: 14.h),
          Text(
            signal.label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: signal.accent),
          ),
          SizedBox(height: 8.h),
          Text(
            signal.value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            signal.detail,
            style: TextStyle(fontSize: 12.sp, height: 1.45, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.cityPrimary)),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 4.h),
          Text(hint, style: TextStyle(fontSize: 11.sp, height: 1.35, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
