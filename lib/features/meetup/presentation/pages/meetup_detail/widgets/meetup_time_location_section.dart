import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 时间地点信息区域组件
///
/// 显示活动的日期时间、地点和参与人数
class MeetupTimeLocationSection extends GetView<MeetupDetailController> {
  const MeetupTimeLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final meetup = controller.meetup.value;
      if (meetup == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(20.w),
        color: Colors.white,
        child: Column(
          children: [
            _buildInfoRow(
              FontAwesomeIcons.calendar,
              l10n.dateAndTime,
              controller.formatDateTime(meetup.schedule.startTime),
            ),
            SizedBox(height: 20.h),
            _buildInfoRow(
              FontAwesomeIcons.locationDot,
              l10n.venue,
              meetup.venue.name,
              subtitle: meetup.venue.address,
            ),
            SizedBox(height: 20.h),
            _buildInfoRow(
              FontAwesomeIcons.users,
              l10n.attendees,
              '${meetup.capacity.currentAttendees} / ${meetup.capacity.maxAttendees}',
              subtitle: meetup.capacity.isFull
                  ? l10n.meetupIsFull
                  : l10n.spotsLeft('${meetup.capacity.remainingSlots}'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4458).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: const Color(0xFFFF4458)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
