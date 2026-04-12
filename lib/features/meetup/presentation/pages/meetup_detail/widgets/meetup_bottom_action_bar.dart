import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 底部操作栏组件
///
/// 根据用户角色（组织者/参与者）显示不同的操作按钮
class MeetupBottomActionBar extends GetView<MeetupDetailController> {
  const MeetupBottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final meetup = controller.meetup.value;
      if (meetup == null) return const SizedBox.shrink();

      log('🎨 构建底部按钮栏 - isOrganizer: ${controller.isOrganizer}');
      log('🎨 构建底部按钮栏 - isJoined: ${controller.isJoined}');
      log('🎨 构建底部按钮栏 - meetup status: ${meetup.status}');

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: AppUiTokens.softTopSheetShadow,
        ),
        child: SafeArea(
          child: Row(
            children: controller.isOrganizer
                ? _buildOrganizerButtons(context, l10n, meetup)
                : _buildAttendeeButtons(context, l10n, meetup),
          ),
        ),
      );
    });
  }

  /// 组织者按钮组：聊天 + 取消活动
  List<Widget> _buildOrganizerButtons(BuildContext context, AppLocalizations l10n, Meetup meetup) {
    return [
      // Chat Button - 组织者始终可用
      OutlinedButton.icon(
        onPressed: () => _openChat(l10n),
        icon: Icon(FontAwesomeIcons.message, size: 20.sp),
        label: Text(
          l10n.chat,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          backgroundColor: AppColors.surfaceElevated,
        ),
      ),
      SizedBox(width: 12.w),
      // 取消活动按钮
      Expanded(
        child: ElevatedButton.icon(
          onPressed: meetup.status == MeetupStatus.cancelled || controller.isEnded
              ? null
              : () => controller.cancelMeetup(context),
          icon: Icon(FontAwesomeIcons.ban, size: 20.sp),
          label: Text(
            meetup.status == MeetupStatus.cancelled ? l10n.cancelled : l10n.cancelMeetup,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: meetup.status == MeetupStatus.cancelled ? AppColors.borderLight : AppColors.feedbackError,
            foregroundColor: meetup.status == MeetupStatus.cancelled ? AppColors.textSecondary : Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
            disabledBackgroundColor: AppColors.borderLight,
          ),
        ),
      ),
    ];
  }

  /// 参与者按钮组：聊天 + 加入/退出
  List<Widget> _buildAttendeeButtons(BuildContext context, AppLocalizations l10n, Meetup meetup) {
    return [
      // Chat Button - 只有参与了才能点击
      OutlinedButton.icon(
        onPressed: controller.isJoined ? () => _openChat(l10n) : null,
        icon: Icon(FontAwesomeIcons.message, size: 20.sp),
        label: Text(
          l10n.chat,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: controller.isJoined ? AppColors.textPrimary : AppColors.textTertiary,
          side: BorderSide(
            color: controller.isJoined ? AppColors.border : AppColors.borderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          backgroundColor: controller.isJoined ? AppColors.surfaceElevated : AppColors.surfaceDisabled,
        ),
      ),
      SizedBox(width: 12.w),
      // Join Button
      Expanded(
        child: ElevatedButton(
          onPressed: controller.isEnded ||
                  (controller.isFull && !controller.isJoined) ||
                  controller.isCancelled
              ? null
              : () => controller.toggleJoin(),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
            foregroundColor: controller.isJoined ? AppColors.textSecondary : Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
            disabledBackgroundColor: AppColors.borderLight,
          ),
          child: Text(
            _getJoinButtonText(l10n, meetup),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }

  String _getJoinButtonText(AppLocalizations l10n, Meetup meetup) {
    if (controller.isCancelled) return l10n.cancelled;
    if (controller.isEnded) return l10n.ended;
    if (controller.isFull && !controller.isJoined) return l10n.full;
    if (controller.isJoined) return l10n.leaveMeetup;
    return l10n.joinMeetup;
  }

  void _openChat(AppLocalizations l10n) {
    final meetup = controller.meetup.value;
    if (meetup == null) return;

    // 组织者或已加入的成员都可以访问聊天室
    if (!controller.isJoined && !controller.isOrganizer) {
      AppToast.warning(
        l10n.joinToAccessChat,
        title: l10n.joinRequired,
      );
      return;
    }

    Get.toNamed(
      AppRoutes.cityChat,
      arguments: {
        'city': meetup.title,
        'country': '${meetup.type} ${l10n.meetup}',
        'meetupId': meetup.id,
        'isMeetupChat': true,
      },
    );
  }
}
