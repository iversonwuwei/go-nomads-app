import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:df_admin_mobile/pages/create_meetup/create_meetup_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/edit_button.dart';
import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';
import 'package:df_admin_mobile/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'meetup_detail_attendees_section.dart';
import 'meetup_detail_bottom_bar.dart';
import 'meetup_detail_image_section.dart';
import 'meetup_detail_info_section.dart';
import 'meetup_detail_organizer_section.dart';

/// Meetup 详情页面 - 使用 GetX + 组件化架构重构
class MeetupDetailPage extends StatelessWidget {
  final Meetup meetup;

  const MeetupDetailPage({super.key, required this.meetup});

  @override
  Widget build(BuildContext context) {
    // 生成唯一 tag 避免多页面冲突
    final uniqueTag = 'meetup_detail_${meetup.id}_${DateTime.now().millisecondsSinceEpoch}';

    // 注册 controller
    final controller = Get.put(
      MeetupDetailPageController(initialMeetup: meetup),
      tag: uniqueTag,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(controller, uniqueTag);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // 顶部 AppBar 与图片
            _buildSliverAppBar(context, controller, uniqueTag),

            // 内容区域
            SliverToBoxAdapter(
              child: Obx(() {
                // 显示加载指示器
                if (controller.isLoading.value) {
                  return Container(
                    padding: EdgeInsets.all(40.w),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF4458)),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息
                    MeetupDetailBasicInfoSection(controllerTag: uniqueTag),

                    SizedBox(height: 16.h),

                    // 时间地点
                    MeetupDetailTimeLocationSection(controllerTag: uniqueTag),

                    SizedBox(height: 16.h),

                    // 描述
                    MeetupDetailDescriptionSection(controllerTag: uniqueTag),

                    SizedBox(height: 16.h),

                    // 组织者信息
                    MeetupDetailOrganizerSection(controllerTag: uniqueTag),

                    SizedBox(height: 16.h),

                    // 参与者列表
                    MeetupDetailAttendeesSection(controllerTag: uniqueTag),

                    SizedBox(height: 100.h),
                  ],
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: MeetupDetailBottomBar(controllerTag: uniqueTag),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MeetupDetailPageController controller, String uniqueTag) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: Colors.white,
      leading: SliverBackButton(
        onPressed: () => _handleBack(controller, uniqueTag),
      ),
      actions: [
        // 编辑按钮 - 只有组织者可见
        Obx(() {
          if (controller.isOrganizer) {
            return SliverEditButton(
              onPressed: () async {
                final result = await Get.to(() => CreateMeetupPage(editingMeetup: controller.meetup.value));
                if (result == true) {
                  // 编辑成功，刷新数据并标记变更
                  await controller.loadEventDetails();
                  controller.hasDataChanged.value = true;
                }
              },
              size: 18,
            );
          }
          return const SizedBox.shrink();
        }),
        SliverShareButton(onPressed: () => _shareMeetup(context, controller)),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: MeetupDetailImageSection(controllerTag: uniqueTag),
      ),
    );
  }

  void _handleBack(MeetupDetailPageController controller, String uniqueTag) {
    final result = controller.hasDataChanged.value ? controller.meetup.value : null;
    Get.delete<MeetupDetailPageController>(tag: uniqueTag);
    Get.back(result: result);
  }

  void _shareMeetup(BuildContext context, MeetupDetailPageController controller) {
    final meetupData = controller.meetup.value;
    final l10n = AppLocalizations.of(context)!;

    // 格式化时间
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
    final timeStr = dateFormat.format(meetupData.schedule.startTime);

    // 构建分享内容
    final String title = '${meetupData.title} - ${l10n.meetup}';
    final String description = '📅 ${l10n.dateAndTime}: $timeStr\n'
        '📍 ${l10n.venue}: ${meetupData.venue.name}\n'
        '👥 ${l10n.organizer}: ${meetupData.organizer.name}\n\n'
        '${meetupData.description}';

    // 构建分享链接
    final String shareUrl = 'https://nomadcities.app/meetups/${meetupData.id}';

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: description,
      shareUrl: shareUrl,
    );
  }
}
