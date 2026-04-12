import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_attendees_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_basic_info_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_bottom_action_bar.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_description_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_image_carousel.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_organizer_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_time_location_section.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/utils/share_link_util.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:go_nomads_app/widgets/report_button.dart';
import 'package:go_nomads_app/widgets/report_dialog.dart';
import 'package:go_nomads_app/widgets/share_bottom_sheet.dart';
import 'package:go_nomads_app/widgets/share_button.dart';
import 'package:intl/intl.dart';

/// Meetup 详情页面
///
/// 使用 GetView 模式，遵循 GetX 标准实践:
/// - 继承 GetView[MeetupDetailController]
/// - 通过 Binding 注入依赖
/// - 页面由多个小组件组成
class MeetupDetailPage extends GetView<MeetupDetailController> {
  final Meetup? meetup;
  final String? meetupId;

  const MeetupDetailPage({
    super.key,
    this.meetup,
    this.meetupId,
  }) : assert(meetup != null || meetupId != null, 'meetup or meetupId is required');

  @override
  Widget build(BuildContext context) {
    // 初始化 Controller 的数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureMeetupLoaded(initialMeetup: meetup, meetupId: meetupId);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Stack(
              children: [
                const AppSceneLoading(
                  scene: AppLoadingScene.meetupDetail,
                  fullScreen: true,
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SliverBackButton(
                      onPressed: controller.handleBack,
                      opacity: 0,
                    ),
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              // 顶部图片和AppBar
              _buildAppBar(context),
              // 内容区域
              _buildContent(context),
            ],
          );
        }),
        bottomNavigationBar: Obx(
          () => controller.isLoading.value ? const SizedBox.shrink() : const MeetupBottomActionBar(),
        ),
      ),
    );
  }

  /// 构建顶部 AppBar
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppColors.surfaceElevated,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: SliverBackButton(
        onPressed: controller.handleBack,
      ),
      actions: [
        // 编辑按钮 - 只有组织者可见
        Obx(() {
          if (controller.isOrganizer) {
            return SliverEditButton(
              onPressed: () async {
                await NavigationUtil.toWithCallback<bool>(
                  page: () => CreateMeetupPage(editingMeetup: controller.meetup.value),
                  onResult: (result) async {
                    if (result.needsRefresh) {
                      await controller.loadEventDetails();
                      controller.hasDataChanged.value = true;
                    }
                  },
                );
              },
              size: 18.r,
            );
          }
          return const SizedBox.shrink();
        }),
        SliverShareButton(onPressed: () => _shareMeetup(context)),
        // 举报按钮 - 非组织者可见
        Obx(() {
          if (!controller.isOrganizer) {
            return SliverReportButton(
              onPressed: () {
                ReportDialog.show(
                  context: context,
                  contentType: ReportContentType.meetup,
                  targetId: controller.meetup.value?.id ?? '',
                  targetName: controller.meetup.value?.title,
                );
              },
              tooltip: AppLocalizations.of(context)!.report,
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            const MeetupImageCarousel(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.14),
                    const Color(0xFF15212B).withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 34.h,
              child: _buildHeroOverlay(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容区域
  SliverToBoxAdapter _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(0, -40.h),
                  child: _buildHeroStatusCard(context),
                ),
                SizedBox(height: 8.h),
                _buildSectionShell(
                  title: l10n.about,
                  child: _buildMeetupSignalBoard(context),
                ),
                SizedBox(height: 16.h),
                _buildSectionShell(
                  title: l10n.meetup,
                  child: const MeetupBasicInfoSection(),
                ),
                SizedBox(height: 16.h),
                _buildSectionShell(
                  title: l10n.dateAndTime,
                  child: const MeetupTimeLocationSection(),
                ),
                SizedBox(height: 16.h),
                _buildSectionShell(
                  title: l10n.about,
                  child: const MeetupDescriptionSection(),
                ),
                SizedBox(height: 16.h),
                _buildSectionShell(
                  title: l10n.organizer,
                  child: const MeetupOrganizerSection(),
                ),
                SizedBox(height: 16.h),
                _buildSectionShell(
                  title: l10n.attendees,
                  child: const MeetupAttendeesSection(),
                ),
              ],
            ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildHeroOverlay(BuildContext context) {
    final meetupData = controller.meetup.value;
    if (meetupData == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final eventTypeLabel = meetupData.eventType?.getDisplayName(
          Localizations.localeOf(context).languageCode,
        ) ??
        meetupData.type.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildHeroPill(FontAwesomeIcons.userGroup, eventTypeLabel),
            _buildHeroPill(
              FontAwesomeIcons.clock,
              controller.isStartingSoon ? l10n.startingSoon : meetupData.status.value,
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          meetupData.title,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.08,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(FontAwesomeIcons.locationDot, size: 12.r, color: Colors.white70),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${meetupData.location.city}, ${meetupData.location.country}',
                style: TextStyle(fontSize: 13.sp, color: Colors.white70),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroStatusCard(BuildContext context) {
    final meetupData = controller.meetup.value;
    if (meetupData == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

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
                      l10n.meetup.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.cityPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      controller.isJoined ? l10n.joined : meetupData.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      controller.formatDateTime(meetupData.schedule.startTime),
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
                      meetupData.capacity.remainingSlots.toString(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.spotsLeft('${meetupData.capacity.remainingSlots}'),
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
                child: _buildSummaryMetric(
                  label: l10n.attendees,
                  value: meetupData.capacity.currentAttendees.toString(),
                  hint: '${meetupData.capacity.maxAttendees}',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildSummaryMetric(
                  label: l10n.venue,
                  value: meetupData.venue.name,
                  hint: meetupData.location.city,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildSummaryMetric(
                  label: l10n.organizer,
                  value: controller.isOrganizer ? 'You' : meetupData.organizer.name,
                  hint: meetupData.status.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupSignalBoard(BuildContext context) {
    final meetupData = controller.meetup.value;
    if (meetupData == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final signals = [
      _buildSignalTile(
        label: 'Status',
        value: meetupData.status.value,
        detail: controller.isStartingSoon ? l10n.startingSoon : controller.formatDateTime(meetupData.schedule.startTime),
        icon: FontAwesomeIcons.signal,
        accent: const Color(0xFF276A88),
      ),
      _buildSignalTile(
        label: l10n.attendees,
        value: '${meetupData.capacity.currentAttendees}/${meetupData.capacity.maxAttendees}',
        detail: meetupData.capacity.isFull ? l10n.meetupIsFull : l10n.spotsLeft('${meetupData.capacity.remainingSlots}'),
        icon: FontAwesomeIcons.users,
        accent: const Color(0xFF855129),
      ),
      _buildSignalTile(
        label: l10n.chat,
        value: controller.isJoined ? l10n.joined : l10n.joinRequired,
        detail: controller.isOrganizer ? l10n.organizer : l10n.joinToAccessChat,
        icon: FontAwesomeIcons.message,
        accent: const Color(0xFF3E7B59),
      ),
      _buildSignalTile(
        label: l10n.venue,
        value: meetupData.location.city,
        detail: meetupData.venue.name,
        icon: FontAwesomeIcons.locationDot,
        accent: const Color(0xFF6F3D78),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12.w) / 2;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: signals.map((tile) => SizedBox(width: width, child: tile)).toList(),
        );
      },
    );
  }

  Widget _buildSectionShell({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildHeroPill(IconData icon, String label) {
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

  Widget _buildSignalTile({
    required String label,
    required String value,
    required String detail,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 16.r, color: accent),
          ),
          SizedBox(height: 14.h),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: accent)),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 6.h),
          Text(detail, style: TextStyle(fontSize: 12.sp, height: 1.45, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({required String label, required String value, required String hint}) {
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
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 4.h),
          Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.sp, height: 1.35, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  /// 分享活动
  void _shareMeetup(BuildContext context) {
    final meetupData = controller.meetup.value;
    if (meetupData == null) return;

    // 格式化时间
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
    final timeStr = dateFormat.format(meetupData.schedule.startTime);

    // 构建分享内容
    final String title = '${meetupData.title} - 数字游民聚会';
    final String description = '📅 时间: $timeStr\n'
        '📍 地点: ${meetupData.venue.name}\n'
        '👥 组织者: ${meetupData.organizer.name}\n\n'
        '${meetupData.description}';

    // 构建分享链接
    final String shareUrl = ShareLinkUtil.meetupDetail(meetupData.id);

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: description,
      shareUrl: shareUrl,
    );
  }
}
