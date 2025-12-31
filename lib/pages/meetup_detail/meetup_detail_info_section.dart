import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MeetupDetailBasicInfoSection extends StatelessWidget {
  final String controllerTag;

  const MeetupDetailBasicInfoSection({super.key, required this.controllerTag});

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeChip(
                _c.meetup.value.eventType?.getDisplayName(Localizations.localeOf(context).languageCode) ??
                    _c.meetup.value.type.value,
              ),
              SizedBox(width: 12.w),
              if (_c.meetup.value.isStartingSoon)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.clock, size: 12.sp, color: const Color(0xFFFF4458)),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.startingSoon,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFFFF4458)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _c.meetup.value.title,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.city, size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Text(
                '${_c.meetup.value.location.city}, ${_c.meetup.value.location.country}',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    IconData icon;
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) {
      color = Colors.brown;
      icon = FontAwesomeIcons.mugSaucer;
    } else if (typeLower.contains('coworking') || typeLower.contains('共享办公')) {
      color = Colors.blue;
      icon = FontAwesomeIcons.laptop;
    } else if (typeLower.contains('activity') || typeLower.contains('运动') || typeLower.contains('sports') || typeLower.contains('健身')) {
      color = Colors.green;
      icon = FontAwesomeIcons.football;
    } else if (typeLower.contains('language') || typeLower.contains('语言')) {
      color = Colors.purple;
      icon = FontAwesomeIcons.globe;
    } else if (typeLower.contains('social') || typeLower.contains('社交') || typeLower.contains('networking') || typeLower.contains('网络')) {
      color = Colors.orange;
      icon = FontAwesomeIcons.userGroup;
    } else if (typeLower.contains('tech') || typeLower.contains('workshop') || typeLower.contains('技术') || typeLower.contains('工作坊')) {
      color = Colors.indigo;
      icon = FontAwesomeIcons.code;
    } else if (typeLower.contains('food') || typeLower.contains('美食')) {
      color = Colors.red;
      icon = FontAwesomeIcons.utensils;
    } else {
      color = AppColors.textSecondary;
      icon = FontAwesomeIcons.calendarDays;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(type, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class MeetupDetailTimeLocationSection extends StatelessWidget {
  final String controllerTag;

  const MeetupDetailTimeLocationSection({super.key, required this.controllerTag});

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Obx(() => Column(
        children: [
          _buildInfoRow(
            FontAwesomeIcons.calendar,
            l10n.dateAndTime,
            _c.formatDateTime(_c.meetup.value.schedule.startTime),
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            FontAwesomeIcons.locationDot,
            l10n.venue,
            _c.meetup.value.venue.name,
            subtitle: _c.meetup.value.venue.address,
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            FontAwesomeIcons.users,
            l10n.attendees,
            '${_c.meetup.value.capacity.currentAttendees} / ${_c.meetup.value.capacity.maxAttendees}',
            subtitle: _c.meetup.value.capacity.isFull
                ? l10n.meetupIsFull
                : l10n.spotsLeft('${_c.meetup.value.capacity.remainingSlots}'),
          ),
        ],
      )),
    );
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
              Text(title, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
              SizedBox(height: 4.h),
              Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MeetupDetailDescriptionSection extends StatelessWidget {
  final String controllerTag;

  const MeetupDetailDescriptionSection({super.key, required this.controllerTag});

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.about, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Obx(() => Text(
            _c.meetup.value.description,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.6),
          )),
        ],
      ),
    );
  }
}
