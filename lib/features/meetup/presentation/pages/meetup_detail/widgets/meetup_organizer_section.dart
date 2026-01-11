import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/direct_chat_page.dart';
import 'package:df_admin_mobile/pages/member_detail_page.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 组织者信息区域组件
///
/// 显示活动组织者头像、名称，并提供联系功能
class MeetupOrganizerSection extends GetView<MeetupDetailController> {
  const MeetupOrganizerSection({super.key});

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
            Text(
              l10n.organizer,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToOrganizerProfile(meetup.organizer),
                  child: SafeCircleAvatar(
                    imageUrl: meetup.organizer.avatarUrl,
                    radius: 30.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meetup.organizer.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.eventOrganizer,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 如果当前用户是组织者，不显示消息按钮
                if (!controller.isOrganizer)
                  OutlinedButton(
                    onPressed: () => _contactOrganizer(meetup.organizer, l10n),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      side: BorderSide(color: const Color(0xFFFF4458), width: 1.5.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text(
                      l10n.message,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _navigateToOrganizerProfile(dynamic organizer) {
    final organizerUser = controller.createBasicUserModel(
      organizer.id,
      organizer.name,
      organizer.avatarUrl,
    );
    Get.to(() => MemberDetailPage(user: organizerUser));
  }

  void _contactOrganizer(dynamic organizer, AppLocalizations l10n) {
    final organizerUser = User(
      id: organizer.id,
      name: organizer.name,
      username: organizer.name.toLowerCase().replaceAll(' ', '_'),
      avatarUrl: organizer.avatarUrl,
      stats: TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0.0,
      ),
      joinedDate: DateTime.now(),
    );

    Get.to(() => DirectChatPage(user: organizerUser));
  }
}
