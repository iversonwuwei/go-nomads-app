import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/member_detail_page.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 参与者列表区域组件
///
/// 显示参与者头像列表，并提供查看全部功能
class MeetupAttendeesSection extends GetView<MeetupDetailController> {
  const MeetupAttendeesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // 标题行
          Obx(() {
            final attendeesCount = controller.meetup.value?.capacity.currentAttendees ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.attendeesCount('$attendeesCount'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (attendeesCount > 0)
                  TextButton(
                    onPressed: () => _showAllAttendees(context, l10n),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cityPrimary,
                      backgroundColor: AppColors.cityPrimaryLight,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            );
          }),
          SizedBox(height: 16.h),
          // 参与者头像列表
          Obx(() {
            if (controller.participants.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Text(
                    l10n.noAttendeesYet,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: SizedBox(
                height: 44.h,
                child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.participants.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final participant = controller.participants[index];
                  final userId = participant['userId']?.toString() ?? '';
                  final userInfo = participant['user'] as Map<String, dynamic>?;
                  final userAvatar = userInfo?['avatar'] as String?;
                  final userName = userInfo?['name'] as String? ?? 'User';

                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () {
                        final participantUser = controller.createBasicUserModel(
                          userId,
                          userName,
                          userAvatar ?? '',
                        );
                        Get.to(() => MemberDetailPage(user: participantUser));
                      },
                      child: Tooltip(
                        message: userName,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderLight),
                            color: AppColors.surfaceElevated,
                          ),
                          child: SafeCircleAvatar(
                            imageUrl: userAvatar,
                            radius: 20.r,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              ),
            );
          }),
      ],
    );
  }

  void _showAllAttendees(BuildContext context, AppLocalizations l10n) {
    Get.bottomSheet(
      AppBottomDrawer(
        title: l10n.allAttendees,
        maxHeightFactor: 0.72,
        footer: AppBottomDrawerActionRow(
          secondaryLabel: l10n.close,
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: l10n.close,
          onPrimaryPressed: () => Get.back<void>(),
        ),
        child: Obx(() {
          if (controller.participants.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  l10n.noAttendeesYet,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.participants.length,
            itemBuilder: (context, index) {
              final participant = controller.participants[index];
              final userId = participant['userId']?.toString() ?? '';
              final userInfo = participant['user'] as Map<String, dynamic>?;
              final userName = userInfo?['name'] as String? ?? '${l10n.user} ${index + 1}';
              final userEmail = userInfo?['email'] as String?;
              final userAvatar = userInfo?['avatar'] as String?;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  final participantUser = controller.createBasicUserModel(
                    userId,
                    userName,
                    userAvatar ?? '',
                  );
                  Get.back();
                  Get.to(() => MemberDetailPage(user: participantUser));
                },
                leading: SafeCircleAvatar(
                  imageUrl: userAvatar,
                  radius: 20,
                ),
                title: Text(userName, style: TextStyle(fontSize: 14.sp)),
                subtitle: Text(
                  userEmail ?? l10n.digitalNomad,
                  style: TextStyle(fontSize: 12.sp),
                ),
              );
            },
          );
        }),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
