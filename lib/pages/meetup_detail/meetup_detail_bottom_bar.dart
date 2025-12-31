import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MeetupDetailBottomBar extends StatelessWidget {
  final String controllerTag;

  const MeetupDetailBottomBar({super.key, required this.controllerTag});

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, -2.h)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_c.isOrganizer) ...[
              // Organizer view: Chat + Cancel buttons
              OutlinedButton.icon(
                onPressed: () => _openChat(context, l10n),
                icon: Icon(FontAwesomeIcons.message, size: 20.sp),
                label: Text(l10n.chat, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue, width: 1.5.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _c.meetup.value.status == MeetupStatus.cancelled || _c.meetup.value.isEnded
                      ? null
                      : () => _c.cancelMeetup(context),
                  icon: Icon(FontAwesomeIcons.ban, size: 20.sp),
                  label: Text(
                    _c.meetup.value.status == MeetupStatus.cancelled ? '已取消' : '取消活动',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.meetup.value.status == MeetupStatus.cancelled ? AppColors.borderLight : Colors.red,
                    foregroundColor: _c.meetup.value.status == MeetupStatus.cancelled ? AppColors.textSecondary : Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.borderLight,
                  ),
                ),
              ),
            ] else ...[
              // Participant view: Chat + Join/Leave buttons
              OutlinedButton.icon(
                onPressed: _c.isJoined ? () => _openChat(context, l10n) : null,
                icon: Icon(FontAwesomeIcons.message, size: 20.sp),
                label: Text(l10n.chat, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _c.isJoined ? Colors.blue : Colors.grey,
                  side: BorderSide(color: _c.isJoined ? Colors.blue : Colors.grey.shade300, width: 1.5.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                  backgroundColor: _c.isJoined ? null : Colors.grey.shade50,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _c.meetup.value.isEnded ||
                          (_c.meetup.value.capacity.isFull && !_c.isJoined) ||
                          _c.meetup.value.status == MeetupStatus.cancelled
                      ? null
                      : () => _c.toggleJoin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
                    foregroundColor: _c.isJoined ? AppColors.textSecondary : Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.borderLight,
                  ),
                  child: Text(
                    _getJoinButtonText(l10n),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }

  String _getJoinButtonText(AppLocalizations l10n) {
    if (_c.meetup.value.status == MeetupStatus.cancelled) return '已取消';
    if (_c.meetup.value.isEnded) return l10n.ended;
    if (_c.meetup.value.capacity.isFull && !_c.isJoined) return l10n.full;
    return _c.isJoined ? l10n.leaveMeetup : l10n.joinMeetup;
  }

  void _openChat(BuildContext context, AppLocalizations l10n) {
    if (!_c.isJoined && !_c.isOrganizer) {
      AppToast.warning(l10n.joinToAccessChat, title: l10n.joinRequired);
      return;
    }

    Get.toNamed(
      AppRoutes.cityChat,
      arguments: {
        'city': _c.meetup.value.title,
        'country': '${_c.meetup.value.type} ${l10n.meetup}',
        'meetupId': _c.meetup.value.id,
        'isMeetupChat': true,
      },
    );
  }
}
