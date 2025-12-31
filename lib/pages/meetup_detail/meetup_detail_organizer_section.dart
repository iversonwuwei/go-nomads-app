import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:df_admin_mobile/pages/direct_chat_page.dart';
import 'package:df_admin_mobile/pages/member_detail_page.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MeetupDetailOrganizerSection extends StatelessWidget {
  final String controllerTag;

  const MeetupDetailOrganizerSection({super.key, required this.controllerTag});

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
          Text(l10n.organizer, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 16.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final organizerUser = _c.createBasicUserModel(
                    _c.meetup.value.organizer.id,
                    _c.meetup.value.organizer.name,
                    _c.meetup.value.organizer.avatarUrl,
                  );
                  Get.to(() => MemberDetailPage(user: organizerUser));
                },
                child: SafeCircleAvatar(imageUrl: _c.meetup.value.organizer.avatarUrl, radius: 30.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_c.meetup.value.organizer.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    SizedBox(height: 4.h),
                    Text(l10n.eventOrganizer, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!_c.isOrganizer)
                OutlinedButton(
                  onPressed: () => _contactOrganizer(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4458),
                    side: BorderSide(color: const Color(0xFFFF4458), width: 1.5.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  child: Text(l10n.message, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      )),
    );
  }

  void _contactOrganizer(BuildContext context) {
    final organizerUser = User(
      id: _c.meetup.value.organizer.id,
      name: _c.meetup.value.organizer.name,
      username: _c.meetup.value.organizer.name.toLowerCase().replaceAll(' ', '_'),
      avatarUrl: _c.meetup.value.organizer.avatarUrl,
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
