import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_attendees_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_basic_info_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_bottom_action_bar.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_description_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_image_carousel.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_organizer_section.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/widgets/meetup_time_location_section.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:go_nomads_app/widgets/report_dialog.dart';
import 'package:go_nomads_app/widgets/share_bottom_sheet.dart';
import 'package:go_nomads_app/widgets/share_button.dart';
import 'package:intl/intl.dart';

/// Meetup 详情页面
///
/// 使用 GetView 模式，遵循 GetX 标准实践:
/// - 继承 GetView[MeetupDetailController]
/// - 通过 Binding 注入依赖
/// - 页面由多个小组件组成
class MeetupDetailPage extends GetView<MeetupDetailController> {
  final Meetup meetup;

  const MeetupDetailPage({
    super.key,
    required this.meetup,
  });

  @override
  Widget build(BuildContext context) {
    // 初始化 Controller 的数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setInitialMeetup(meetup);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // 顶部图片和AppBar
            _buildAppBar(context),
            // 内容区域
            _buildContent(),
          ],
        ),
        bottomNavigationBar: const MeetupBottomActionBar(),
      ),
    );
  }

  /// 构建顶部 AppBar
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: Colors.white,
      leading: SliverBackButton(
        onPressed: controller.handleBack,
      ),
      actions: [
        // 编辑按钮 - 只有组织者可见
        Obx(() {
          if (controller.isOrganizer) {
            return SliverEditButton(
              onPressed: () async {
                await NavigationUtil.toWithCallback<bool>(
                  page: () => CreateMeetupPage(editingMeetup: controller.meetup.value),
                  onResult: (result) async {
                    if (result.needsRefresh) {
                      await controller.loadEventDetails();
                      controller.hasDataChanged.value = true;
                    }
                  },
                );
              },
              size: 18,
            );
          }
          return const SizedBox.shrink();
        }),
        SliverShareButton(onPressed: () => _shareMeetup(context)),
        // 举报按钮 - 非组织者可见
        Obx(() {
          if (!controller.isOrganizer) {
            return IconButton(
              icon: const Icon(FontAwesomeIcons.circleExclamation, color: Colors.white, size: 18),
              onPressed: () {
                ReportDialog.show(
                  context: context,
                  contentType: ReportContentType.meetup,
                  targetId: controller.meetup.value?.id ?? '',
                  targetName: controller.meetup.value?.title,
                );
              },
              tooltip: AppLocalizations.of(context)!.report,
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        background: MeetupImageCarousel(),
      ),
    );
  }

  /// 构建内容区域
  SliverToBoxAdapter _buildContent() {
    return SliverToBoxAdapter(
      child: Obx(() {
        // 显示加载指示器
        if (controller.isLoading.value) {
          return Container(
            padding: EdgeInsets.all(40.w),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF4458),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            const MeetupBasicInfoSection(),
            SizedBox(height: 16.h),

            // 时间地点
            const MeetupTimeLocationSection(),
            SizedBox(height: 16.h),

            // 描述
            const MeetupDescriptionSection(),
            SizedBox(height: 16.h),

            // 组织者信息
            const MeetupOrganizerSection(),
            SizedBox(height: 16.h),

            // 参与者列表
            const MeetupAttendeesSection(),
            SizedBox(height: 100.h),
          ],
        );
      }),
    );
  }

  /// 分享活动
  void _shareMeetup(BuildContext context) {
    final meetupData = controller.meetup.value;
    if (meetupData == null) return;

    // 格式化时间
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
    final timeStr = dateFormat.format(meetupData.schedule.startTime);

    // 构建分享内容
    final String title = '${meetupData.title} - 数字游民聚会';
    final String description = '📅 时间: $timeStr\n'
        '📍 地点: ${meetupData.venue.name}\n'
        '👥 组织者: ${meetupData.organizer.name}\n\n'
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
