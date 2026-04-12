import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Meetup 卡片组件 - Nomads.com 风格
class HomeMeetupCard extends StatelessWidget {
  final Meetup meetup;
  final bool isMobile;

  const HomeMeetupCard({
    super.key,
    required this.meetup,
    required this.isMobile,
  });

  MeetupStateController get _meetupController => Get.find<MeetupStateController>();

  bool _isJoined(RxList<String> rsvpedIds) {
    return rsvpedIds.contains(meetup.id) || meetup.isJoined;
  }

  @override
  Widget build(BuildContext context) {
    final date = meetup.schedule.startTime;

    return Obx(() {
      final isJoined = _isJoined(_meetupController.rsvpedMeetupIds);
      final currentAttendees = meetup.capacity.currentAttendees;
      final maxAttendees = meetup.capacity.maxAttendees;
      final isFull = currentAttendees >= maxAttendees;
      final authController = Get.find<AuthStateController>();
      final isOrganizer =
          authController.isAuthenticated.value && meetup.organizer.id == authController.currentUser.value?.id;

      return Container(
        width: isMobile ? 280 : 320,
        margin: EdgeInsets.only(right: 16.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context),
                _buildContentSection(context, date),
                _buildActionButtons(context, isJoined, isFull, isOrganizer),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildImageSection(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.meetupDetail, arguments: meetup),
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Image.network(
              meetup.images.isNotEmpty
                  ? meetup.images.first
                  : 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
              width: double.infinity,
              height: 140.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // 图片加载失败时显示占位符
                return Container(
                  width: double.infinity,
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.image,
                        size: 40.r,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context)!.imageLoadFailed,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFFFF4458),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                meetup.eventType?.name ?? meetup.type.value,
                style: TextStyle(
                  color: _getTypeColor(meetup.eventType?.enName ?? meetup.type.value),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, DateTime date) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.meetupDetail, arguments: meetup),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meetup.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            _buildDateLocation(date),
            SizedBox(height: 10.h),
            _buildAttendeeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLocation(DateTime date) {
    final localDate = date.toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.calendar, size: 13.r, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                '${_formatDate(localDate)} ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(FontAwesomeIcons.locationDot, size: 13.r, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                [
                  if (meetup.venue.name.isNotEmpty) meetup.venue.name,
                  meetup.location.fullDescription,
                ].where((s) => s.isNotEmpty).join(', '),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendeeInfo() {
    final l10n = AppLocalizations.of(Get.context!)!;
    final currentAttendees = meetup.capacity.currentAttendees;
    final maxAttendees = meetup.capacity.maxAttendees;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.users, size: 11.r, color: AppColors.textSecondary),
              SizedBox(width: 5.w),
              Text(
                '$currentAttendees',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        if ((maxAttendees - currentAttendees) > 0)
          Text(
            l10n.spotsLeftCount(maxAttendees - currentAttendees),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.cityPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const Spacer(),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.user, size: 13.r, color: AppColors.textSecondary),
              SizedBox(width: 3.w),
              Flexible(
                child: Text(
                  meetup.organizer.name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isJoined, bool isFull, bool isOrganizer) {
    final l10n = AppLocalizations.of(context)!;
    final status = meetup.status;

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
      child: _buildButtonContent(context, l10n, status, isJoined, isFull, isOrganizer),
    );
  }

  Widget _buildButtonContent(
    BuildContext context,
    AppLocalizations l10n,
    MeetupStatus status,
    bool isJoined,
    bool isFull,
    bool isOrganizer,
  ) {
    // 已取消
    if (status == MeetupStatus.cancelled) {
      return _buildDisabledButton(
          FontAwesomeIcons.ban, isOrganizer ? l10n.meetupStatusCancelled : l10n.meetupEventCancelled);
    }

    // 已结束
    if (status == MeetupStatus.completed || meetup.isEnded) {
      return _buildDisabledButton(
          FontAwesomeIcons.circleCheck, isOrganizer ? l10n.meetupStatusEnded : l10n.meetupEventEnded);
    }

    // 组织者按钮
    if (isOrganizer) {
      return _buildOrganizerButtons(context);
    }

    // 普通用户按钮
    return _buildUserButtons(context, l10n, isJoined, isFull);
  }

  Widget _buildDisabledButton(IconData icon, String text) {
    return SizedBox(
      width: double.infinity,
      height: 38.h,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.borderLight,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textSecondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.r),
            SizedBox(width: 4.w),
            Text(text, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildChatButton(context, true)),
        SizedBox(width: 6.w),
        Expanded(child: _buildCancelButton(context)),
      ],
    );
  }

  Widget _buildUserButtons(BuildContext context, AppLocalizations l10n, bool isJoined, bool isFull) {
    return Row(
      children: [
        Expanded(child: _buildChatButton(context, isJoined)),
        SizedBox(width: 6.w),
        Expanded(child: _buildJoinButton(context, l10n, isJoined, isFull)),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, bool enabled) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 38.h,
      child: OutlinedButton(
        onPressed: enabled
            ? () {
                final authController = Get.find<AuthStateController>();
                if (!authController.isAuthenticated.value) {
                  AppToast.warning(l10n.pleaseLoginToCreateMeetup, title: l10n.loginRequired);
                  Get.toNamed(AppRoutes.login);
                  return;
                }
                Get.toNamed(AppRoutes.cityChat, arguments: {
                  'city': meetup.title,
                  'country': '${meetup.type} Meetup',
                  'meetupId': meetup.id,
                  'isMeetupChat': true,
                });
              }
            : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: enabled ? AppColors.accent : AppColors.textTertiary,
          side: BorderSide(
            color: enabled ? AppColors.accent.withValues(alpha: 0.28) : Colors.grey.shade300,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          backgroundColor: enabled ? AppColors.accent.withValues(alpha: 0.05) : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.message, size: 14.r),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(l10n.homeMeetupChatButton, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ElevatedButton(
        onPressed: () => _handleCancelMeetup(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.ban, size: 14.r),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, AppLocalizations l10n, bool isJoined, bool isFull) {
    return SizedBox(
      height: 38.h,
      child: ElevatedButton(
        onPressed: (isFull && !isJoined) ? null : () => _handleToggleJoin(context, isJoined),
        style: ElevatedButton.styleFrom(
          backgroundColor: isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
          foregroundColor: isJoined ? AppColors.textSecondary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textSecondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isJoined ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circlePlus, size: 14.r),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                isFull && !isJoined ? l10n.full : (isJoined ? l10n.leave : l10n.join),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleJoin(BuildContext context, bool isCurrentlyJoined) async {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthStateController>();

    if (!authController.isAuthenticated.value) {
      AppToast.warning(l10n.pleaseLoginToCreateMeetup, title: l10n.loginRequired);
      Get.toNamed(AppRoutes.login);
      return;
    }

    final isJoining = !isCurrentlyJoined;

    try {
      // 使用 MeetupStateController 的方法，已实现单点更新
      if (isJoining) {
        final success = await _meetupController.rsvpToMeetup(meetup.id);
        if (success) {
          log('✅ 加入活动成功: ${meetup.id}');
        }
      } else {
        final success = await _meetupController.cancelRsvp(meetup.id);
        if (success) {
          log('✅ 退出活动成功: ${meetup.id}');
        }
      }
      // 无需调用 refreshMeetups()，rsvpToMeetup/cancelRsvp 已经单点更新了列表
    } catch (e) {
      log('❌ 操作失败: $e');
      _handleJoinError(e.toString(), isCurrentlyJoined);
    }
  }

  void _handleJoinError(String errorMessage, bool isCurrentlyJoined) {
    if (errorMessage.contains('已经参加') || errorMessage.contains('already joined')) {
      if (!_meetupController.rsvpedMeetupIds.contains(meetup.id)) {
        _meetupController.rsvpedMeetupIds.add(meetup.id);
      }
      AppToast.info(AppLocalizations.of(Get.context!)!.dataServiceAlreadyJoinedMeetup);
      return;
    }

    if (errorMessage.contains('未参加') || errorMessage.contains('not joined')) {
      _meetupController.rsvpedMeetupIds.remove(meetup.id);
      AppToast.info(AppLocalizations.of(Get.context!)!.dataServiceNotJoinedMeetup);
      return;
    }

    AppToast.error(
      isCurrentlyJoined
          ? AppLocalizations.of(Get.context!)!.dataServiceLeaveMeetupFailed
          : AppLocalizations.of(Get.context!)!.dataServiceJoinMeetupFailed,
      title: AppLocalizations.of(Get.context!)!.dataServiceOperationFailed,
    );
  }

  Future<void> _handleCancelMeetup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.confirmCancelMeetupTitle),
        content: Text(l10n.confirmCancelMeetupMessage),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 使用 MeetupStateController 的方法，已实现单点更新
      final success = await _meetupController.cancelMeetup(meetup.id);
      if (success) {
        log('✅ 取消活动成功: ${meetup.id}');
      }
      // 无需调用 refreshMeetups()，cancelMeetup 已经单点更新了列表
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error(l10n.cancelMeetupFailed);
    }
  }

  Color _getTypeColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) return Colors.brown;
    if (typeLower.contains('coworking') || typeLower.contains('business')) return Colors.blue;
    if (typeLower.contains('activity') || typeLower.contains('outdoor')) return Colors.green;
    if (typeLower.contains('language')) return Colors.purple;
    if (typeLower.contains('social') || typeLower.contains('networking')) return Colors.orange;
    if (typeLower.contains('tech') || typeLower.contains('workshop')) return Colors.indigo;
    if (typeLower.contains('food') || typeLower.contains('dinner')) return Colors.red;
    if (typeLower.contains('sports') || typeLower.contains('fitness')) return Colors.teal;
    if (typeLower.contains('culture') || typeLower.contains('art')) return Colors.pink;
    if (typeLower.contains('yoga') || typeLower.contains('meditation')) return const Color(0xFF4CAF50);
    return const Color(0xFF9C27B0);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
