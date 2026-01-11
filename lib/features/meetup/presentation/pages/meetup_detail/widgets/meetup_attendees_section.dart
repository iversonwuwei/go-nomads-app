import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/member_detail_page.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
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

    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
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
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFFFF4458),
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
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
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

            return SizedBox(
              height: 40.h,
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
                        child: SafeCircleAvatar(
                          imageUrl: userAvatar,
                          radius: 20.r,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAllAttendees(BuildContext context, AppLocalizations l10n) {
    Get.dialog(
      AlertDialog(
        title: Text(l10n.allAttendees, style: TextStyle(fontSize: 18.sp)),
        content: SizedBox(
          width: double.maxFinite,
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
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.close, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
