import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
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
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片区域
              _buildImageSection(context),
              // 内容区域
              _buildContentSection(context, date),
              // 操作按钮
              _buildActionButtons(context, isJoined, isFull, isOrganizer),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImageSection(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.meetupDetail, arguments: meetup),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
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
                color: _getTypeColor(meetup.eventType?.enName ?? meetup.type.value),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                meetup.eventType?.name ?? meetup.type.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
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
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              meetup.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            // 日期和地点
            _buildDateLocation(date),
            SizedBox(height: 8.h),
            // 参与者信息
            _buildAttendeeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLocation(DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.calendar, size: 13.r, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
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
                  fontSize: 11.sp,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.users, size: 13.r, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Text(
              '$currentAttendees',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        if ((maxAttendees - currentAttendees) > 0)
          Text(
            l10n.spotsLeftCount(maxAttendees - currentAttendees),
            style: TextStyle(
              fontSize: 11.sp,
              color: Color(0xFFFF4458),
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
      height: 32.h,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.borderLight,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
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
      height: 32.h,
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
          foregroundColor: enabled ? Colors.blue : Colors.grey,
          side: BorderSide(
            color: enabled ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          backgroundColor: enabled ? null : Colors.grey.shade50,
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
      height: 32.h,
      child: ElevatedButton(
        onPressed: () => _handleCancelMeetup(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.ban, size: 14.r),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(AppLocalizations.of(context)!.confirmCancelMeetupTitle,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, AppLocalizations l10n, bool isJoined, bool isFull) {
    return SizedBox(
      height: 32.h,
      child: ElevatedButton(
        onPressed: (isFull && !isJoined) ? null : () => _handleToggleJoin(context, isJoined),
        style: ElevatedButton.styleFrom(
          backgroundColor: isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
          foregroundColor: isJoined ? AppColors.textSecondary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
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
