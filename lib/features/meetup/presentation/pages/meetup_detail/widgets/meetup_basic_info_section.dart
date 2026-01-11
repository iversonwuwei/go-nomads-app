import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 基本信息区域组件
///
/// 显示活动类型标签、标题、城市等基本信息
class MeetupBasicInfoSection extends GetView<MeetupDetailController> {
  const MeetupBasicInfoSection({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeChip(
                  meetup.eventType?.getDisplayName(
                        Localizations.localeOf(context).languageCode,
                      ) ??
                      meetup.type.value,
                ),
                SizedBox(width: 12.w),
                if (controller.isStartingSoon)
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
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF4458),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              meetup.title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(FontAwesomeIcons.city, size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  '${meetup.location.city}, ${meetup.location.country}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
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
    } else if (typeLower.contains('activity') ||
        typeLower.contains('运动') ||
        typeLower.contains('sports') ||
        typeLower.contains('健身')) {
      color = Colors.green;
      icon = FontAwesomeIcons.football;
    } else if (typeLower.contains('language') || typeLower.contains('语言')) {
      color = Colors.purple;
      icon = FontAwesomeIcons.globe;
    } else if (typeLower.contains('social') ||
        typeLower.contains('社交') ||
        typeLower.contains('networking') ||
        typeLower.contains('网络')) {
      color = Colors.orange;
      icon = FontAwesomeIcons.userGroup;
    } else if (typeLower.contains('tech') ||
        typeLower.contains('workshop') ||
        typeLower.contains('技术') ||
        typeLower.contains('工作坊')) {
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            type,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
