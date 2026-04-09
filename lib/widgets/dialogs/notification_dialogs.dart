import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';
import 'package:go_nomads_app/widgets/dialogs/app_loading_dialog.dart';

/// 活动邀请响应对话框
class EventInvitationDialog extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onResponse;

  const EventInvitationDialog({
    super.key,
    required this.notification,
    this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventTitle = notification.metadata?['eventTitle'] ?? notification.title;
    final inviterName = notification.metadata?['inviterName'] ?? '某用户';
    final eventTime = notification.metadata?['eventTime'] ?? '';
    final invitationId = notification.metadata?['invitationId'] ?? notification.relatedId;

    return AppBottomDrawer(
      title: l10n.eventInvitation,
      maxHeightFactor: 0.72,
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleResponse(invitationId, false),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                l10n.decline,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleResponse(invitationId, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                l10n.accept,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.calendarDays,
              color: const Color(0xFF10B981),
              size: 32.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '$inviterName ${l10n.inviteYouToJoin}',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                if (eventTime.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 14.r,
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          eventTime,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResponse(String? invitationId, bool accepted) async {
    if (invitationId == null || invitationId.isEmpty) {
      AppToast.error('无法获取邀请ID');
      return;
    }

    final notificationController = Get.find<NotificationStateController>();

    AppLoadingDialog.showSimple();

    final success = await notificationController.respondToEventInvitation(
      notificationId: notification.id,
      invitationId: invitationId,
      accepted: accepted,
    );

    AppLoadingDialog.hide();

    if (success) {
      AppToast.success(accepted ? '已接受邀请' : '已拒绝邀请');
      Get.back<void>();
      onResponse?.call();
    } else {
      AppToast.error('操作失败，请重试');
    }
  }
}
